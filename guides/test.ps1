function Test-BrukerStatus {
    param(
        [string]$UserPrincipalName
    )
    
    $bruker = Get-MgUser -Filter "userPrincipalName eq '$UserPrincipalName'" -Property DisplayName,AccountEnabled,LastPasswordChangeDateTime,SignInActivity
    
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
Test-BrukerStatus -UserPrincipalName "kjetil.riis@NTNU961.onmicrosoft.com"