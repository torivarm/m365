# test-graph-connection.ps1
# Test-script for Microsoft Graph PowerShell-tilkobling
# 
# Kjør dette scriptet for å verifisere at Microsoft Graph-modulen er installert
# og at du kan koble til Microsoft 365-miljøet

Write-Host "=================================" -ForegroundColor Cyan
Write-Host "Microsoft Graph Connection Test" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Sjekk om modulen er installert
Write-Host "Sjekker om Microsoft.Graph er installert..." -ForegroundColor Yellow
$module = Get-Module -Name Microsoft.Graph.Authentication -ListAvailable

if (-not $module) {
    Write-Host "❌ Microsoft.Graph er ikke installert!" -ForegroundColor Red
    Write-Host "Kjør: Install-Module -Name Microsoft.Graph -Scope CurrentUser" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Microsoft.Graph versjon $($module.Version) er installert" -ForegroundColor Green
Write-Host ""

# Koble til
Write-Host "Kobler til Microsoft Graph..." -ForegroundColor Yellow
Write-Host "Du vil bli bedt om å logge inn i nettleseren" -ForegroundColor Cyan

try {
    Connect-MgGraph -Scopes "User.Read.All", "Organization.Read.All" -NoWelcome
    Write-Host "✅ Tilkobling vellykket!" -ForegroundColor Green
} catch {
    Write-Host "❌ Kunne ikke koble til: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "Tester API-tilgang" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Hent organisasjonsinformasjon
try {
    $org = Get-MgOrganization
    Write-Host "📊 Organisasjonsinformasjon:" -ForegroundColor Yellow
    Write-Host "   Navn: $($org.DisplayName)" -ForegroundColor White
    Write-Host "   Tenant ID: $($org.Id)" -ForegroundColor White
    Write-Host "   Verifiserte domener: $(($org.VerifiedDomains | Where-Object IsDefault).Name)" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "⚠️ Kunne ikke hente organisasjonsinformasjon: $_" -ForegroundColor Yellow
}

# Hent brukerinformasjon
try {
    Write-Host "👥 Henter brukerinformasjon..." -ForegroundColor Yellow
    $users = Get-MgUser -Top 5 -Property DisplayName,UserPrincipalName,Id,AccountEnabled
    
    if ($users.Count -gt 0) {
        Write-Host "✅ Fant $($users.Count) brukere (viser maks 5)" -ForegroundColor Green
        $users | Select-Object DisplayName, UserPrincipalName, AccountEnabled | Format-Table
    } else {
        Write-Host "⚠️ Ingen brukere funnet" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Kunne ikke hente brukere: $_" -ForegroundColor Red
}

# Vis egen brukerinfo
try {
    $context = Get-MgContext
    $me = Get-MgUser -UserId $context.Account
    Write-Host "👤 Din påloggede bruker:" -ForegroundColor Cyan
    Write-Host "   Navn: $($me.DisplayName)" -ForegroundColor White
    Write-Host "   E-post: $($me.UserPrincipalName)" -ForegroundColor White
    Write-Host ""
} catch {
    Write-Host "⚠️ Kunne ikke hente din brukerinfo" -ForegroundColor Yellow
}

# Vis tilkoblingsdetaljer
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "Tilkoblingsdetaljer" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
$context = Get-MgContext
Write-Host "Environment: $($context.Environment)" -ForegroundColor White
Write-Host "TenantId: $($context.TenantId)" -ForegroundColor White
Write-Host "Scopes:" -ForegroundColor White
$context.Scopes | ForEach-Object { Write-Host "  - $_" -ForegroundColor Gray }

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan

# Koble fra
$disconnect = Read-Host "Koble fra? (J/N)"
if ($disconnect -eq "J") {
    Disconnect-MgGraph
    Write-Host "✅ Frakoblet fra Microsoft Graph" -ForegroundColor Green
} else {
    Write-Host "⚠️ Husk å koble fra med: Disconnect-MgGraph" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Test fullført!" -ForegroundColor Green