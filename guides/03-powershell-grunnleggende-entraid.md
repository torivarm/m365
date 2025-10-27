# PowerShell Grunnleggende og Brukeradministrasjon i Microsoft EntraID

## 📚 Innholdsfortegnelse
1. [Introduksjon](#introduksjon)
2. [Variabler og grunnleggende struktur](#variabler-og-grunnleggende-struktur)
3. [Betingelser: If/Else og Switch](#betingelser-ifelse-og-switch)
4. [Løkker: ForEach og For](#løkker-foreach-og-for)
5. [Feilhåndtering med Try/Catch](#feilhåndtering-med-trycatch)
6. [Funksjoner](#funksjoner)
7. [Import av datafiler](#import-av-datafiler)
8. [Objektbehandling og pipelining](#objektbehandling-og-pipelining)
9. [Parametre og skript som verktøy](#parametre-og-skript-som-verktøy)
10. [Komplett eksempel: Brukeradministrasjonsverktøy](#komplett-eksempel-brukeradministrasjonsverktøy)

---

## Introduksjon

Denne veiviseren tar deg gjennom grunnleggende PowerShell-programmering med praktiske eksempler fra Microsoft EntraID (tidligere Azure AD) brukeradministrasjon. Du vil lære å bygge skript fra bunnen av, med fokus på virkelige scenarier du møter i Microsoft 365-administrasjon.

### 📋 Forutsetninger
- VS Code og PowerShell Core installert (se tidligere veiviser)
- Microsoft.Graph-modulen installert
- Tilgang til et Microsoft 365 test-miljø

### 🎯 Læringsmål
- Forstå PowerShell-syntaks og struktur
- Bygge gjenbrukbare skript for brukeradministrasjon
- Implementere feilhåndtering og logging
- Automatisere vanlige administrative oppgaver

---

## Variabler og grunnleggende struktur

### 📖 Konsept
Variabler i PowerShell starter alltid med `$` og kan lagre alle typer data. PowerShell er dynamisk typet, så du trenger ikke deklarere type på forhånd.

### 🔧 Grunnleggende variabeltyper

```powershell
# enkle-variabler.ps1
# Demonstrerer ulike variabeltyper i PowerShell

# Tekststrenger (String)
$brukerNavn = "Ola Nordmann"
$epost = "ola.nordmann@bedrift.no"

# Tall (Integer, Double)
$alder = 35
$lønn = 450000.50

# Boolean (Sant/Usant)
$erAktiv = $true
$harLisens = $false

# Dato
$opprettetDato = Get-Date
$utløpsDato = (Get-Date).AddDays(90)

# Array (liste)
$avdelinger = @("IT", "HR", "Salg", "Økonomi")

# HashTable (nøkkel-verdi par)
$brukerInfo = @{
    Fornavn = "Ola"
    Etternavn = "Nordmann"
    Avdeling = "IT"
    Lokasjon = "Oslo"
}

# Vis variabelinnhold
Write-Host "Bruker: $brukerNavn"
Write-Host "E-post: $epost"
Write-Host "Opprettet: $($opprettetDato.ToString('yyyy-MM-dd'))"
Write-Host "Avdelinger: $($avdelinger -join ', ')"
Write-Host "Brukerinfo: $($brukerInfo.Fornavn) $($brukerInfo.Etternavn) - $($brukerInfo.Avdeling)"
```

### 💡 EntraID-eksempel: Lagre brukerinformasjon

```powershell
# entraid-variabler.ps1
# Praktisk eksempel med Microsoft Graph

# Koble til Microsoft Graph
Connect-MgGraph -Scopes "User.Read.All"

# Hent en bruker og lagre i variabel (MERK! I eksemplet under må navn erstattes med en av sine egne brukere og bedrift.no må erstattes med egen @<eget-opprettet-navn>.onmicrosoft.com)
$bruker = Get-MgUser -UserId "ola.nordmann@bedrift.no"

# Lagre spesifikke egenskaper
$displayNavn = $bruker.DisplayName
$jobbtittel = $bruker.JobTitle
$avdeling = $bruker.Department

# Sjekk om bruker har lisens (array av lisenser)
$lisenser = Get-MgUserLicenseDetail -UserId $bruker.Id
$harM365Lisens = $lisenser.SkuPartNumber -contains "SPB"

# Vis informasjon
Write-Host "=== Brukerinformasjon ===" -ForegroundColor Cyan
Write-Host "Navn: $displayNavn"
Write-Host "Stilling: $jobbtittel"
Write-Host "Avdeling: $avdeling"
Write-Host "Har Microsoft 365 Business Premium lisens: $harM365Lisens"

Disconnect-MgGraph
```

---

## Betingelser: If/Else og Switch

### 📖 Konsept
Betingelser lar skriptet ta beslutninger basert på verdier og tilstander. `If/Else` brukes for enkle tester, mens `Switch` er bedre for mange alternativer.

### 🔧 If/Else grunnleggende

```powershell
# if-else-basics.ps1
# Grunnleggende if/else struktur

$brukerStatus = "Aktiv"
$sisteInnlogging = (Get-Date).AddDays(-45)
$dageSidenInnlogging = (Get-Date) - $sisteInnlogging

# Enkel if-test
if ($brukerStatus -eq "Aktiv") {
    Write-Host "Brukeren er aktiv" -ForegroundColor Green
}

# If-else
if ($dageSidenInnlogging.Days -gt 30) {
    Write-Host "⚠️ Brukeren har ikke logget inn på over 30 dager" -ForegroundColor Yellow
} else {
    Write-Host "✅ Brukeren har nylig vært innlogget" -ForegroundColor Green
}

# If-elseif-else
if ($dageSidenInnlogging.Days -gt 90) {
    Write-Host "❌ Inaktiv bruker - vurder deaktivering" -ForegroundColor Red
} elseif ($dageSidenInnlogging.Days -gt 30) {
    Write-Host "⚠️ Bruker viser tegn til inaktivitet" -ForegroundColor Yellow
} else {
    Write-Host "✅ Aktiv bruker" -ForegroundColor Green
}
```

### 💡 EntraID-eksempel: Sjekk brukerstatus

```powershell
# check-user-status.ps1
# Sjekk og håndter brukerstatus i EntraID

Connect-MgGraph -Scopes "User.Read.All", "User.Update.All"

function Test-BrukerStatus {
    param(
        [string]$UserPrincipalName
    )
    
    $bruker = Get-MgUser -UserId $UserPrincipalName -Property DisplayName,AccountEnabled,LastPasswordChangeDateTime,SignInActivity
    
    if ($null -eq $bruker) {
        Write-Host "❌ Bruker ikke funnet" -ForegroundColor Red
        return
    }
    
    # Sjekk om konto er aktivert
    if ($bruker.AccountEnabled) {
        Write-Host "✅ Konto er aktiv: $($bruker.DisplayName)" -ForegroundColor Green
        
        # Sjekk passord-alder
        if ($bruker.LastPasswordChangeDateTime) {
            $passordAlder = (Get-Date) - $bruker.LastPasswordChangeDateTime
            
            if ($passordAlder.Days -gt 90) {
                Write-Host "⚠️ Passordet er $($passordAlder.Days) dager gammelt - bør endres" -ForegroundColor Yellow
            } else {
                Write-Host "✅ Passordet er $($passordAlder.Days) dager gammelt" -ForegroundColor Green
            }
        }
    } else {
        Write-Host "❌ Konto er deaktivert: $($bruker.DisplayName)" -ForegroundColor Red
        
        $svar = Read-Host "Ønsker du å aktivere kontoen? (J/N)"
        if ($svar -eq "J") {
            Update-MgUser -UserId $UserPrincipalName -AccountEnabled:$true
            Write-Host "✅ Konto aktivert" -ForegroundColor Green
        }
    }
}

# Test funksjonen
Test-BrukerStatus -UserPrincipalName "test@bedrift.no"

Disconnect-MgGraph
```

### 🔧 Switch-setninger

```powershell
# switch-example.ps1
# Bruk av switch for flere alternativer

function Set-BrukerLisens {
    param(
        [string]$Brukertype
    )
    
    switch ($Brukertype) {
        "Standard" {
            $lisens = "SPE_E3"
            $beskrivelse = "Microsoft 365 E3"
        }
        "Frontline" {
            $lisens = "SPE_F1"
            $beskrivelse = "Microsoft 365 F3"
        }
        "Basic" {
            $lisens = "O365_BUSINESS_ESSENTIALS"
            $beskrivelse = "Microsoft 365 Business Basic"
        }
        "Ekstern" {
            $lisens = "EXCHANGESTANDARD"
            $beskrivelse = "Exchange Online Plan 1"
        }
        default {
            Write-Host "❌ Ukjent brukertype: $Brukertype" -ForegroundColor Red
            return
        }
    }
    
    Write-Host "Tildeler lisens: $beskrivelse ($lisens)" -ForegroundColor Cyan
    # Her ville du faktisk tildelt lisensen med Set-MgUserLicense
}

# Test switch
Set-BrukerLisens -Brukertype "Standard"
Set-BrukerLisens -Brukertype "Frontline"
Set-BrukerLisens -Brukertype "Ukjent"
```

---

## Løkker: ForEach og For

### 📖 Konsept
Løkker lar deg utføre samme operasjon på mange elementer. `ForEach` er mest brukt for å gå gjennom lister, mens `For` gir mer kontroll over iterasjonen.

### 🔧 ForEach-løkker

```powershell
# foreach-basics.ps1
# Grunnleggende ForEach-eksempler

# ForEach med array
$avdelinger = @("IT", "HR", "Salg", "Økonomi", "Marked")

Write-Host "=== Avdelinger ===" -ForegroundColor Cyan
foreach ($avdeling in $avdelinger) {
    Write-Host "Behandler avdeling: $avdeling"
    # Her kunne du gjort noe med hver avdeling
}

# ForEach med hashtable
$brukerRoller = @{
    "ola.nordmann@bedrift.no" = "Administrator"
    "kari.hansen@bedrift.no" = "Bruker"
    "per.olsen@bedrift.no" = "Gjest"
}

Write-Host "`n=== Brukerroller ===" -ForegroundColor Cyan
foreach ($bruker in $brukerRoller.GetEnumerator()) {
    Write-Host "$($bruker.Key) har rolle: $($bruker.Value)"
}

# ForEach-Object i pipeline (mer effektivt for store datamengder)
1..5 | ForEach-Object {
    Write-Host "Nummer: $_"
}
```

### 💡 EntraID-eksempel: Behandle flere brukere

```powershell
# process-multiple-users.ps1
# Behandle flere brukere med ForEach

Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All"

# Hent alle brukere i en avdeling
$itBrukere = Get-MgUser -Filter "department eq 'IT'" -Property DisplayName,UserPrincipalName,AccountEnabled

Write-Host "=== IT-avdeling Brukerrapport ===" -ForegroundColor Cyan
Write-Host "Antall brukere: $($itBrukere.Count)" -ForegroundColor Yellow
Write-Host ""

$aktiveBrukere = 0
$inaktiveBrukere = 0

foreach ($bruker in $itBrukere) {
    if ($bruker.AccountEnabled) {
        Write-Host "✅ $($bruker.DisplayName) - AKTIV" -ForegroundColor Green
        $aktiveBrukere++
    } else {
        Write-Host "❌ $($bruker.DisplayName) - INAKTIV" -ForegroundColor Red
        $inaktiveBrukere++
    }
}

Write-Host ""
Write-Host "Sammendrag:" -ForegroundColor Cyan
Write-Host "  Aktive: $aktiveBrukere" -ForegroundColor Green
Write-Host "  Inaktive: $inaktiveBrukere" -ForegroundColor Red

Disconnect-MgGraph
```

### 🔧 For-løkker

```powershell
# for-loops.ps1
# Bruk av For-løkker for mer kontroll

# Standard for-løkke
Write-Host "Teller fra 1 til 5:" -ForegroundColor Cyan
for ($i = 1; $i -le 5; $i++) {
    Write-Host "  Tall: $i"
}

# Prosessere array med indeks
$brukere = @("Ola", "Kari", "Per", "Anne", "Lars")

Write-Host "`nBrukere med nummer:" -ForegroundColor Cyan
for ($i = 0; $i -lt $brukere.Count; $i++) {
    Write-Host "  $($i + 1). $($brukere[$i])"
}

# Batch-prosessering
$alleBrukere = 1..100  # Simuler 100 brukere
$batchStørrelse = 10

Write-Host "`nBatch-prosessering:" -ForegroundColor Cyan
for ($i = 0; $i -lt $alleBrukere.Count; $i += $batchStørrelse) {
    $batch = $alleBrukere[$i..($i + $batchStørrelse - 1)]
    Write-Host "  Prosesserer batch $($i/$batchStørrelse + 1): Bruker $($batch[0]) til $($batch[-1])"
    Start-Sleep -Milliseconds 500  # Simuler prosessering
}
```

---

## Feilhåndtering med Try/Catch

### 📖 Konsept
Feilhåndtering sikrer at skriptet ditt kan håndtere uventede situasjoner på en kontrollert måte. `Try/Catch/Finally` lar deg fange opp og håndtere feil.

### 🔧 Grunnleggende Try/Catch

```powershell
# try-catch-basics.ps1
# Grunnleggende feilhåndtering

# Enkel try/catch
try {
    # Prøv å gjøre noe som kan feile
    $resultat = 10 / 0  # Dette vil gi en feil
} catch {
    Write-Host "❌ En feil oppstod: $_" -ForegroundColor Red
}

# Try/catch med spesifikk feiltype
try {
    Get-Item "C:\IkkeEksisterende\fil.txt" -ErrorAction Stop
} catch [System.Management.Automation.ItemNotFoundException] {
    Write-Host "⚠️ Filen ble ikke funnet" -ForegroundColor Yellow
} catch {
    Write-Host "❌ Generell feil: $_" -ForegroundColor Red
}

# Try/catch/finally
try {
    Write-Host "Starter operasjon..." -ForegroundColor Cyan
    # Simuler operasjon
    throw "Simulert feil"
} catch {
    Write-Host "❌ Feil: $_" -ForegroundColor Red
} finally {
    Write-Host "🧹 Rydder opp..." -ForegroundColor Gray
    # Finally kjører alltid, uansett om det var feil eller ikke
}
```

### 💡 EntraID-eksempel: Robust brukeropprettelse

```powershell
# safe-user-creation.ps1
# Sikker brukeropprettelse med feilhåndtering

function New-SafeMgUser {
    param(
        [Parameter(Mandatory)]
        [string]$DisplayName,
        
        [Parameter(Mandatory)]
        [string]$UserPrincipalName,
        
        [Parameter(Mandatory)]
        [string]$Password,
        
        [string]$Department = "Ikke angitt"
    )
    
    # Loggfil
    $logFile = "user-creation-$(Get-Date -Format 'yyyyMMdd').log"
    
    try {
        Write-Host "Oppretter bruker: $UserPrincipalName" -ForegroundColor Cyan
        
        # Valider input
        if ($UserPrincipalName -notmatch '^[\w\.-]+@[\w\.-]+\.\w+$') {
            throw "Ugyldig e-postformat: $UserPrincipalName"
        }
        
        if ($Password.Length -lt 8) {
            throw "Passordet må være minst 8 tegn"
        }
        
        # Koble til hvis ikke allerede tilkoblet
        $context = Get-MgContext -ErrorAction SilentlyContinue
        if ($null -eq $context) {
            Write-Host "Kobler til Microsoft Graph..." -ForegroundColor Yellow
            Connect-MgGraph -Scopes "User.ReadWrite.All" -ErrorAction Stop
        }
        
        # Sjekk om bruker allerede eksisterer
        $eksisterendeBruker = Get-MgUser -Filter "userPrincipalName eq '$UserPrincipalName'" -ErrorAction SilentlyContinue
        
        if ($eksisterendeBruker) {
            throw "Bruker eksisterer allerede: $UserPrincipalName"
        }
        
        # Opprett bruker
        $passwordProfile = @{
            Password = $Password
            ForceChangePasswordNextSignIn = $true
        }
        
        $newUser = New-MgUser -DisplayName $DisplayName `
                              -UserPrincipalName $UserPrincipalName `
                              -MailNickname ($UserPrincipalName.Split('@')[0]) `
                              -PasswordProfile $passwordProfile `
                              -Department $Department `
                              -AccountEnabled:$true `
                              -ErrorAction Stop
        
        # Logg suksess
        $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - SUCCESS - Created user: $UserPrincipalName"
        Add-Content -Path $logFile -Value $logEntry
        
        Write-Host "✅ Bruker opprettet successfully!" -ForegroundColor Green
        Write-Host "   ID: $($newUser.Id)" -ForegroundColor Gray
        Write-Host "   Navn: $($newUser.DisplayName)" -ForegroundColor Gray
        
        return $newUser
        
    } catch [Microsoft.Graph.PowerShell.Models.ODataErrors.ODataError] {
        # Spesifikk Graph API-feil
        $errorMessage = "Graph API-feil: $($_.Exception.Message)"
        Write-Host "❌ $errorMessage" -ForegroundColor Red
        
        # Logg feil
        $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR - $errorMessage"
        Add-Content -Path $logFile -Value $logEntry
        
    } catch {
        # Generell feil
        $errorMessage = "Feil ved brukeropprettelse: $_"
        Write-Host "❌ $errorMessage" -ForegroundColor Red
        
        # Logg feil
        $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - ERROR - $errorMessage"
        Add-Content -Path $logFile -Value $logEntry
        
    } finally {
        Write-Host "Log lagret til: $logFile" -ForegroundColor Gray
    }
}

# Test funksjonen
# New-SafeMgUser -DisplayName "Test Bruker" -UserPrincipalName "test@bedrift.no" -Password "P@ssw0rd123!"
```

---

## Funksjoner

### 📖 Konsept
Funksjoner lar deg organisere kode i gjenbrukbare blokker. De kan ta inn parametere, utføre operasjoner og returnere resultater.

### 🔧 Grunnleggende funksjoner

```powershell
# functions-basics.ps1
# Grunnleggende funksjonsstruktur

# Enkel funksjon uten parametere
function Say-Hello {
    Write-Host "Hei fra funksjonen!" -ForegroundColor Cyan
}

# Funksjon med parametere
function Get-Greeting {
    param(
        [string]$Name = "Verden",
        [int]$Hour = (Get-Date).Hour
    )
    
    if ($Hour -lt 12) {
        $greeting = "God morgen"
    } elseif ($Hour -lt 18) {
        $greeting = "God dag"
    } else {
        $greeting = "God kveld"
    }
    
    return "$greeting, $Name!"
}

# Funksjon med obligatoriske parametere og validering
function Calculate-Age {
    param(
        [Parameter(Mandatory=$true)]
        [DateTime]$BirthDate,
        
        [DateTime]$ReferenceDate = (Get-Date)
    )
    
    if ($BirthDate -gt $ReferenceDate) {
        Write-Error "Fødselsdato kan ikke være i fremtiden!"
        return
    }
    
    $age = $ReferenceDate.Year - $BirthDate.Year
    if ($ReferenceDate.DayOfYear -lt $BirthDate.DayOfYear) {
        $age--
    }
    
    return $age
}

# Test funksjonene
Say-Hello
$hilsen = Get-Greeting -Name "Student" -Hour 14
Write-Host $hilsen

$alder = Calculate-Age -BirthDate "1990-05-15"
Write-Host "Alder: $alder år"
```

### 💡 EntraID-eksempel: Avanserte brukerfunksjoner

```powershell
# user-management-functions.ps1
# Praktiske funksjoner for brukeradministrasjon

function Get-UserLicenseReport {
    <#
    .SYNOPSIS
        Genererer en lisensrapport for en bruker
    
    .DESCRIPTION
        Henter alle lisenser tildelt en bruker og viser status
    
    .PARAMETER UserPrincipalName
        E-postadressen til brukeren
    
    .EXAMPLE
        Get-UserLicenseReport -UserPrincipalName "ola@bedrift.no"
    #>
    
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserPrincipalName
    )
    
    try {
        # Hent bruker
        $user = Get-MgUser -UserId $UserPrincipalName -ErrorAction Stop
        
        # Hent lisenser
        $licenses = Get-MgUserLicenseDetail -UserId $user.Id
        
        if ($licenses.Count -eq 0) {
            Write-Host "⚠️ Ingen lisenser tildelt $($user.DisplayName)" -ForegroundColor Yellow
            return
        }
        
        # Lag rapport
        $report = [PSCustomObject]@{
            UserName = $user.DisplayName
            UserPrincipalName = $user.UserPrincipalName
            LicenseCount = $licenses.Count
            Licenses = @()
        }
        
        foreach ($license in $licenses) {
            $licenseInfo = [PSCustomObject]@{
                Name = $license.SkuPartNumber
                Id = $license.SkuId
                ServicePlans = $license.ServicePlans | Where-Object { $_.ProvisioningStatus -eq "Success" } | Select-Object -ExpandProperty ServicePlanName
            }
            $report.Licenses += $licenseInfo
        }
        
        return $report
        
    } catch {
        Write-Error "Kunne ikke generere rapport: $_"
        return $null
    }
}

function Set-BulkUserDepartment {
    <#
    .SYNOPSIS
        Oppdaterer avdeling for flere brukere samtidig
    #>
    
    param(
        [Parameter(Mandatory=$true)]
        [string[]]$UserPrincipalNames,
        
        [Parameter(Mandatory=$true)]
        [string]$Department,
        
        [switch]$WhatIf
    )
    
    $successCount = 0
    $failureCount = 0
    $results = @()
    
    foreach ($upn in $UserPrincipalNames) {
        try {
            if ($WhatIf) {
                Write-Host "[WhatIf] Ville oppdatert $upn til avdeling: $Department" -ForegroundColor Cyan
                $successCount++
            } else {
                Update-MgUser -UserId $upn -Department $Department -ErrorAction Stop
                Write-Host "✅ Oppdatert $upn" -ForegroundColor Green
                $successCount++
            }
            
            $results += [PSCustomObject]@{
                User = $upn
                Status = "Success"
                NewDepartment = $Department
            }
            
        } catch {
            Write-Host "❌ Feilet for $upn : $_" -ForegroundColor Red
            $failureCount++
            
            $results += [PSCustomObject]@{
                User = $upn
                Status = "Failed"
                Error = $_.Exception.Message
            }
        }
    }
    
    # Vis sammendrag
    Write-Host ""
    Write-Host "=== Sammendrag ===" -ForegroundColor Cyan
    Write-Host "Vellykket: $successCount" -ForegroundColor Green
    Write-Host "Feilet: $failureCount" -ForegroundColor Red
    
    return $results
}

# Eksempel på bruk
# Connect-MgGraph -Scopes "User.ReadWrite.All"
# $rapport = Get-UserLicenseReport -UserPrincipalName "test@bedrift.no"
# $resultat = Set-BulkUserDepartment -UserPrincipalNames @("user1@bedrift.no", "user2@bedrift.no") -Department "IT" -WhatIf
```

---

## Import av datafiler

### 📖 Konsept
PowerShell kan lese data fra forskjellige filformater. CSV er mest vanlig for brukeradministrasjon, mens JSON brukes for konfigurasjon.

### 🔧 CSV-import

```powershell
# import-csv-basics.ps1
# Grunnleggende CSV-håndtering

# Opprett eksempel CSV-fil
$csvContent = @"
Fornavn,Etternavn,Email,Avdeling,Lokasjon
Ola,Nordmann,ola.nordmann@bedrift.no,IT,Oslo
Kari,Hansen,kari.hansen@bedrift.no,HR,Bergen
Per,Olsen,per.olsen@bedrift.no,Salg,Trondheim
Anne,Larsen,anne.larsen@bedrift.no,Økonomi,Oslo
"@

$csvContent | Out-File "brukere.csv" -Encoding UTF8

# Les CSV-fil
$brukere = Import-Csv "brukere.csv"

# Vis data
Write-Host "=== Importerte brukere ===" -ForegroundColor Cyan
$brukere | Format-Table

# Behandle hver rad
foreach ($bruker in $brukere) {
    Write-Host "Behandler: $($bruker.Fornavn) $($bruker.Etternavn) - $($bruker.Avdeling)" -ForegroundColor Yellow
}

# Filtrer og grupper data
$osloAnsatte = $brukere | Where-Object { $_.Lokasjon -eq "Oslo" }
Write-Host "`nAnsatte i Oslo: $($osloAnsatte.Count)" -ForegroundColor Cyan

$avdelingsGrupper = $brukere | Group-Object -Property Avdeling
Write-Host "`nAnsatte per avdeling:" -ForegroundColor Cyan
$avdelingsGrupper | ForEach-Object {
    Write-Host "  $($_.Name): $($_.Count) ansatte"
}
```

### 💡 EntraID-eksempel: Bulk-import av brukere

```powershell
# bulk-user-import.ps1
# Importer brukere fra CSV til EntraID

# CSV-format:
# Fornavn,Etternavn,Email,Avdeling,Stilling,Lokasjon,Telefon

function Import-UsersFromCSV {
    param(
        [Parameter(Mandatory=$true)]
        [string]$CsvPath,
        
        [switch]$TestMode
    )
    
    # Valider at filen eksisterer
    if (-not (Test-Path $CsvPath)) {
        Write-Error "CSV-fil ikke funnet: $CsvPath"
        return
    }
    
    # Importer data
    try {
        $users = Import-Csv $CsvPath -Encoding UTF8
        Write-Host "✅ Importerte $($users.Count) brukere fra CSV" -ForegroundColor Green
    } catch {
        Write-Error "Kunne ikke lese CSV: $_"
        return
    }
    
    # Valider kolonner
    $requiredColumns = @("Fornavn", "Etternavn", "Email", "Avdeling")
    $csvColumns = $users[0].PSObject.Properties.Name
    
    foreach ($col in $requiredColumns) {
        if ($col -notin $csvColumns) {
            Write-Error "Mangler påkrevd kolonne: $col"
            return
        }
    }
    
    # Prosesser brukere
    $results = @()
    $successCount = 0
    $errorCount = 0
    
    foreach ($user in $users) {
        $displayName = "$($user.Fornavn) $($user.Etternavn)"
        
        Write-Host "`nProsesserer: $displayName" -ForegroundColor Cyan
        
        # Valider e-post
        if ($user.Email -notmatch '^[\w\.-]+@[\w\.-]+\.\w+$') {
            Write-Host "❌ Ugyldig e-post: $($user.Email)" -ForegroundColor Red
            $errorCount++
            
            $results += [PSCustomObject]@{
                DisplayName = $displayName
                Email = $user.Email
                Status = "Failed"
                Error = "Invalid email format"
            }
            continue
        }
        
        if ($TestMode) {
            Write-Host "[TEST MODE] Ville opprettet:" -ForegroundColor Yellow
            Write-Host "  Navn: $displayName"
            Write-Host "  E-post: $($user.Email)"
            Write-Host "  Avdeling: $($user.Avdeling)"
            Write-Host "  Stilling: $($user.Stilling)"
            Write-Host "  Lokasjon: $($user.Lokasjon)"
            
            $results += [PSCustomObject]@{
                DisplayName = $displayName
                Email = $user.Email
                Status = "Test Success"
                Action = "Would create"
            }
            $successCount++
            
        } else {
            try {
                # Generer midlertidig passord
                $tempPassword = "Temp-$(Get-Random -Minimum 1000 -Maximum 9999)!"
                
                # Opprett bruker-parametere
                $userParams = @{
                    DisplayName = $displayName
                    GivenName = $user.Fornavn
                    Surname = $user.Etternavn
                    UserPrincipalName = $user.Email
                    MailNickname = $user.Email.Split('@')[0]
                    Department = $user.Avdeling
                    JobTitle = $user.Stilling
                    City = $user.Lokasjon
                    AccountEnabled = $true
                    PasswordProfile = @{
                        Password = $tempPassword
                        ForceChangePasswordNextSignIn = $true
                    }
                }
                
                # Legg til telefon hvis den finnes
                if ($user.Telefon) {
                    $userParams.MobilePhone = $user.Telefon
                }
                
                # Opprett bruker
                $newUser = New-MgUser @userParams -ErrorAction Stop
                
                Write-Host "✅ Bruker opprettet: $($newUser.UserPrincipalName)" -ForegroundColor Green
                Write-Host "   Midlertidig passord: $tempPassword" -ForegroundColor Yellow
                
                $results += [PSCustomObject]@{
                    DisplayName = $displayName
                    Email = $user.Email
                    Status = "Success"
                    UserId = $newUser.Id
                    TempPassword = $tempPassword
                }
                $successCount++
                
            } catch {
                Write-Host "❌ Feilet: $_" -ForegroundColor Red
                $errorCount++
                
                $results += [PSCustomObject]@{
                    DisplayName = $displayName
                    Email = $user.Email
                    Status = "Failed"
                    Error = $_.Exception.Message
                }
            }
        }
    }
    
    # Vis sammendrag
    Write-Host ""
    Write-Host "=== Import Sammendrag ===" -ForegroundColor Cyan
    Write-Host "Totalt prosessert: $($users.Count)" -ForegroundColor White
    Write-Host "Vellykket: $successCount" -ForegroundColor Green
    Write-Host "Feilet: $errorCount" -ForegroundColor Red
    
    # Eksporter resultater
    $resultatFil = "import-results-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
    $results | Export-Csv $resultatFil -NoTypeInformation -Encoding UTF8
    Write-Host "`nResultater lagret til: $resultatFil" -ForegroundColor Cyan
    
    return $results
}

# Test import (test mode)
# Import-UsersFromCSV -CsvPath "brukere.csv" -TestMode

# Faktisk import (krever Graph-tilkobling)
# Connect-MgGraph -Scopes "User.ReadWrite.All"
# Import-UsersFromCSV -CsvPath "brukere.csv"
# Disconnect-MgGraph
```

### 🔧 JSON-håndtering

```powershell
# json-config.ps1
# Bruk av JSON for konfigurasjon

# Opprett konfigurasjonsfil
$config = @{
    Organization = @{
        Name = "Bedrift AS"
        Domain = "bedrift.no"
    }
    DefaultSettings = @{
        Department = "Ikke tildelt"
        Location = "Oslo"
        LicenseType = "SPE_E3"
    }
    PasswordPolicy = @{
        MinLength = 12
        RequireComplexity = $true
        ForceChangeOnFirstLogin = $true
    }
    NotificationSettings = @{
        SendWelcomeEmail = $true
        AdminEmail = "admin@bedrift.no"
    }
}

# Lagre til JSON
$config | ConvertTo-Json -Depth 3 | Out-File "config.json" -Encoding UTF8

# Les konfigurasjon
$loadedConfig = Get-Content "config.json" -Raw | ConvertFrom-Json

# Bruk konfigurasjon
Write-Host "Organisasjon: $($loadedConfig.Organization.Name)" -ForegroundColor Cyan
Write-Host "Standard avdeling: $($loadedConfig.DefaultSettings.Department)"
Write-Host "Passord minimum lengde: $($loadedConfig.PasswordPolicy.MinLength)"
```

---

## Objektbehandling og pipelining

### 📖 Konsept
PowerShell er objektbasert - alt er objekter med egenskaper og metoder. Pipeline (`|`) lar deg sende objekter mellom kommandoer.

### 🔧 Pipeline grunnleggende

```powershell
# pipeline-basics.ps1
# Grunnleggende pipeline-operasjoner

# Enkel pipeline
Get-Process | Where-Object { $_.CPU -gt 10 } | Select-Object Name, CPU, Id

# Pipeline med flere trinn
$resultat = 1..100 | 
    Where-Object { $_ % 2 -eq 0 } |      # Kun partall
    ForEach-Object { $_ * 2 } |          # Doble verdien
    Where-Object { $_ -gt 50 } |         # Kun over 50
    Sort-Object -Descending |            # Sorter synkende
    Select-Object -First 10              # Ta de 10 første

Write-Host "Top 10 resultater: $($resultat -join ', ')"

# Gruppering og aggregering
$prosessGrupper = Get-Process | 
    Group-Object -Property ProcessName |
    Where-Object { $_.Count -gt 1 } |
    Sort-Object Count -Descending |
    Select-Object -First 5

Write-Host "`nTop 5 prosesser med flere instanser:"
$prosessGrupper | Format-Table Name, Count
```

### 💡 EntraID-eksempel: Avansert objektbehandling

```powershell
# advanced-object-handling.ps1
# Avansert objektbehandling med Graph-data

function Get-UserAnalytics {
    <#
    .SYNOPSIS
        Analyser brukere og generer statistikk
    #>
    
    Connect-MgGraph -Scopes "User.Read.All", "AuditLog.Read.All" -ErrorAction Stop
    
    try {
        # Hent alle brukere med relevante egenskaper
        Write-Host "Henter brukerdata..." -ForegroundColor Cyan
        $users = Get-MgUser -All -Property DisplayName,Department,City,Country,CreatedDateTime,AccountEnabled,SignInActivity
        
        # Pipeline-analyse
        Write-Host "`n=== Brukerstatistikk ===" -ForegroundColor Cyan
        
        # 1. Aktive vs inaktive
        $statusGruppe = $users | Group-Object -Property AccountEnabled
        $aktive = ($statusGruppe | Where-Object { $_.Name -eq "True" }).Count
        $inaktive = ($statusGruppe | Where-Object { $_.Name -eq "False" }).Count
        
        Write-Host "Totalt antall brukere: $($users.Count)" -ForegroundColor White
        Write-Host "  Aktive: $aktive" -ForegroundColor Green
        Write-Host "  Inaktive: $inaktive" -ForegroundColor Red
        
        # 2. Top 5 avdelinger
        Write-Host "`nTop 5 avdelinger:" -ForegroundColor Cyan
        $users | 
            Where-Object { $null -ne $_.Department -and $_.Department -ne "" } |
            Group-Object -Property Department |
            Sort-Object Count -Descending |
            Select-Object -First 5 |
            ForEach-Object {
                Write-Host "  $($_.Name): $($_.Count) brukere"
            }
        
        # 3. Geografisk distribusjon
        Write-Host "`nGeografisk distribusjon:" -ForegroundColor Cyan
        $users | 
            Where-Object { $null -ne $_.City } |
            Group-Object -Property City |
            Sort-Object Count -Descending |
            Select-Object -First 5 |
            ForEach-Object {
                Write-Host "  $($_.Name): $($_.Count) brukere"
            }
        
        # 4. Nylig opprettede brukere (siste 30 dager)
        $30DagerSiden = (Get-Date).AddDays(-30)
        $nyeBrukere = $users | 
            Where-Object { $_.CreatedDateTime -gt $30DagerSiden } |
            Sort-Object CreatedDateTime -Descending
        
        Write-Host "`nNye brukere siste 30 dager: $($nyeBrukere.Count)" -ForegroundColor Cyan
        if ($nyeBrukere.Count -gt 0) {
            $nyeBrukere | 
                Select-Object -First 5 |
                ForEach-Object {
                    Write-Host "  $($_.DisplayName) - opprettet $($_.CreatedDateTime.ToString('yyyy-MM-dd'))"
                }
        }
        
        # 5. Brukere uten avdeling
        $utenAvdeling = $users | 
            Where-Object { $null -eq $_.Department -or $_.Department -eq "" }
        
        if ($utenAvdeling.Count -gt 0) {
            Write-Host "`n⚠️ Brukere uten avdeling: $($utenAvdeling.Count)" -ForegroundColor Yellow
            
            $svar = Read-Host "Vil du se liste? (J/N)"
            if ($svar -eq "J") {
                $utenAvdeling | 
                    Select-Object DisplayName, UserPrincipalName |
                    Format-Table
            }
        }
        
        # 6. Lag rapport-objekt
        $rapport = [PSCustomObject]@{
            TotalUsers = $users.Count
            ActiveUsers = $aktive
            InactiveUsers = $inaktive
            NewUsersLast30Days = $nyeBrukere.Count
            UsersWithoutDepartment = $utenAvdeling.Count
            TopDepartments = $users | 
                Where-Object { $_.Department } |
                Group-Object -Property Department |
                Sort-Object Count -Descending |
                Select-Object -First 5 |
                ForEach-Object {
                    [PSCustomObject]@{
                        Department = $_.Name
                        Count = $_.Count
                    }
                }
            Timestamp = Get-Date
        }
        
        return $rapport
        
    } finally {
        Disconnect-MgGraph
    }
}

# Eksempel på avansert filtrering og transformasjon
function Find-InactiveUsers {
    param(
        [int]$DaysInactive = 90
    )
    
    Connect-MgGraph -Scopes "User.Read.All", "AuditLog.Read.All"
    
    $inactiveDate = (Get-Date).AddDays(-$DaysInactive)
    
    # Kompleks pipeline med flere transformasjoner
    $inactiveUsers = Get-MgUser -All -Property DisplayName,UserPrincipalName,SignInActivity,AccountEnabled |
        Where-Object { $_.AccountEnabled -eq $true } |  # Kun aktive kontoer
        Where-Object { 
            $null -eq $_.SignInActivity.LastSignInDateTime -or 
            $_.SignInActivity.LastSignInDateTime -lt $inactiveDate 
        } |
        Select-Object DisplayName, 
                     UserPrincipalName,
                     @{Name='LastSignIn'; Expression={$_.SignInActivity.LastSignInDateTime}},
                     @{Name='DaysInactive'; Expression={
                         if ($null -eq $_.SignInActivity.LastSignInDateTime) {
                             "Never"
                         } else {
                             ((Get-Date) - $_.SignInActivity.LastSignInDateTime).Days
                         }
                     }} |
        Sort-Object LastSignIn
    
    Write-Host "Fant $($inactiveUsers.Count) inaktive brukere (over $DaysInactive dager)" -ForegroundColor Yellow
    
    Disconnect-MgGraph
    
    return $inactiveUsers
}

# Kjør analyse
# $rapport = Get-UserAnalytics
# $inaktive = Find-InactiveUsers -DaysInactive 60
```

---

## Parametre og skript som verktøy

### 📖 Konsept
Parametre gjør skriptene dine fleksible og gjenbrukbare. Med riktig parameterdesign blir skriptet ditt et kraftig verktøy.

### 🔧 Avanserte parametere

```powershell
# parameter-validation.ps1
# Avansert parametervalidering og -håndtering

function Test-AdvancedParameters {
    [CmdletBinding()]
    param(
        # Obligatorisk parameter med validering
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        
        # Parameter med forhåndsdefinerte valg
        [Parameter(Position=1)]
        [ValidateSet("Development", "Test", "Production")]
        [string]$Environment = "Development",
        
        # Parameter med tallvalidering
        [Parameter()]
        [ValidateRange(1, 100)]
        [int]$Priority = 50,
        
        # Parameter med mønstervalidering
        [Parameter()]
        [ValidatePattern('^[\w\.-]+@[\w\.-]+\.\w+$')]
        [string]$Email,
        
        # Switch-parameter
        [switch]$Verbose,
        
        # Parameter som tar input fra pipeline
        [Parameter(ValueFromPipeline=$true)]
        [string[]]$InputObjects
    )
    
    process {
        if ($Verbose) {
            Write-Host "Prosesserer med følgende parametere:" -ForegroundColor Cyan
            Write-Host "  Name: $Name"
            Write-Host "  Environment: $Environment"
            Write-Host "  Priority: $Priority"
            if ($Email) { Write-Host "  Email: $Email" }
        }
        
        foreach ($obj in $InputObjects) {
            Write-Host "Behandler: $obj"
        }
    }
}

# Test funksjonen
Test-AdvancedParameters -Name "Test" -Environment "Production" -Priority 75 -Verbose
```

### 💡 Komplett brukeradministrasjonsverktøy

```powershell
# User-Management-Tool.ps1
# Komplett verktøy for brukeradministrasjon i Microsoft EntraID

<#
.SYNOPSIS
    Brukeradministrasjonsverktøy for Microsoft EntraID
    
.DESCRIPTION
    Dette scriptet gir et komplett sett med verktøy for å administrere
    brukere i Microsoft 365/EntraID miljøet.
    
.PARAMETER Action
    Hvilken handling som skal utføres
    
.PARAMETER UserPrincipalName
    E-postadressen til brukeren
    
.PARAMETER CsvFile
    Sti til CSV-fil for bulk-operasjoner
    
.PARAMETER Department
    Avdeling for bruker eller filtrering
    
.PARAMETER ExportPath
    Sti for eksport av rapporter
    
.PARAMETER WhatIf
    Kjør i test-modus uten å gjøre endringer
    
.EXAMPLE
    .\User-Management-Tool.ps1 -Action CreateUser -UserPrincipalName "ny@bedrift.no"
    
.EXAMPLE
    .\User-Management-Tool.ps1 -Action BulkImport -CsvFile "users.csv" -WhatIf
    
.EXAMPLE
    .\User-Management-Tool.ps1 -Action GenerateReport -Department "IT" -ExportPath "C:\Reports"
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

# Hjelpefunksjoner
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "Info"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp [$Level] $Message"
    
    switch ($Level) {
        "Error" { Write-Host $logMessage -ForegroundColor Red }
        "Warning" { Write-Host $logMessage -ForegroundColor Yellow }
        "Success" { Write-Host $logMessage -ForegroundColor Green }
        default { Write-Host $logMessage -ForegroundColor White }
    }
    
    # Logg til fil
    $logFile = Join-Path $ExportPath "user-management-$(Get-Date -Format 'yyyyMMdd').log"
    Add-Content -Path $logFile -Value $logMessage -ErrorAction SilentlyContinue
}

function Connect-GraphIfNeeded {
    $context = Get-MgContext -ErrorAction SilentlyContinue
    if ($null -eq $context) {
        Write-Log "Kobler til Microsoft Graph..." "Info"
        try {
            Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All" -ErrorAction Stop
            Write-Log "Tilkoblet Microsoft Graph" "Success"
        } catch {
            Write-Log "Kunne ikke koble til Graph: $_" "Error"
            exit 1
        }
    }
}

function New-UserAccount {
    param(
        [string]$UserPrincipalName,
        [string]$DisplayName,
        [string]$Department
    )
    
    if ($WhatIf) {
        Write-Log "[WhatIf] Ville opprettet bruker: $UserPrincipalName" "Warning"
        return
    }
    
    try {
        # Generer sikker passord
        $password = "Welcome-$(Get-Random -Minimum 1000 -Maximum 9999)!"
        
        $userParams = @{
            UserPrincipalName = $UserPrincipalName
            DisplayName = $DisplayName
            MailNickname = $UserPrincipalName.Split('@')[0]
            Department = $Department
            AccountEnabled = $true
            PasswordProfile = @{
                Password = $password
                ForceChangePasswordNextSignIn = $true
            }
        }
        
        $newUser = New-MgUser @userParams -ErrorAction Stop
        Write-Log "Bruker opprettet: $UserPrincipalName (Temp passord: $password)" "Success"
        
        return @{
            Success = $true
            UserId = $newUser.Id
            Password = $password
        }
        
    } catch {
        Write-Log "Feil ved opprettelse av $UserPrincipalName : $_" "Error"
        return @{ Success = $false; Error = $_.Exception.Message }
    }
}

function Disable-UserAccount {
    param([string]$UserPrincipalName)
    
    if ($WhatIf) {
        Write-Log "[WhatIf] Ville deaktivert: $UserPrincipalName" "Warning"
        return
    }
    
    try {
        Update-MgUser -UserId $UserPrincipalName -AccountEnabled:$false -ErrorAction Stop
        Write-Log "Bruker deaktivert: $UserPrincipalName" "Success"
    } catch {
        Write-Log "Kunne ikke deaktivere $UserPrincipalName : $_" "Error"
    }
}

function Get-InactiveUsersReport {
    param([int]$DaysInactive = 90)
    
    Write-Log "Genererer rapport for inaktive brukere (>$DaysInactive dager)" "Info"
    
    $inactiveDate = (Get-Date).AddDays(-$DaysInactive)
    
    $users = Get-MgUser -All -Property DisplayName,UserPrincipalName,SignInActivity,AccountEnabled |
        Where-Object { $_.AccountEnabled -eq $true } |
        Where-Object { 
            $null -eq $_.SignInActivity.LastSignInDateTime -or 
            $_.SignInActivity.LastSignInDateTime -lt $inactiveDate 
        }
    
    $report = $users | Select-Object DisplayName, UserPrincipalName,
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
                ((Get-Date) - $_.SignInActivity.LastSignInDateTime).Days
            }
        }}
    
    # Eksporter rapport
    $reportFile = Join-Path $ExportPath "inactive-users-$(Get-Date -Format 'yyyyMMdd').csv"
    $report | Export-Csv $reportFile -NoTypeInformation -Encoding UTF8
    
    Write-Log "Fant $($users.Count) inaktive brukere" "Warning"
    Write-Log "Rapport lagret: $reportFile" "Success"
    
    return $report
}

# Hovedlogikk
Write-Log "=== User Management Tool Started ===" "Info"
Write-Log "Action: $Action" "Info"

# Sjekk/opprett rapport-mappe
if (-not (Test-Path $ExportPath)) {
    New-Item -Path $ExportPath -ItemType Directory -Force | Out-Null
}

# Koble til Graph hvis nødvendig
if ($Action -ne "Help") {
    Connect-GraphIfNeeded
}

# Utfør handling
switch ($Action) {
    "CreateUser" {
        if (-not $UserPrincipalName) {
            Write-Log "UserPrincipalName er påkrevd for CreateUser" "Error"
            exit 1
        }
        
        $displayName = Read-Host "Skriv inn fullt navn"
        $dept = if ($Department) { $Department } else { Read-Host "Skriv inn avdeling" }
        
        $result = New-UserAccount -UserPrincipalName $UserPrincipalName -DisplayName $displayName -Department $dept
        
        if ($result.Success) {
            Write-Log "Bruker opprettet med ID: $($result.UserId)" "Success"
            Write-Log "Midlertidig passord: $($result.Password)" "Warning"
        }
    }
    
    "DisableUser" {
        if (-not $UserPrincipalName) {
            Write-Log "UserPrincipalName er påkrevd for DisableUser" "Error"
            exit 1
        }
        
        Disable-UserAccount -UserPrincipalName $UserPrincipalName
    }
    
    "EnableUser" {
        if (-not $UserPrincipalName) {
            Write-Log "UserPrincipalName er påkrevd for EnableUser" "Error"
            exit 1
        }
        
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
    
    "BulkImport" {
        if (-not $CsvFile -or -not (Test-Path $CsvFile)) {
            Write-Log "Gyldig CSV-fil er påkrevd for BulkImport" "Error"
            exit 1
        }
        
        Write-Log "Starter bulk-import fra: $CsvFile" "Info"
        
        $users = Import-Csv $CsvFile -Encoding UTF8
        $successCount = 0
        $errorCount = 0
        
        foreach ($user in $users) {
            if ($WhatIf) {
                Write-Log "[WhatIf] Ville opprettet: $($user.Email)" "Warning"
                $successCount++
            } else {
                $result = New-UserAccount -UserPrincipalName $user.Email `
                                         -DisplayName "$($user.Fornavn) $($user.Etternavn)" `
                                         -Department $user.Avdeling
                
                if ($result.Success) {
                    $successCount++
                } else {
                    $errorCount++
                }
            }
        }
        
        Write-Log "Import fullført - Success: $successCount, Errors: $errorCount" "Info"
    }
    
    "GenerateReport" {
        Write-Log "Genererer brukerrapport..." "Info"
        
        $filter = if ($Department) { 
            "department eq '$Department'"
        } else {
            $null
        }
        
        $users = if ($filter) {
            Get-MgUser -Filter $filter -All
        } else {
            Get-MgUser -All
        }
        
        $report = $users | Select-Object DisplayName, UserPrincipalName, Department, JobTitle, City, AccountEnabled
        
        $reportFile = Join-Path $ExportPath "user-report-$(Get-Date -Format 'yyyyMMdd-HHmmss').csv"
        $report | Export-Csv $reportFile -NoTypeInformation -Encoding UTF8
        
        Write-Log "Rapport generert med $($users.Count) brukere" "Success"
        Write-Log "Fil: $reportFile" "Info"
    }
    
    "FindInactive" {
        $report = Get-InactiveUsersReport -DaysInactive 90
        $report | Select-Object -First 10 | Format-Table
    }
    
    "UpdateDepartment" {
        if (-not $UserPrincipalName -or -not $Department) {
            Write-Log "Både UserPrincipalName og Department er påkrevd" "Error"
            exit 1
        }
        
        if ($WhatIf) {
            Write-Log "[WhatIf] Ville oppdatert $UserPrincipalName til avdeling: $Department" "Warning"
        } else {
            try {
                Update-MgUser -UserId $UserPrincipalName -Department $Department -ErrorAction Stop
                Write-Log "Avdeling oppdatert for $UserPrincipalName : $Department" "Success"
            } catch {
                Write-Log "Kunne ikke oppdatere avdeling: $_" "Error"
            }
        }
    }
}

# Cleanup
if ($Action -ne "Help") {
    Disconnect-MgGraph
    Write-Log "Frakoblet Microsoft Graph" "Info"
}

Write-Log "=== User Management Tool Completed ===" "Info"
```

---

## Komplett eksempel: Brukeradministrasjonsverktøy

Her er et eksempel på hvordan alle konseptene kommer sammen i et praktisk verktøy:

```powershell
# Complete-User-Lifecycle.ps1
# Komplett brukerlivssyklus-håndtering

# Konfigurasjonsfil (config.json)
$defaultConfig = @{
    Organization = @{
        Domain = "bedrift.no"
        DefaultPassword = "Welcome2Company!"
    }
    Licenses = @{
        Standard = "SPE_E3"
        Frontline = "SPE_F1"
    }
    Notifications = @{
        WelcomeEmailTemplate = "welcome-template.html"
        ITNotificationEmail = "it@bedrift.no"
    }
}

class UserManager {
    [string]$LogPath
    [hashtable]$Config
    [bool]$Connected
    
    UserManager([string]$configPath) {
        $this.LogPath = ".\Logs\$(Get-Date -Format 'yyyyMMdd')-usermanager.log"
        $this.LoadConfig($configPath)
        $this.Connected = $false
    }
    
    [void]LoadConfig([string]$path) {
        if (Test-Path $path) {
            $this.Config = Get-Content $path -Raw | ConvertFrom-Json -AsHashtable
        } else {
            $this.Config = $script:defaultConfig
        }
    }
    
    [void]Connect() {
        if (-not $this.Connected) {
            Connect-MgGraph -Scopes "User.ReadWrite.All", "Group.ReadWrite.All"
            $this.Connected = $true
            $this.Log("Connected to Microsoft Graph", "Info")
        }
    }
    
    [void]Disconnect() {
        if ($this.Connected) {
            Disconnect-MgGraph
            $this.Connected = $false
            $this.Log("Disconnected from Microsoft Graph", "Info")
        }
    }
    
    [void]Log([string]$message, [string]$level) {
        $entry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') [$level] $message"
        Add-Content -Path $this.LogPath -Value $entry
        
        switch ($level) {
            "Error" { Write-Host $entry -ForegroundColor Red }
            "Warning" { Write-Host $entry -ForegroundColor Yellow }
            "Success" { Write-Host $entry -ForegroundColor Green }
            default { Write-Host $entry }
        }
    }
    
    [hashtable]CreateUser([hashtable]$userInfo) {
        $this.Connect()
        
        try {
            $user = New-MgUser @userInfo -ErrorAction Stop
            $this.Log("Created user: $($user.UserPrincipalName)", "Success")
            
            return @{
                Success = $true
                UserId = $user.Id
                UserPrincipalName = $user.UserPrincipalName
            }
        } catch {
            $this.Log("Failed to create user: $_", "Error")
            return @{
                Success = $false
                Error = $_.Exception.Message
            }
        }
    }
    
    [void]ProcessNewStarters([string]$csvPath) {
        $this.Connect()
        
        $newStarters = Import-Csv $csvPath
        $results = @()
        
        foreach ($starter in $newStarters) {
            $this.Log("Processing new starter: $($starter.Email)", "Info")
            
            # Opprett bruker
            $userInfo = @{
                DisplayName = "$($starter.FirstName) $($starter.LastName)"
                UserPrincipalName = $starter.Email
                GivenName = $starter.FirstName
                Surname = $starter.LastName
                Department = $starter.Department
                JobTitle = $starter.JobTitle
                PasswordProfile = @{
                    Password = $this.Config.Organization.DefaultPassword
                    ForceChangePasswordNextSignIn = $true
                }
                AccountEnabled = $true
            }
            
            $result = $this.CreateUser($userInfo)
            
            if ($result.Success) {
                # Tildel lisens
                $this.AssignLicense($result.UserId, $starter.LicenseType)
                
                # Legg til i grupper
                if ($starter.Groups) {
                    $groups = $starter.Groups -split ';'
                    foreach ($group in $groups) {
                        $this.AddToGroup($result.UserId, $group.Trim())
                    }
                }
                
                # Send velkomst-e-post
                $this.SendWelcomeEmail($starter.Email)
            }
            
            $results += $result
        }
        
        # Generer rapport
        $this.GenerateOnboardingReport($results)
    }
    
    [void]AssignLicense([string]$userId, [string]$licenseType) {
        # Implementer lisenstildeling
        $this.Log("Assigned $licenseType license to user $userId", "Info")
    }
    
    [void]AddToGroup([string]$userId, [string]$groupName) {
        # Implementer gruppe-tillegg
        $this.Log("Added user $userId to group $groupName", "Info")
    }
    
    [void]SendWelcomeEmail([string]$email) {
        # Implementer e-postutsending
        $this.Log("Sent welcome email to $email", "Info")
    }
    
    [void]GenerateOnboardingReport([array]$results) {
        $reportPath = ".\Reports\onboarding-$(Get-Date -Format 'yyyyMMdd').csv"
        $results | Export-Csv $reportPath -NoTypeInformation
        $this.Log("Generated onboarding report: $reportPath", "Success")
    }
}

# Bruk av klassen
$userManager = [UserManager]::new(".\config.json")
$userManager.ProcessNewStarters(".\new-starters.csv")
$userManager.Disconnect()
```

---

## 📚 Neste steg og øvelser

### Øvelse 1: Grunnleggende
Lag et skript som:
1. Kobler til Microsoft Graph
2. Henter alle brukere i en spesifikk avdeling
3. Eksporterer listen til CSV

### Øvelse 2: Middels
Utvid skriptet til å:
1. Sjekke om brukerne har lisens
2. Markere brukere som mangler lisens
3. Generere en rapport med statistikk

### Øvelse 3: Avansert
Lag et komplett verktøy som:
1. Leser brukere fra CSV
2. Oppretter nye brukere med feilhåndtering
3. Tildeler lisenser basert på avdeling
4. Sender rapport på e-post

### Øvelse 4: Ekspert
Implementer en full brukerlivssyklus:
1. Onboarding med automatisk oppsett
2. Periodisk gjennomgang av inaktive
3. Offboarding med arkivering
4. Compliance-rapportering

---

## 🎯 Tips for videre læring

1. **Praksis**: Lag et test-miljø og eksperimenter
2. **Dokumentasjon**: Les Microsoft Graph PowerShell SDK-dokumentasjonen
3. **Community**: Del kode og lær av andre i PowerShell-samfunnet
4. **Automasjon**: Identifiser repetitive oppgaver og automatiser dem
5. **Sikkerhet**: Alltid test i test-miljø først, bruk -WhatIf

---

*Sist oppdatert: Oktober 2025*  
*Versjon: 1.0*