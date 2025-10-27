# Koble til
Connect-MgGraph -Scopes "User.Read.All"

# Hent en spesifikk bruker (bruk din egen e-post)
$bruker = Get-MgUser -UserId "ivar.martinsen@NTNU961.onmicrosoft.com"

# Vis informasjon
Write-Host "Navn: $($bruker.DisplayName)"
Write-Host "E-post: $($bruker.UserPrincipalName)"
Write-Host "Jobb: $($bruker.JobTitle)"