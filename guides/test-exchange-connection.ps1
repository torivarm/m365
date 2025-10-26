# test-exchange-connection.ps1
# Test-script for Exchange Online PowerShell-tilkobling
# 
# Kjør dette scriptet for å verifisere at Exchange Online Management-modulen 
# er installert og at du kan koble til Exchange Online

Write-Host "=================================" -ForegroundColor Cyan
Write-Host "Exchange Online Connection Test" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Sjekk om modulen er installert
Write-Host "Sjekker om ExchangeOnlineManagement er installert..." -ForegroundColor Yellow
$module = Get-Module -Name ExchangeOnlineManagement -ListAvailable

if (-not $module) {
    Write-Host "❌ ExchangeOnlineManagement er ikke installert!" -ForegroundColor Red
    Write-Host "Kjør: Install-Module -Name ExchangeOnlineManagement -Scope CurrentUser" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ ExchangeOnlineManagement versjon $($module.Version) er installert" -ForegroundColor Green
Write-Host ""

# Be om brukernavn
$userPrincipalName = Read-Host "Skriv inn din admin e-postadresse"

# Koble til
Write-Host "Kobler til Exchange Online..." -ForegroundColor Yellow
Write-Host "Du vil bli bedt om å logge inn i nettleseren" -ForegroundColor Cyan

try {
    Connect-ExchangeOnline -UserPrincipalName $userPrincipalName -ShowBanner:$false
    Write-Host "✅ Tilkobling vellykket!" -ForegroundColor Green
} catch {
    Write-Host "❌ Kunne ikke koble til: $_" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "Tester Exchange-tilgang" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""

# Test grunnleggende tilgang
try {
    # Hent egen postboks
    Write-Host "📧 Henter din postboksinformasjon..." -ForegroundColor Yellow
    $myMailbox = Get-Mailbox -Identity $userPrincipalName -ErrorAction Stop
    
    Write-Host "✅ Din postboks:" -ForegroundColor Green
    Write-Host "   Navn: $($myMailbox.DisplayName)" -ForegroundColor White
    Write-Host "   E-post: $($myMailbox.PrimarySmtpAddress)" -ForegroundColor White
    Write-Host "   Database: $($myMailbox.Database)" -ForegroundColor White
    Write-Host "   Størrelse-grense: $($myMailbox.ProhibitSendReceiveQuota)" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host "⚠️ Kunne ikke hente postboksinformasjon: $_" -ForegroundColor Yellow
}

# Hent postboksstatistikk
try {
    Write-Host "📊 Postboksstatistikk:" -ForegroundColor Yellow
    $stats = Get-MailboxStatistics -Identity $userPrincipalName -ErrorAction Stop
    
    Write-Host "   Brukt plass: $($stats.TotalItemSize.Value)" -ForegroundColor White
    Write-Host "   Antall elementer: $($stats.ItemCount)" -ForegroundColor White
    Write-Host "   Slettet elementer: $($stats.DeletedItemCount)" -ForegroundColor White
    Write-Host ""
    
} catch {
    Write-Host "⚠️ Kunne ikke hente postboksstatistikk: $_" -ForegroundColor Yellow
}

# List noen postbokser
try {
    Write-Host "📮 Henter postbokser (maks 5)..." -ForegroundColor Yellow
    $mailboxes = Get-Mailbox -ResultSize 5 -ErrorAction Stop
    
    if ($mailboxes.Count -gt 0) {
        Write-Host "✅ Fant $($mailboxes.Count) postbokser:" -ForegroundColor Green
        $mailboxes | Select-Object DisplayName, PrimarySmtpAddress, RecipientTypeDetails | Format-Table
    } else {
        Write-Host "⚠️ Ingen postbokser funnet" -ForegroundColor Yellow
    }
} catch {
    Write-Host "❌ Kunne ikke hente postboksliste: $_" -ForegroundColor Red
}

# Test e-postflyt (message trace)
try {
    Write-Host "✉️ Tester e-postflyt (message trace)..." -ForegroundColor Yellow
    $endDate = Get-Date
    $startDate = $endDate.AddDays(-1)
    
    $messages = Get-MessageTrace -SenderAddress $userPrincipalName -StartDate $startDate -EndDate $endDate -PageSize 5 -ErrorAction Stop
    
    if ($messages) {
        Write-Host "✅ Fant $(($messages | Measure-Object).Count) meldinger siste 24 timer" -ForegroundColor Green
        $messages | Select-Object Received, SenderAddress, RecipientAddress, Subject, Status | Format-Table
    } else {
        Write-Host "ℹ️ Ingen meldinger funnet fra din adresse siste 24 timer" -ForegroundColor Cyan
    }
    Write-Host ""
} catch {
    Write-Host "⚠️ Kunne ikke kjøre message trace: $_" -ForegroundColor Yellow
}

# Vis tilkoblingsinfo
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "Tilkoblingsdetaljer" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

$connection = Get-ConnectionInformation
if ($connection) {
    Write-Host "Tilkoblet til: $($connection.ConnectionUri)" -ForegroundColor White
    Write-Host "Bruker: $($connection.UserPrincipalName)" -ForegroundColor White
    Write-Host "Token utløper: $($connection.TokenExpiryTimeUTC)" -ForegroundColor White
    Write-Host "Tilkoblings-ID: $($connection.Id)" -ForegroundColor White
}

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan

# Koble fra
$disconnect = Read-Host "Koble fra? (J/N)"
if ($disconnect -eq "J") {
    Disconnect-ExchangeOnline -Confirm:$false
    Write-Host "✅ Frakoblet fra Exchange Online" -ForegroundColor Green
} else {
    Write-Host "⚠️ Husk å koble fra med: Disconnect-ExchangeOnline -Confirm:`$false" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "✅ Test fullført!" -ForegroundColor Green