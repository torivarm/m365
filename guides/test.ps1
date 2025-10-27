# Komplett eksempel som kombinerer flere teknikker
function Get-BrukerStatistikk {
    param(
        [int]$AntallBrukere = 50
    )
    
    try {
        # Sjekk tilkobling
        if (-not (Get-MgContext)) {
            throw "Du må koble til Graph først"
        }
        
        Write-Host "Henter $AntallBrukere brukere..." -ForegroundColor Cyan
        $brukere = Get-MgUser -Top $AntallBrukere -Property DisplayName,UserPrincipalName,AssignedLicenses,JobTitle,Department,AccountEnabled
        
        # Variabler for statistikk
        $stats = @{
            Totalt = $brukere.Count
            Aktive = 0
            MedJobbtittel = 0
            MedAvdeling = 0
            Avdelinger = @{}
        }
        
        # Analyser brukere med løkke
        foreach ($bruker in $brukere) {
            # If/else for status
            if ($bruker.AccountEnabled) {
                $stats.Aktive++
            }
            
            if ($bruker.JobTitle) {
                $stats.MedJobbtittel++
            }
            
            if ($bruker.Department) {
                $stats.MedAvdeling++
                
                # Tell per avdeling
                if ($stats.Avdelinger.ContainsKey($bruker.Department)) {
                    $stats.Avdelinger[$bruker.Department]++
                }
                else {
                    $stats.Avdelinger[$bruker.Department] = 1
                }
            }
        }
        
        # Vis resultat
        Write-Host "`n=== STATISTIKK ===" -ForegroundColor Green
        Write-Host "Totalt brukere: $($stats.Totalt)"
        Write-Host "Aktive: $($stats.Aktive)"
        Write-Host "Med jobbtittel: $($stats.MedJobbtittel)"
        Write-Host "Med avdeling: $($stats.MedAvdeling)"
        
        Write-Host "`n=== AVDELINGER ===" -ForegroundColor Cyan
        foreach ($avdeling in $stats.Avdelinger.Keys | Sort-Object) {
            Write-Host "$avdeling : $($stats.Avdelinger[$avdeling]) bruker(e)"
        }
        
        return $stats
    }
    catch {
        Write-Host "Feil: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Bruk
Connect-MgGraph -Scopes "User.Read.All"
$resultat = Get-BrukerStatistikk -AntallBrukere 100
Disconnect-MgGraph