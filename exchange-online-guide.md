# Administrere postkasser i Exchange Online med PowerShell

Dette dokumentet forklarer hvordan man kan administrere postkasser i Exchange Online ved hjelp av PowerShell. Her er en gjennomgang av de viktigste kommandoene og deres funksjoner.

## Tilkobling til Exchange Online

Først må vi sjekke om ExchangeOnlineManagement-modulen er installert og koble til Exchange Online:

```powershell
if ($null -eq (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Host "ExchangeOnlineManagement module not found. Installing..."
    Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
} else {
    Write-Host "ExchangeOnlineManagement module is already installed."
}
```

Dette scriptet sjekker om modulen er installert, og installerer den hvis den mangler.

```powershell
Import-Module ExchangeOnlineManagement


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
Get-EXOMailbox | Select-Object DisplayName,PrimarySmtpAddress
```
Denne kommandoen viser en liste over alle postkasser med visningsnavn og e-postadresse.

### Vis alle M365-grupper med postkasser
```powershell
Get-UnifiedGroup | Select-Object DisplayName,PrimarySmtpAddress
```
Viser alle Microsoft 365-grupper som har postkasser.

### Hente spesifikk M365-gruppe
```powershell
$m365Group = "Kundesupport"
Get-UnifiedGroup -Identity $m365Group | Select-Object DisplayName,PrimarySmtpAddress
```

```powershell
$mailbox = Get-UnifiedGroup -Identity $m365Group
```
Disse kommandoene henter informasjon om en spesifikk M365-gruppe og lagrer den i en variabel for videre bruk.

### Vise gruppemedlemmer
```powershell
Get-UnifiedGroupLinks -Identity $mailbox.Identity -LinkType Members | 
    Get-Recipient | 
    Select-Object DisplayName, PrimarySmtpAddress, RecipientType, Alias, Name |
    Format-Table -AutoSize
```
Denne kommandoen viser detaljert informasjon om alle medlemmer i gruppen.

## Administrere tillatelser

### Vise eksisterende tillatelser
```powershell
Get-RecipientPermission -Identity $mailbox.Identity | 
    Select-Object Trustee,AccessRights
```
Viser nåværende tillatelser for postkassen.

### Legge til Send As-tillatelser
```powershell
$trustee = "Jan.Eide@m365tim.onmicrosoft.com"
Add-RecipientPermission -Identity $mailbox.Identity -AccessRights SendAs -Trustee $trustee -Confirm:$false
```
Gir en bruker rettighet til å sende som postkassen.

### Legge til Send on Behalf-tillatelser
```powershell
[array] $trustees = "Jan.Eide@m365tim.onmicrosoft.com","Daniel.Thorsen@m365tim.onmicrosoft.com"

Set-UnifiedGroup -Identity $mailbox.Identity -GrantSendOnBehalfTo $trustees
```
Gir flere brukere rettighet til å sende på vegne av postkassen.

### Verifisere tillatelser
```powershell
$currentTrustees = (Get-UnifiedGroup -Identity $mailbox.Identity).GrantSendOnBehalfTo

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
Get-DistributionGroup | Select-Object DisplayName,PrimarySmtpAddress
```
Viser alle vanlige distribusjonsgrupper.

### Vise dynamiske distribusjonsgrupper
```powershell
Get-DynamicDistributionGroup | Select-Object DisplayName,PrimarySmtpAddress
```
Viser alle dynamiske distribusjonsgrupper.
