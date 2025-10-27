Connect-MgGraph -Scopes "User.Read.All"

# Hent bruker og lagre i variabel
$minBruker = Get-MgUser -UserId "ivar.martinsen@NTNU961.onmicrosoft.com" -Property UserPrincipalName,Department,DisplayName,JobTitle 

# Bruk variabelen senere
$navn = $minBruker.DisplayName
$epost = $minBruker.UserPrincipalName
$avdeling = $minBruker.Department

Write-Host "=== Min informasjon ==="
Write-Host "Navn: $navn"
Write-Host "E-post: $epost"
Write-Host "Avdeling: $avdeling"