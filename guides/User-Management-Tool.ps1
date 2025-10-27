# User-Management-Tool.ps1
# Komplett verktøy for brukeradministrasjon i Microsoft EntraID
# Versjon: 1.0
# Dato: Oktober 2025

<#
.SYNOPSIS
    Brukeradministrasjonsverktøy for Microsoft EntraID
    
.DESCRIPTION
    Dette scriptet gir et komplett sett med verktøy for å administrere
    brukere i Microsoft 365/EntraID miljøet.
    
.PARAMETER Action
    Hvilken handling som skal utføres:
    - CreateUser: Opprett ny bruker
    - DisableUser: Deaktiver bruker
    - EnableUser: Aktiver bruker
    - ResetPassword: Tilbakestill passord
    - BulkImport: Importer flere brukere fra CSV
    - GenerateReport: Generer brukerrapport
    - FindInactive: Finn inaktive brukere
    - UpdateDepartment: Oppdater avdeling
    
.PARAMETER UserPrincipalName
    E-postadressen til brukeren
    
.PARAMETER CsvFile
    Sti til CSV-fil for bulk-operasjoner
    
.PARAMETER Department
    Avdeling for bruker eller filtrering
    
.PARAMETER ExportPath
    Sti for eksport av rapporter (standard: .\Reports)
    
.PARAMETER WhatIf
    Kjør i test-modus uten å gjøre endringer
    
.EXAMPLE
    .\User-Management-Tool.ps1 -Action CreateUser -UserPrincipalName "ny@bedrift.no"
    Oppretter en ny bruker
    
.EXAMPLE
    .\User-Management-Tool.ps1 -Action BulkImport -CsvFile "users.csv" -WhatIf
    Tester bulk-import uten å opprette brukere
    
.EXAMPLE
    .\User-Management-Tool.ps1 -Action GenerateReport -Department "IT" -ExportPath "C:\Reports"
    Genererer rapport for IT-avdelingen
    
.EXAMPLE
    .\User-Management-Tool.ps1 -Action FindInactive
    Finner brukere som ikke har logget inn på 90 dager
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("CreateUser", "DisableUser", "EnableUser", "ResetPassword", 
                 "BulkImport", "GenerateReport", "FindInactive", "UpdateDepartment")]
    [string]$Action,
    
    [Parameter()]
    [string]$UserPrincipalName,
    
    [Parameter()]
    [string]$CsvFile,
    
    [Parameter()]
    [string]$Department,
    
    [Parameter()]
    [string]$ExportPath = ".\Reports",
    
    [Parameter()]
    [switch]$WhatIf
)

# Farger for output
$colors = @{
    Error = "Red"
    Warning = "Yellow"
    Success = "Green"
    Info = "Cyan"
    Default = "White"
}

# Hjelpefunksjoner
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp [$Level] $Message"
    
    # Skriv til konsoll med farge
    $color = if ($colors.ContainsKey($Level)) { $colors[$Level] } else { $colors.Default }
    Write-Host $logMessage -ForegroundColor $color
    
    # Opprett log-mappe hvis den ikke eksisterer
    $logPath = Join-Path $ExportPath "Logs"
    if (-not (Test-Path $logPath)) {
        New-Item -Path $logPath -ItemType Directory -Force | Out-Null
    }
    
    # Logg til fil
    $logFile = Join-Path $logPath "user-management-$(Get-Date -Format 'yyyyMMdd').log"
    Add-Content -Path $logFile -Value $logMessage -ErrorAction SilentlyContinue
}

function Connect-GraphIfNeeded {
    $context = Get-MgContext -ErrorAction SilentlyContinue
    if ($null -eq $context) {
        Write-Log "Kobler til Microsoft Graph..." "Info"
        try {
            Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All", "AuditLog.Read.All" -ErrorAction Stop
            Write-Log "Tilkoblet Microsoft Graph" "Success"
            return $true
        } catch {
            Write-Log "Kunne ikke koble til Graph: $_" "Error"
            return $false
        }
    }
    Write-Log "Allerede koblet til Microsoft Graph" "Info"
    return $true
}

