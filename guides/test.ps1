# Enkel lisensoversikt
Connect-MgGraph -Scopes "User.Read.All"

Write-Host "=== LISENS STATUS ===" -ForegroundColor Cyan

$brukere = Get-MgUser -Top 20 -Property DisplayName,UserPrincipalName,AssignedLicenses

$medLisens = 0
$utenLisens = 0

foreach ($bruker in $brukere) {
    if ($bruker.AssignedLicenses.Count -gt 0) {
        $medLisens++
    }
    else {
        $utenLisens++
        Write-Host "⚠️  $($bruker.DisplayName) - Ingen lisens" -ForegroundColor Yellow
    }
}

Write-Host "`nOppsummering:"
Write-Host "Med lisens: $medLisens" -ForegroundColor Green
Write-Host "Uten lisens: $utenLisens" -ForegroundColor Red

Disconnect-MgGraph