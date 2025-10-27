$bruker = Get-MgUser -UserId "ivar.martinsen@NTNU961.onmicrosoft.com" -Property AccountEnabled,DisplayName,UserPrincipalName
if ($bruker.AccountEnabled -eq $true) {
    Write-Host "✅ Kontoen er aktiv" -ForegroundColor Green
}
else {
    Write-Host "❌ Kontoen er deaktivert" -ForegroundColor Red
}