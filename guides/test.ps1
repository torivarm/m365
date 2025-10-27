function Get-BrukerInfo {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Epost
    )
    
    try {
        $bruker = Get-MgUser -UserId $Epost -Property DisplayName,UserPrincipalName,JobTitle,Department,AccountEnabled
        
        Write-Host "=== Brukerinformasjon ==="
        Write-Host "Navn: $($bruker.DisplayName)"
        Write-Host "E-post: $($bruker.UserPrincipalName)"
        Write-Host "Jobbtittel: $($bruker.JobTitle)"
        Write-Host "Avdeling: $($bruker.Department)"
        Write-Host "Konto aktiv: $($bruker.AccountEnabled)"
    }
    catch {
        Write-Host "❌ Kunne ikke hente bruker: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Bruk funksjonen
Connect-MgGraph -Scopes "User.Read.All"
Get-BrukerInfo -Epost "me"