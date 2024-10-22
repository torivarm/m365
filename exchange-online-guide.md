# Administrere postkasser i Exchange Online med PowerShell

Dette dokumentet forklarer hvordan man kan administrere postkasser i Exchange Online ved hjelp av PowerShell. Her er en gjennomgang av de viktigste kommandoene og deres funksjoner.

## Tilkobling til Exchange Online

Først må vi sjekke om ExchangeOnlineManagement-modulen er installert og koble til Exchange Online:

```powershell
# Sjekker om ExchangeOnlineManagement-modulen er installert
if ($null -eq (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Host "ExchangeOnlineManagement module not found. Installing..."
    Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
} else {
    Write-Host "ExchangeOnlineManagement module is already installed."
}
```

Dette scriptet sjekker om modulen er installert, og installerer den hvis den mangler.

```powershell
# Importerer modulen
Import-Module ExchangeOnlineManagement

# Kobler til Exchange Online
try {
    Connect-ExchangeOnline -ShowProgress $true
    Write-Host "Successfully connected to Exchange Online."
} catch {
    Write-Host "Error connecting to Exchange Online: $_"
}
```

Disse kommandoene importerer modulen og etablerer en tilkobling til Exchange Online.

## Hente informasjon om postkasser

### Vis alle postkasser
```powershell
# Henter alle postkasser
Get-EXOMailbox | Select-Object DisplayName,PrimarySmtpAddress
```
Denne kommandoen viser en liste over alle postkasser med visningsnavn og e-postadresse.

### Vis alle M365-grupper med postkasser
```powershell
# Henter alle M365-grupper med postkasser
Get-UnifiedGroup | Select-Object DisplayName,PrimarySmtpAddress
```
Viser alle Microsoft 365-grupper som har postkasser.

### Hente spesifikk M365-gruppe
```powershell
# Henter en spesifikk M365-gruppe postkasse
$m365Group = "Kundesupport"
Get-UnifiedGroup -Identity $m365Group | Select-Object DisplayName,PrimarySmtpAddress

# Lagrer postkassen i en variabel
$mailbox = Get-UnifiedGroup -Identity $m365Group
```
Disse kommandoene henter informasjon om en spesifikk M365-gruppe og lagrer den i en variabel for videre bruk.

### Vise gruppemedlemmer
```powershell
# Henter alle medlemmer av postkassen
Get-UnifiedGroupLinks -Identity $mailbox.Identity -LinkType Members | 
    Get-Recipient | 
    Select-Object DisplayName, PrimarySmtpAddress, RecipientType, Alias, Name |
    Format-Table -AutoSize
```
Denne kommandoen viser detaljert informasjon om alle medlemmer i gruppen.

## Administrere tillatelser

### Vise eksisterende tillatelser
```powershell
# Henter medlemmers tillatelser og Send As-rettigheter
Get-RecipientPermission -Identity $mailbox.Identity | 
    Select-Object Trustee,AccessRights
```
Viser nåværende tillatelser for postkassen.

### Legge til Send As-tillatelser
```powershell
# Legger til Send As-tillatelser for en bruker
$trustee = "Jan.Eide@m365tim.onmicrosoft.com"
Add-RecipientPermission -Identity $mailbox.Identity -AccessRights SendAs -Trustee $trustee -Confirm:$false
```
Gir en bruker rettighet til å sende som postkassen.

### Legge til Send on Behalf-tillatelser
```powershell
# Definerer brukere som skal få tillatelser
[array] $trustees = "Jan.Eide@m365tim.onmicrosoft.com","Daniel.Thorsen@m365tim.onmicrosoft.com"

# Gir Send on Behalf-tillatelser
Set-UnifiedGroup -Identity $mailbox.Identity -GrantSendOnBehalfTo $trustees
```
Gir flere brukere rettighet til å sende på vegne av postkassen.

### Verifisere tillatelser
```powershell
# Henter nåværende tillatelser for postkassen
$currentTrustees = (Get-UnifiedGroup -Identity $mailbox.Identity).GrantSendOnBehalfTo

# Går gjennom alle brukere med tillatelser og viser detaljer
Write-Host "Send on behalf granted to: " -ForegroundColor Yellow
foreach ($currentTrustee in $currentTrustees) {
    $currentTrusteeRecipient = Get-Recipient -Identity $currentTrustee
    Write-Host "Name: $($currentTrusteeRecipient.DisplayName) - SMTP: $($currentTrusteeRecipient.PrimarySmtpAddress) - ID: $($currentTrusteeRecipient.Identity)" -ForegroundColor Green
}
```
Disse kommandoene viser detaljert informasjon om hvem som har Send on Behalf-tillatelser.

## Andre nyttige kommandoer

### Vise distribusjonsgrupper
```powershell
# Henter alle distribusjonsgrupper
Get-DistributionGroup | Select-Object DisplayName,PrimarySmtpAddress
```
Viser alle vanlige distribusjonsgrupper.

### Vise dynamiske distribusjonsgrupper
```powershell
# Henter alle dynamiske distribusjonsgrupper
Get-DynamicDistributionGroup | Select-Object DisplayName,PrimarySmtpAddress
```
Viser alle dynamiske distribusjonsgrupper.
