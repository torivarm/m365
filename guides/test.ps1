function Get-GruppeInfo {
    param(
        [Parameter(Mandatory=$true)]
        [string]$GruppeNavn,
        
        [switch]$VisMedlemmer
    )
    
    # Finn gruppe
    $gruppe = Get-MgGroup -Filter "displayName eq '$GruppeNavn'"
    
    if (-not $gruppe) {
        Write-Host "Fant ikke gruppe: $GruppeNavn" -ForegroundColor Red
        return
    }
    
    Write-Host "Gruppe: $($gruppe.DisplayName)"
    Write-Host "Beskrivelse: $($gruppe.Description)"
    
    if ($VisMedlemmer) {
        Write-Host "`nMedlemmer:"
        $medlemmer = Get-MgGroupMember -GroupId $gruppe.Id
        foreach ($medlem in $medlemmer) {
            $bruker = Get-MgUser -UserId $medlem.Id
            Write-Host "  - $($bruker.DisplayName)"
        }
    }
}

# Bruk funksjonen
Connect-MgGraph -Scopes "Group.Read.All", "GroupMember.Read.All"
# 
Get-GruppeInfo -GruppeNavn "IT-team" -VisMedlemmer