# Lag en enkel rapport over brukere
Connect-MgGraph -Scopes "User.Read.All"

Write-Host "=== BRUKERRAPPORT ===" -ForegroundColor Cyan
Write-Host "Generert: $(Get-Date -Format 'dd.MM.yyyy HH:mm')`n"

# Hent brukere
$brukere = Get-MgUser -Top 20 -Property UserPrincipalName,DisplayName,AccountEnabled,Department

# Statistikk
$totalt = $brukere.Count
$aktive = ($brukere | Where-Object {$_.AccountEnabled -eq $true}).Count
$inaktive = $totalt - $aktive

Write-Host "Total brukere: $totalt"
Write-Host "Aktive: $aktive" -ForegroundColor Green
Write-Host "Inaktive: $inaktive" -ForegroundColor Red

# Vis brukere uten avdeling
$utenAvdeling = $brukere | Where-Object {-not $_.Department}
if ($utenAvdeling) {
    Write-Host "`n⚠️  $($utenAvdeling.Count) brukere mangler avdeling:" -ForegroundColor Yellow
    foreach ($bruker in $utenAvdeling) {
        Write-Host "  - $($bruker.DisplayName)"
    }
}

Disconnect-MgGraph