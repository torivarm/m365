# check-modules.ps1
# Script for å sjekke og oppdatere Microsoft 365 PowerShell-moduler
# 
# Kjør dette scriptet månedlig for å holde modulene oppdaterte

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Microsoft 365 PowerShell Module Checker" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Sjekker for modul-oppdateringer..." -ForegroundColor Yellow
Write-Host ""

# Definer modulene vi skal sjekke
$modules = @(
    @{Name = "Microsoft.Graph"; Description = "Microsoft Graph PowerShell SDK"},
    @{Name = "ExchangeOnlineManagement"; Description = "Exchange Online Management"},
    @{Name = "MicrosoftTeams"; Description = "Microsoft Teams PowerShell"},
    @{Name = "PnP.PowerShell"; Description = "PnP PowerShell (SharePoint/Teams)"},
    @{Name = "Az"; Description = "Azure PowerShell"}
)

# Sjekk om vi kjører som administrator (Windows)
$isAdmin = $false
if ($IsWindows) {
    $currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if ($isAdmin) {
    Write-Host "🔐 Kjører med administratorrettigheter" -ForegroundColor Green
} else {
    Write-Host "ℹ️ Kjører som vanlig bruker (CurrentUser scope)" -ForegroundColor Cyan
}
Write-Host ""

# Lagre resultater
$results = @()

foreach ($module in $modules) {
    Write-Host "Sjekker: $($module.Description)" -ForegroundColor Cyan
    Write-Host "Modulnavn: $($module.Name)" -ForegroundColor Gray
    
    # Sjekk om modulen er installert
    $installed = Get-Module -Name $module.Name -ListAvailable | 
                 Sort-Object Version -Descending | 
                 Select-Object -First 1
    
    if ($installed) {
        Write-Host "  Installert versjon: $($installed.Version)" -ForegroundColor White
        
        # Sjekk om det finnes nyere versjon online
        try {
            $online = Find-Module -Name $module.Name -ErrorAction Stop
            
            if ($online.Version -gt $installed.Version) {
                Write-Host "  ⚠️ Ny versjon tilgjengelig: $($online.Version)" -ForegroundColor Yellow
                
                $result = [PSCustomObject]@{
                    Module = $module.Name
                    Description = $module.Description
                    CurrentVersion = $installed.Version
                    AvailableVersion = $online.Version
                    Status = "Utdatert"
                    CanUpdate = $true
                }
                
                # Tilby oppdatering
                $answer = Read-Host "  Ønsker du å oppdatere nå? (J/N)"
                if ($answer -eq "J" -or $answer -eq "j") {
                    try {
                        Write-Host "  Oppdaterer..." -ForegroundColor Yellow
                        if ($isAdmin) {
                            Update-Module -Name $module.Name -Force
                        } else {
                            Update-Module -Name $module.Name -Scope CurrentUser -Force
                        }
                        Write-Host "  ✅ Oppdatert til versjon $($online.Version)!" -ForegroundColor Green
                        $result.Status = "Oppdatert"
                    } catch {
                        Write-Host "  ❌ Oppdatering feilet: $_" -ForegroundColor Red
                        $result.Status = "Oppdatering feilet"
                    }
                }
            } else {
                Write-Host "  ✅ Modulen er oppdatert" -ForegroundColor Green
                $result = [PSCustomObject]@{
                    Module = $module.Name
                    Description = $module.Description
                    CurrentVersion = $installed.Version
                    AvailableVersion = $installed.Version
                    Status = "Oppdatert"
                    CanUpdate = $false
                }
            }
        } catch {
            Write-Host "  ⚠️ Kunne ikke sjekke online versjon: $_" -ForegroundColor Yellow
            $result = [PSCustomObject]@{
                Module = $module.Name
                Description = $module.Description
                CurrentVersion = $installed.Version
                AvailableVersion = "Ukjent"
                Status = "Kunne ikke sjekke"
                CanUpdate = $false
            }
        }
    } else {
        Write-Host "  ❌ Ikke installert" -ForegroundColor Red
        
        $result = [PSCustomObject]@{
            Module = $module.Name
            Description = $module.Description
            CurrentVersion = "Ikke installert"
            AvailableVersion = "N/A"
            Status = "Ikke installert"
            CanUpdate = $false
        }
        
        # Tilby installasjon
        $answer = Read-Host "  Ønsker du å installere modulen? (J/N)"
        if ($answer -eq "J" -or $answer -eq "j") {
            try {
                Write-Host "  Installerer..." -ForegroundColor Yellow
                if ($isAdmin) {
                    Install-Module -Name $module.Name -Force -AllowClobber
                } else {
                    Install-Module -Name $module.Name -Scope CurrentUser -Force -AllowClobber
                }
                $newModule = Get-Module -Name $module.Name -ListAvailable | Select-Object -First 1
                Write-Host "  ✅ Installert versjon $($newModule.Version)!" -ForegroundColor Green
                $result.Status = "Nylig installert"
                $result.CurrentVersion = $newModule.Version
            } catch {
                Write-Host "  ❌ Installasjon feilet: $_" -ForegroundColor Red
                $result.Status = "Installasjon feilet"
            }
        }
    }
    
    $results += $result
    Write-Host ""
}

# Vis sammendrag
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Sammendrag" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$results | Format-Table -AutoSize

# Sjekk duplikater
Write-Host "Sjekker for duplikate modulversjoner..." -ForegroundColor Yellow
foreach ($module in $modules) {
    $versions = Get-Module -Name $module.Name -ListAvailable
    if ($versions.Count -gt 1) {
        Write-Host "⚠️ $($module.Name) har $($versions.Count) versjoner installert:" -ForegroundColor Yellow
        $versions | Select-Object Version, Path | Format-Table
        
        $answer = Read-Host "Ønsker du å fjerne gamle versjoner? (J/N)"
        if ($answer -eq "J" -or $answer -eq "j") {
            $latestVersion = $versions | Sort-Object Version -Descending | Select-Object -First 1
            $oldVersions = $versions | Where-Object { $_.Version -ne $latestVersion.Version }
            
            foreach ($old in $oldVersions) {
                try {
                    Write-Host "  Fjerner versjon $($old.Version)..." -ForegroundColor Yellow
                    Uninstall-Module -Name $module.Name -RequiredVersion $old.Version -Force
                    Write-Host "  ✅ Fjernet!" -ForegroundColor Green
                } catch {
                    Write-Host "  ❌ Kunne ikke fjerne: $_" -ForegroundColor Red
                }
            }
        }
    }
}

# PowerShellGet sjekk
Write-Host ""
Write-Host "Sjekker PowerShellGet..." -ForegroundColor Yellow
$psGet = Get-Module -Name PowerShellGet -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1
Write-Host "PowerShellGet versjon: $($psGet.Version)" -ForegroundColor White

$psGetOnline = Find-Module -Name PowerShellGet
if ($psGetOnline.Version -gt $psGet.Version) {
    Write-Host "⚠️ Ny versjon av PowerShellGet tilgjengelig: $($psGetOnline.Version)" -ForegroundColor Yellow
    Write-Host "Anbefaler å oppdatere: Update-Module -Name PowerShellGet" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "✅ Sjekk fullført!" -ForegroundColor Green
Write-Host ""
Write-Host "Tips:" -ForegroundColor Cyan
Write-Host "- Kjør dette scriptet månedlig for å holde modulene oppdaterte" -ForegroundColor White
Write-Host "- Bruk 'Get-Module -Name <ModulNavn> -ListAvailable' for å se installerte versjoner" -ForegroundColor White
Write-Host "- Bruk 'Get-Command -Module <ModulNavn>' for å se tilgjengelige kommandoer" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan