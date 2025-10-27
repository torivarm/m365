# Vis tilkoblingsinfo
$connection = Get-ConnectionInformation
Write-Host "`n📊 Tilkoblingsdetaljer:" -ForegroundColor Yellow
Write-Host "   Tilkoblet til: $($connection.ConnectionUri)"
Write-Host "   Token utløper: $($connection.TokenExpiryTimeUTC)"