function New-UserAccount {
    param(
        [string]$UserPrincipalName,
        [string]$DisplayName,
        [string]$FirstName,
        [string]$LastName,
        [string]$Department,
        [string]$JobTitle,
        [string]$Office
    )
    
    if ($WhatIf) {
        Write-Log "[WhatIf] Ville opprettet bruker: $UserPrincipalName" "Warning"
        Write-Log "  Navn: $DisplayName" "Info"
        Write-Log "  Avdeling: $Department" "Info"
        Write-Log "  Stilling: $JobTitle" "Info"
        return @{ Success = $true; WhatIf = $true }
    }
    
    try {
        # Generer sikker passord
        $passwordChars = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!@#%"
        $password = -join ((1..12) | ForEach-Object { $passwordChars[(Get-Random -Maximum $passwordChars.Length)] })
        $password = "Welcome-" + $password
        
        # Forbered bruker-objektet
        $userParams = @{
            UserPrincipalName = $UserPrincipalName
            DisplayName = $DisplayName
            MailNickname = $UserPrincipalName.Split('@')[0]
            AccountEnabled = $true
            PasswordProfile = @{
                Password = $password
                ForceChangePasswordNextSignIn = $true
            }
        }
        
        # Legg til valgfrie parametere hvis de er angitt
        if ($FirstName) { $userParams.GivenName = $FirstName }
        if ($LastName) { $userParams.Surname = $LastName }
        if ($Department) { $userParams.Department = $Department }
        if ($JobTitle) { $userParams.JobTitle = $JobTitle }
        if ($Office) { $userParams.OfficeLocation = $Office }
        
        # Opprett bruker
        $newUser = New-MgUser @userParams -ErrorAction Stop
        
        Write-Log "Bruker opprettet: $UserPrincipalName" "Success"
        Write-Log "  User ID: $($newUser.Id)" "Info"
        Write-Log "  Midlertidig passord: $password" "Warning"
        
        return @{
            Success = $true
            UserId = $newUser.Id
            Password = $password
            User = $newUser
        }
        
    } catch {
        Write-Log "Feil ved opprettelse av $UserPrincipalName : $_" "Error"
        return @{ 
            Success = $false
            Error = $_.Exception.Message 
        }
    }
}

function Disable-UserAccount {
    param([string]$UserPrincipalName)
    
    if ($WhatIf) {
        Write-Log "[WhatIf] Ville deaktivert: $UserPrincipalName" "Warning"
        return $true
    }
    
    try {
        # Hent bruker først for å verifisere at den eksisterer
        $user = Get-MgUser -UserId $UserPrincipalName -ErrorAction Stop
        Write-Log "Fant bruker: $($user.DisplayName)" "Info"
        
        # Deaktiver bruker
        Update-MgUser -UserId $UserPrincipalName -AccountEnabled:$false -ErrorAction Stop
        Write-Log "Bruker deaktivert: $UserPrincipalName" "Success"
        
        # Fjern fra alle grupper (valgfritt)
        $groups = Get-MgUserMemberOf -UserId $UserPrincipalName
        if ($groups) {
            Write-Log "Bruker er medlem av $($groups.Count) grupper" "Info"
        }
        
        return $true
    } catch {
        Write-Log "Kunne ikke deaktivere $UserPrincipalName : $_" "Error"
        return $false
    }
}

