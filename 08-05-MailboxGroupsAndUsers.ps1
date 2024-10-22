# In this script we will see how we can manage mailboxes with PowerShell

# Checks if it is connected to Exchange Online
if ($null -eq (Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {
    Write-Host "ExchangeOnlineManagement module not found. Installing..."
    Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
} else {
    Write-Host "ExchangeOnlineManagement module is already installed."
}

# Import the module
Import-Module ExchangeOnlineManagement

# Connect to Exchange Online
try {
    Connect-ExchangeOnline -ShowProgress $true
    Write-Host "Successfully connected to Exchange Online."
} catch {
    Write-Host "Error connecting to Exchange Online: $_"
}


# Gets all mailboxes
Get-EXOMailbox | Select-Object DisplayName,PrimarySmtpAddress

# Gets all M365 groups with mailboxes
Get-UnifiedGroup | Select-Object DisplayName,PrimarySmtpAddress

# Gets a specific M365 group mailbox
$m365Group = "Kundesupport"
Get-UnifiedGroup -Identity $m365Group | Select-Object DisplayName,PrimarySmtpAddress

# Puts the mailbox in a variable
$mailbox = Get-UnifiedGroup -Identity $m365Group

# Gets all members of the mailbox
Get-UnifiedGroupLinks -Identity $mailbox.Identity -LinkType Members | 
    Get-Recipient | 
    Select-Object DisplayName, PrimarySmtpAddress, RecipientType, Alias, Name |
    Format-Table -AutoSize

# Gets members permissions and send as permissions
Get-RecipientPermission -Identity $mailbox.Identity | 
    Select-Object Trustee,AccessRights



# Adds members permissions and send as or send on behalf of permissions
$trustee = "Jan.Eide@m365tim.onmicrosoft.com"
Add-RecipientPermission -Identity $mailbox.Identity -AccessRights SendAs -Trustee $trustee -Confirm:$false

# Define trustees
[array] $trustees = "Jan.Eide@m365tim.onmicrosoft.com","Daniel.Thorsen@m365tim.onmicrosoft.com"

# Grant send on behalf of permissions
Set-UnifiedGroup -Identity $mailbox.Identity -GrantSendOnBehalfTo $trustees

# Get current permissions of the mailbox
$currentTrustees = (Get-UnifiedGroup -Identity $mailbox.Identity).GrantSendOnBehalfTo
# Loops through the current trustees and gets the primary smtp address and display name
Write-Host "Send on behalf granted to: " -ForegroundColor Yellow
foreach ($currentTrustee in $currentTrustees) {
    $currentTrusteeRecipient = Get-Recipient -Identity $currentTrustee
    Write-Host "Name: $($currentTrusteeRecipient.DisplayName) - SMTP: $($currentTrusteeRecipient.PrimarySmtpAddress) - ID: $($currentTrusteeRecipient.Identity)" -ForegroundColor Green
}

# Verify the final permissions (Shows only the ID)
Get-UnifiedGroup -Identity $mailbox.Identity | Select-Object GrantSendOnBehalfTo

# Gets all distribution groups
Get-DistributionGroup | Select-Object DisplayName,PrimarySmtpAddress

# Gets all dynamic distribution groups
Get-DynamicDistributionGroup | Select-Object DisplayName,PrimarySmtpAddress