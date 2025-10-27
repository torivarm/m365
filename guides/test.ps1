# Vis medlemmer i en gruppe
Connect-MgGraph -Scopes "Group.Read.All", "GroupMember.Read.All"

# Hent alle grupper
$grupper = Get-MgGroup -Top 10

Write-Host "=== TILGJENGELIGE GRUPPER ===" -ForegroundColor Cyan
for ($i = 0; $i -lt $grupper.Count; $i++) {
    Write-Host "$($i+1). $($grupper[$i].DisplayName)"
}

$valg = Read-Host "`nVelg gruppe (nummer)"

if ($valg -match '^\d+$' -and [int]$valg -le $grupper.Count -and [int]$valg -gt 0) {
    $gruppe = $grupper[[int]$valg - 1]
    
    Write-Host "`n=== $($gruppe.DisplayName) ===" -ForegroundColor Green
    
    try {
        $medlemmer = Get-MgGroupMember -GroupId $gruppe.Id
        
        if ($medlemmer) {
            Write-Host "Medlemmer ($($medlemmer.Count)):"
            foreach ($medlem in $medlemmer) {
                $bruker = Get-MgUser -UserId $medlem.Id
                Write-Host "  👤 $($bruker.DisplayName) - $($bruker.UserPrincipalName)"
            }
        }
        else {
            Write-Host "Ingen medlemmer i gruppen"
        }
    }
    catch {
        Write-Host "Kunne ikke hente medlemmer: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Disconnect-MgGraph