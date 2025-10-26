# test-teams-connection.ps1
# Test-script for Microsoft Teams PowerShell-tilkobling
# 
# Kjør dette scriptet for å verifisere at Microsoft Teams-modulen 
# er installert og at du kan koble til Microsoft Teams

Write-Host "=================================" -ForegroundColor Cyan
Write-Host "Microsoft Teams Connection Test" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Sjekk om modulen er installert
Write-Host "Sjekker om MicrosoftTeams er installert..." -ForegroundColor Yellow
$module = Get-Module -Name MicrosoftTeams -ListAvailable

if (-not $module) {
    Write-Host "❌ MicrosoftTeams er ikke installert!" -ForegroundColor Red
    Write-Host "Kjør: Install-Module -Name MicrosoftTeams -Scope CurrentUser" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ MicrosoftTeams versjon $($module.Version) er installert" -ForegroundColor Green
Write-Host ""

# Koble til
Write-Host "Kobler til Microsoft Teams..." -ForegroundColor Yellow
Write-Host "Du vil bli bedt om å logge inn i nettleseren" -ForegroundColor Cyan

try {
    $connection = Connect-MicrosoftTeams
    Write-Host "✅ Tilkobling vellykket!" -ForegroundColor Green
    Write-Host "   Tenant ID: $($connection.TenantId)" -ForegroundColor White
    Write-Host "   Konto: $($connection.Account)" -ForegroundColor White
} catch {
    Write-Host "❌ Kunne ikke koble til: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "Tester Teams-tilgang" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Hent tenant-informasjon
try {
    Write-Host "🏢 Henter tenant-informasjon..." -ForegroundColor Yellow
    $tenant = Get-CsTenant -ErrorAction Stop
    
    Write-Host "✅ Tenant-detaljer:" -ForegroundColor Green
    Write-Host "   Navn: $($tenant.DisplayName)" -ForegroundColor White
    Write-Host "   ID: $($tenant.TenantId)" -ForegroundColor White
    Write-Host "   Domener: $(($tenant.Domains | Select-Object -First 3) -join ', ')" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "⚠️ Kunne ikke hente tenant-informasjon: $_" -ForegroundColor Yellow
}

# List teams
try {
    Write-Host "👥 Henter Teams (maks 5)..." -ForegroundColor Yellow
    $teams = Get-Team -ErrorAction Stop | Select-Object -First 5
    
    if ($teams) {
        Write-Host "✅ Fant $(($teams | Measure-Object).Count) teams:" -ForegroundColor Green
        $teams | Select-Object DisplayName, Description, Visibility, Archived | Format-Table
    } else {
        Write-Host "ℹ️ Ingen teams funnet eller mangler tillatelser" -ForegroundColor Cyan
    }
    Write-Host ""
} catch {
    Write-Host "⚠️ Kunne ikke hente teams: $_" -ForegroundColor Yellow
    Write-Host "   Dette kan skyldes manglende tillatelser" -ForegroundColor Gray
    Write-Host ""
}

# Hent policies
try {
    Write-Host "📋 Henter Teams Policies..." -ForegroundColor Yellow
    
    # Messaging policies
    $messagingPolicies = Get-CsTeamsMessagingPolicy -ErrorAction Stop
    if ($messagingPolicies) {
        Write-Host "✅ Messaging Policies ($($messagingPolicies.Count)):" -ForegroundColor Green
        $messagingPolicies | Select-Object Identity, Description | Select-Object -First 3 | Format-Table
    }
    
    # Meeting policies
    $meetingPolicies = Get-CsTeamsMeetingPolicy -ErrorAction Stop
    if ($meetingPolicies) {
        Write-Host "✅ Meeting Policies ($($meetingPolicies.Count)):" -ForegroundColor Green
        $meetingPolicies | Select-Object Identity, Description | Select-Object -First 3 | Format-Table
    }
    
    # Calling policies
    $callingPolicies = Get-CsTeamsCallingPolicy -ErrorAction Stop
    if ($callingPolicies) {
        Write-Host "✅ Calling Policies ($($callingPolicies.Count)):" -ForegroundColor Green
        $callingPolicies | Select-Object Identity, Description | Select-Object -First 3 | Format-Table
    }
    
} catch {
    Write-Host "⚠️ Kunne ikke hente alle policies: $_" -ForegroundColor Yellow
}

# Test bruker-tilgang
try {
    Write-Host "👤 Tester bruker-tilgang..." -ForegroundColor Yellow
    
    # Prøv å hente en Teams-bruker
    $teamsUsers = Get-CsOnlineUser -ResultSize 1 -ErrorAction Stop
    
    if ($teamsUsers) {
        Write-Host "✅ Kan hente Teams-brukere" -ForegroundColor Green
        Write-Host "   Eksempel-bruker: $($teamsUsers.DisplayName)" -ForegroundColor White
        Write-Host "   UPN: $($teamsUsers.UserPrincipalName)" -ForegroundColor White
        Write-Host ""
    }
} catch {
    Write-Host "⚠️ Kunne ikke hente Teams-brukere: $_" -ForegroundColor Yellow
    Write-Host "   Dette krever ofte ekstra administrative tillatelser" -ForegroundColor Gray
    Write-Host ""
}

# Sjekk app-katalog
try {
    Write-Host "📱 Sjekker Teams App-katalog..." -ForegroundColor Yellow
    $apps = Get-CsTeamsApp -ErrorAction Stop | Select-Object -First 5
    
    if ($apps) {
        Write-Host "✅ Fant $(($apps | Measure-Object).Count) apps (viser maks 5):" -ForegroundColor Green
        $apps | Select-Object DisplayName, Id, DistributionMethod | Format-Table
    }
    Write-Host ""
} catch {
    Write-Host "⚠️ Kunne ikke hente app-katalog: $_" -ForegroundColor Yellow
}

# Vis tilkoblingssammendrag
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "Tilkoblingssammendrag" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Sjekk hvilke cmdlets som er tilgjengelige
$teamsCmdlets = Get-Command -Module MicrosoftTeams -ErrorAction SilentlyContinue
if ($teamsCmdlets) {
    Write-Host "✅ $($teamsCmdlets.Count) Teams cmdlets tilgjengelige" -ForegroundColor Green
    
    # Vis noen eksempel-cmdlets
    Write-Host "Eksempel cmdlets:" -ForegroundColor White
    $teamsCmdlets | Select-Object -First 10 | ForEach-Object {
        Write-Host "   - $($_.Name)" -ForegroundColor Gray
    }
    Write-Host "   ... og $(($teamsCmdlets.Count - 10)) flere" -ForegroundColor Gray
}

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan

# Koble fra
$disconnect = Read-Host "Koble fra? (J/N)"
if ($disconnect -eq "J") {
    Disconnect-MicrosoftTeams
    Write-Host "✅ Frakoblet fra Microsoft Teams" -ForegroundColor Green
} else {
    Write-Host "⚠️ Husk å koble fra med: Disconnect-MicrosoftTeams" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Test fullført!" -ForegroundColor Green