function Reset-UserPassword {
    param([string]$UserPrincipalName)
    
    if ($WhatIf) {
        Write-Log "[WhatIf] Ville tilbakestilt passord for: $UserPrincipalName" "Warning"
        return @{ Success = $true; WhatIf = $true }
    }
    
    try {
        # Generer nytt passord
        $newPassword = "Reset-$(Get-Random -Minimum 100000 -Maximum 999999)!"
        
        # Oppdater passord
        Update-MgUser -UserId $UserPrincipalName `
                     -PasswordProfile @{
                         Password = $newPassword
                         ForceChangePasswordNextSignIn = $true
                     } -ErrorAction Stop
        
        Write-Log "Passord tilbakestilt for: $UserPrincipalName" "Success"
        Write-Log "Nytt midlertidig passord: $newPassword" "Warning"
        
        return @{
            Success = $true
            Password = $newPassword
        }
    } catch {
        Write-Log "Kunne ikke tilbakestille passord: $_" "Error"
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

function Import-BulkUsers {
    param([string]$CsvPath)
    
    if (-not (Test-Path $CsvPath)) {
        Write-Log "CSV-fil ikke funnet: $CsvPath" "Error"
        return
    }
    
    # Les CSV
    try {
        $users = Import-Csv $CsvPath -Encoding UTF8
        Write-Log "Leste $($users.Count) brukere fra CSV" "Info"
    } catch {
        Write-Log "Kunne ikke lese CSV: $_" "Error"
        return
    }
    
    # Valider kolonner
    $requiredColumns = @("Fornavn", "Etternavn", "Email")
    $csvColumns = $users[0].PSObject.Properties.Name
    $missingColumns = $requiredColumns | Where-Object { $_ -notin $csvColumns }
    
    if ($missingColumns) {
        Write-Log "Mangler påkrevde kolonner: $($missingColumns -join ', ')" "Error"
        return
    }
    
    # Prosesser hver bruker
    $results = @()
    $successCount = 0
    $errorCount = 0
    $skipCount = 0
    
    foreach ($user in $users) {
        Write-Log "" "Info"
        Write-Log "Prosesserer bruker $($successCount + $errorCount + $skipCount + 1) av $($users.Count)" "Info"
        
        # Sjekk om bruker allerede eksisterer
        $existingUser = Get-MgUser -Filter "userPrincipalName eq '$($user.Email)'" -ErrorAction SilentlyContinue
        if ($existingUser) {
            Write-Log "Bruker eksisterer allerede: $($user.Email)" "Warning"
            $skipCount++
            $results += [PSCustomObject]@{
                Email = $user.Email
                Name = "$($user.Fornavn) $($user.Etternavn)"
                Status = "Skipped - Already exists"
                UserId = $existingUser.Id
            }
            continue
        }
        
        # Opprett bruker
        $result = New-UserAccount -UserPrincipalName $user.Email `
                                 -DisplayName "$($user.Fornavn) $($user.Etternavn)" `
                                 -FirstName $user.Fornavn `
                                 -LastName $user.Etternavn `
                                 -Department $user.Avdeling `
                                 -JobTitle $user.Stilling `
                                 -Office $user.Lokasjon
        
        if ($result.Success) {
            $successCount++
            $results += [PSCustomObject]@{
                Email = $user.Email
                Name = "$($user.Fornavn) $($user.Etternavn)"
                Status = "Created"
                UserId = $result.UserId
                Password = $result.Password
            }
        } else {
            $errorCount++
            $results += [PSCustomObject]@{
                Email = $user.Email
                Name = "$($user.Fornavn) $($user.Etternavn)"
                Status = "Failed"
                Error = $result.Error
            }
        }
        
        # Vent litt mellom hver bruker for å unngå throttling
        Start-Sleep -Milliseconds 500
    }
    
    # Vis sammendrag
    Write-Log "" "Info"
    Write-Log "=== Import Sammendrag ===" "Info"
    Write-Log "Totalt prosessert: $($users.Count)" "Info"
    Write-Log "Opprettet: $successCount" "Success"
    Write-Log "Hoppet over: $skipCount" "Warning"
    Write-Log "Feilet: $errorCount" "Error"
    
    # Eksporter resultater
    if ($results.Count -gt 0) {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $resultFile = Join-Path $ExportPath "import-results-$timestamp.csv"
        $results | Export-Csv $resultFile -NoTypeInformation -Encoding UTF8
        Write-Log "Resultater lagret til: $resultFile" "Success"
    }
    
    return $results
}

function Get-InactiveUsersReport {
    param(
        [int]$DaysInactive = 90
    )
    
    Write-Log "Søker etter brukere som ikke har logget inn på $DaysInactive dager..." "Info"
    
    $inactiveDate = (Get-Date).AddDays(-$DaysInactive)
    
    try {
        # Hent alle aktive brukere
        $users = Get-MgUser -All -Property DisplayName,UserPrincipalName,SignInActivity,AccountEnabled,Department,JobTitle `
                           -Filter "accountEnabled eq true" -ErrorAction Stop
        
        Write-Log "Fant $($users.Count) aktive brukere totalt" "Info"
        
        # Filtrer inaktive brukere
        $inactiveUsers = $users | Where-Object { 
            $null -eq $_.SignInActivity.LastSignInDateTime -or 
            $_.SignInActivity.LastSignInDateTime -lt $inactiveDate 
        }
        
        Write-Log "Fant $($inactiveUsers.Count) inaktive brukere" "Warning"
        
        # Lag rapport
        $report = $inactiveUsers | Select-Object DisplayName, 
                                                 UserPrincipalName,
                                                 Department,
                                                 JobTitle,
                                                 @{Name='LastSignIn'; Expression={
                                                     if ($null -eq $_.SignInActivity.LastSignInDateTime) {
                                                         "Never"
                                                     } else {
                                                         $_.SignInActivity.LastSignInDateTime.ToString('yyyy-MM-dd')
                                                     }
                                                 }},
                                                 @{Name='DaysInactive'; Expression={
                                                     if ($null -eq $_.SignInActivity.LastSignInDateTime) {
                                                         "N/A"
                                                     } else {
                                                         [math]::Round(((Get-Date) - $_.SignInActivity.LastSignInDateTime).TotalDays)
                                                     }
                                                 }} | Sort-Object LastSignIn
        
        # Eksporter rapport
        if ($report.Count -gt 0) {
            $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
            $reportFile = Join-Path $ExportPath "inactive-users-$timestamp.csv"
            $report | Export-Csv $reportFile -NoTypeInformation -Encoding UTF8
            Write-Log "Rapport lagret til: $reportFile" "Success"
            
            # Vis de 10 mest inaktive
            Write-Log "" "Info"
            Write-Log "Top 10 mest inaktive brukere:" "Info"
            $report | Select-Object -First 10 | Format-Table DisplayName, Department, LastSignIn, DaysInactive -AutoSize
        }
        
        return $report
        
    } catch {
        Write-Log "Feil ved generering av inaktivitetsrapport: $_" "Error"
        return $null
    }
}

