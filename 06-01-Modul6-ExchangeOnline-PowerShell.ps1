# Find og installere moduler #
Find-Module -Name ExchangeOnlineManagement | Install-Module
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline


# https://docs.microsoft.com/en-us/powershell/module/exchange/new-distributiongroup?view=exchange-ps
Get-Help New-DistributionGroup -Example
Get-DistributionGroup | Select-Object DisplayName,PrimarySmtpAddress
New-DistributionGroup -Name "" -DisplayName "" -PrimarySmtpAddress ""

# https://docs.microsoft.com/en-us/powershell/module/exchange/add-distributiongroupmember?view=exchange-ps
Add-DistributionGroupMember -Identity "" -Member ""

New-Mailbox -Shared -Name "" -DisplayName "" -PrimarySmtpAddress ""

# https://docs.microsoft.com/en-us/powershell/module/exchange/add-mailboxpermission?view=exchange-ps
Get-Mailbox -Identity "" | Add-MailboxPermission -User "" -AccessRights FullAccess -InheritanceType All

# https://docs.microsoft.com/en-us/powershell/module/exchange/add-recipientpermission?view=exchange-ps
Add-RecipientPermission -Identity "" -AccessRights SendAs -Trustee "" -Confirm:$false

# https://docs.microsoft.com/en-us/powershell/module/exchange/new-dynamicdistributiongroup?view=exchange-ps
New-DynamicDistributionGroup -Name "" -IncludedRecipients "MailboxUsers" -ConditionalStateOrProvince "Trondheim"

# https://docs.microsoft.com/en-us/powershell/module/exchange/new-unifiedgroup?view=exchange-ps
New-UnifiedGroup -DisplayName ""
# https://docs.microsoft.com/en-us/powershell/module/exchange/set-unifiedgroup?view=exchange-ps
Set-UnifiedGroup
# https://docs.microsoft.com/en-us/powershell/module/exchange/add-unifiedgrouplinks?view=exchange-ps
Add-UnifiedGroupLinks -Identity "" -LinkType Members -Links Kari.nordmann@demoundervisning.onmicrosoft.com

# https://docs.microsoft.com/en-us/powershell/module/exchange/new-mailbox?view=exchange-ps
New-Mailbox -Name "@edudev365.onmicrosoft.com" `
    -DisplayName "" `
    -Alias "" `
    -Room `
    -EnableRoomMailboxAccount $true `
    -RoomMailboxPassword (ConvertTo-SecureString -String FfdE123e!wes_ -AsPlainText -Force)

Get-Mailbox -Identity "skrivinnNavnPåRom" | Set-Mailbox -ResourceCapacity 12
