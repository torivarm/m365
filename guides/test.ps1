# Hent alle brukere (eller bruk -Top for testing)
$brukere = Get-MgUser -Top 50 -Property Department,UserPrincipalName

# Opprett en hashtable for telling
$avdelinger = @{}

# Tell brukere per avdeling
foreach ($bruker in $brukere) {
    if ($bruker.Department) {
        if ($avdelinger.ContainsKey($bruker.Department)) {
            $avdelinger[$bruker.Department]++
        }
        else {
            $avdelinger[$bruker.Department] = 1
        }
    }
}

# Vis resultatet
Write-Host "`n=== Brukere per avdeling ==="
foreach ($avdeling in $avdelinger.Keys) {
    Write-Host "$avdeling : $($avdelinger[$avdeling]) bruker(e)"
}