function Get-DepartmentReport {
    param([string]$DepartmentName)
    
    try {
        if ($DepartmentName) {
            Write-Log "Genererer rapport for avdeling: $DepartmentName" "Info"
            $users = Get-MgUser -Filter "department eq '$DepartmentName'" -All `
                               -Property DisplayName,UserPrincipalName,Department,JobTitle,City,AccountEnabled
        } else {
            Write-Log "Genererer rapport for alle avdelinger" "Info"
            $users = Get-MgUser -All `
                               -Property DisplayName,UserPrincipalName,Department,JobTitle,City,AccountEnabled
        }
        
        Write-Log "Fant $($users.Count) brukere" "Info"
        
        # Grupper etter avdeling
        $departmentGroups = $users | Group-Object -Property Department
        
        Write-Log "" "Info"
        Write-Log "=== Avdelingsstatistikk ===" "Info"
        foreach ($dept in $departmentGroups | Sort-Object Count -Descending) {
            $deptName = if ($dept.Name) { $dept.Name } else { "[Ikke angitt]" }
            Write-Log "  $deptName : $($dept.Count) brukere" "Info"
        }
        
        # Lag detaljert rapport
        $report = $users | Select-Object DisplayName, 
                                         UserPrincipalName, 
                                         Department, 
                                         JobTitle, 
                                         City,
                                         @{Name='Status'; Expression={
                                             if ($_.AccountEnabled) { "Aktiv" } else { "Inaktiv" }
                                         }}
        
        # Eksporter rapport
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $reportFile = Join-Path $ExportPath "department-report-$timestamp.csv"
        $report | Export-Csv $reportFile -NoTypeInformation -Encoding UTF8
        Write-Log "Rapport lagret til: $reportFile" "Success"
        
        return $report
        
    } catch {
        Write-Log "Feil ved generering av avdelingsrapport: $_" "Error"
        return $null
    }
}

# ============================================
# HOVEDPROGRAM
# ============================================

Write-Log "=== User Management Tool Started ===" "Info"
Write-Log "Action: $Action" "Info"
if ($WhatIf) {
    Write-Log "WhatIf-modus aktivert - ingen endringer vil bli gjort" "Warning"
}

# Sjekk om Microsoft.Graph-modulen er installert
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Log "Microsoft.Graph-modulen er ikke installert!" "Error"
    Write-Log "Installer med: Install-Module -Name Microsoft.Graph -Scope CurrentUser" "Info"
    exit 1
}

# Opprett eksport-mappe hvis den ikke eksisterer
if (-not (Test-Path $ExportPath)) {
    New-Item -Path $ExportPath -ItemType Directory -Force | Out-Null
    Write-Log "Opprettet eksport-mappe: $ExportPath" "Info"
}

# Koble til Graph hvis nødvendig
$needsConnection = $Action -ne "Help"
if ($needsConnection) {
    if (-not (Connect-GraphIfNeeded)) {
        Write-Log "Kunne ikke etablere tilkobling til Microsoft Graph" "Error"
        exit 1
    }
}

# Utfør valgt handling
try {
    switch ($Action) {
        "CreateUser" {
            if (-not $UserPrincipalName) {
                Write-Log "UserPrincipalName er påkrevd for CreateUser" "Error"
                exit 1
            }
            
            Write-Log "Oppretter bruker: $UserPrincipalName" "Info"
            
            # Samle brukerinformasjon
            if (-not $PSBoundParameters.ContainsKey('WhatIf')) {
                $displayName = Read-Host "Fullt navn"
                $firstName = Read-Host "Fornavn"
                $lastName = Read-Host "Etternavn"
                $dept = if ($Department) { $Department } else { Read-Host "Avdeling" }
                $title = Read-Host "Stilling (valgfritt)"
                $office = Read-Host "Kontor/Lokasjon (valgfritt)"
            } else {
                $displayName = "Test Bruker"
                $firstName = "Test"
                $lastName = "Bruker"
                $dept = if ($Department) { $Department } else { "Test" }
                $title = "Test Stilling"
                $office = "Test Kontor"
            }
            
            $result = New-UserAccount -UserPrincipalName $UserPrincipalName `
                                     -DisplayName $displayName `
                                     -FirstName $firstName `
                                     -LastName $lastName `
                                     -Department $dept `
                                     -JobTitle $title `
                                     -Office $office
            
            if ($result.Success -and -not $result.WhatIf) {
                Write-Log "" "Info"
                Write-Log "Bruker opprettet!" "Success"
                Write-Log "Bruker ID: $($result.UserId)" "Info"
                Write-Log "Midlertidig passord: $($result.Password)" "Warning"
                Write-Log "HUSK: Brukeren må endre passord ved første innlogging" "Warning"
            }
        }
        
        "DisableUser" {
            if (-not $UserPrincipalName) {
                Write-Log "UserPrincipalName er påkrevd for DisableUser" "Error"
                exit 1
            }
            
            Write-Log "Deaktiverer bruker: $UserPrincipalName" "Info"
            
            if (-not $WhatIf) {
                $confirm = Read-Host "Er du sikker på at du vil deaktivere denne brukeren? (J/N)"
                if ($confirm -ne "J" -and $confirm -ne "j") {
                    Write-Log "Operasjon avbrutt av bruker" "Warning"
                    exit 0
                }
            }
            
            $result = Disable-UserAccount -UserPrincipalName $UserPrincipalName
            if ($result) {
                Write-Log "Bruker deaktivert!" "Success"
            }
        }
        
        "EnableUser" {
            if (-not $UserPrincipalName) {
                Write-Log "UserPrincipalName er påkrevd for EnableUser" "Error"
                exit 1
            }
            
            Write-Log "Aktiverer bruker: $UserPrincipalName" "Info"
            
            if ($WhatIf) {
                Write-Log "[WhatIf] Ville aktivert: $UserPrincipalName" "Warning"
            } else {
                try {
                    Update-MgUser -UserId $UserPrincipalName -AccountEnabled:$true -ErrorAction Stop
                    Write-Log "Bruker aktivert: $UserPrincipalName" "Success"
                } catch {
                    Write-Log "Kunne ikke aktivere $UserPrincipalName : $_" "Error"
                }
            }
        }
        
        "ResetPassword" {
            if (-not $UserPrincipalName) {
                Write-Log "UserPrincipalName er påkrevd for ResetPassword" "Error"
                exit 1
            }
            
            Write-Log "Tilbakestiller passord for: $UserPrincipalName" "Info"
            
            if (-not $WhatIf) {
                $confirm = Read-Host "Er du sikker på at du vil tilbakestille passordet? (J/N)"
                if ($confirm -ne "J" -and $confirm -ne "j") {
                    Write-Log "Operasjon avbrutt av bruker" "Warning"
                    exit 0
                }
            }
            
            $result = Reset-UserPassword -UserPrincipalName $UserPrincipalName
            if ($result.Success -and -not $result.WhatIf) {
                Write-Log "" "Info"
                Write-Log "Passord tilbakestilt!" "Success"
                Write-Log "Nytt midlertidig passord: $($result.Password)" "Warning"
                Write-Log "Brukeren må endre passord ved neste innlogging" "Info"
            }
        }
        
        "BulkImport" {
            if (-not $CsvFile) {
                Write-Log "CsvFile parameter er påkrevd for BulkImport" "Error"
                Write-Log "Eksempel: -CsvFile 'C:\path\to\users.csv'" "Info"
                exit 1
            }
            
            if (-not (Test-Path $CsvFile)) {
                Write-Log "CSV-fil ikke funnet: $CsvFile" "Error"
                exit 1
            }
            
            Write-Log "Starter bulk-import fra: $CsvFile" "Info"
            
            if (-not $WhatIf) {
                $confirm = Read-Host "Dette vil opprette flere brukere. Fortsette? (J/N)"
                if ($confirm -ne "J" -and $confirm -ne "j") {
                    Write-Log "Import avbrutt av bruker" "Warning"
                    exit 0
                }
            }
            
            $results = Import-BulkUsers -CsvPath $CsvFile
        }
        
        "GenerateReport" {
            if ($Department) {
                Write-Log "Genererer rapport for avdeling: $Department" "Info"
            } else {
                Write-Log "Genererer rapport for alle brukere" "Info"
            }
            
            $report = Get-DepartmentReport -DepartmentName $Department
            
            if ($report) {
                Write-Log "" "Info"
                Write-Log "Rapport generert med $($report.Count) brukere" "Success"
            }
        }
        
        "FindInactive" {
            Write-Log "Søker etter inaktive brukere..." "Info"
            
            $daysInactive = 90
            if (-not $WhatIf) {
                $customDays = Read-Host "Antall dager inaktiv (standard: 90)"
                if ($customDays) {
                    $daysInactive = [int]$customDays
                }
            }
            
            $report = Get-InactiveUsersReport -DaysInactive $daysInactive
            
            if ($report) {
                Write-Log "" "Info"
                Write-Log "Analyse fullført!" "Success"
            }
        }
        
        "UpdateDepartment" {
            if (-not $UserPrincipalName -or -not $Department) {
                Write-Log "Både UserPrincipalName og Department er påkrevd" "Error"
                Write-Log "Eksempel: -UserPrincipalName 'user@domain.com' -Department 'IT'" "Info"
                exit 1
            }
            
            Write-Log "Oppdaterer avdeling for: $UserPrincipalName" "Info"
            Write-Log "Ny avdeling: $Department" "Info"
            
            if ($WhatIf) {
                Write-Log "[WhatIf] Ville oppdatert $UserPrincipalName til avdeling: $Department" "Warning"
            } else {
                try {
                    # Hent eksisterende brukerinfo
                    $user = Get-MgUser -UserId $UserPrincipalName -Property DisplayName,Department -ErrorAction Stop
                    $oldDept = if ($user.Department) { $user.Department } else { "[Ikke angitt]" }
                    
                    # Oppdater avdeling
                    Update-MgUser -UserId $UserPrincipalName -Department $Department -ErrorAction Stop
                    
                    Write-Log "Avdeling oppdatert!" "Success"
                    Write-Log "  Bruker: $($user.DisplayName)" "Info"
                    Write-Log "  Fra: $oldDept" "Info"
                    Write-Log "  Til: $Department" "Info"
                } catch {
                    Write-Log "Kunne ikke oppdatere avdeling: $_" "Error"
                }
            }
        }
        
        default {
            Write-Log "Ukjent handling: $Action" "Error"
            exit 1
        }
    }
} finally {
    # Koble fra Graph
    if ($needsConnection) {
        Disconnect-MgGraph -ErrorAction SilentlyContinue
        Write-Log "Frakoblet Microsoft Graph" "Info"
    }
}

Write-Log "=== User Management Tool Completed ===" "Info"