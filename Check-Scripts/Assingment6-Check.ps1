# Connect to Exchange Online
Import-Module ExchangeOnlineManagement
Connect-ExchangeOnline -UserPrincipalName <YourAdminUPN>

# Get Dynamic Distribution Lists and Their Members
Write-Host "Retrieving Dynamic Distribution Lists and their members..."
$dynamicDLists = Get-DynamicDistributionGroup
foreach ($ddl in $dynamicDLists) {
    Write-Host "Dynamic Distribution List: $($ddl.DisplayName)"
    $members = Get-Recipient -RecipientPreviewFilter $ddl.RecipientFilter
    foreach ($member in $members) {
        Write-Host "`tMember: $($member.DisplayName)"
    }
}

# Get Standard Distribution Lists and Their Members
Write-Host "Retrieving Distribution Lists and their members..."
$distributionLists = Get-DistributionGroup
foreach ($dl in $distributionLists) {
    Write-Host "Distribution List: $($dl.DisplayName)"
    $members = Get-DistributionGroupMember -Identity $dl.Identity
    foreach ($member in $members) {
        Write-Host "`tMember: $($member.DisplayName)"
    }
}

# Get Resources (Rooms and Equipment) and Their Settings
Write-Host "Retrieving Resources (Rooms and Equipment)..."
$rooms = Get-Mailbox -RecipientTypeDetails RoomMailbox
$equipments = Get-Mailbox -RecipientTypeDetails EquipmentMailbox

foreach ($room in $rooms) {
    Write-Host "Room: $($room.DisplayName) - Capacity: $($room.ResourceCapacity)"
    # Fetch and display desired room settings here
}

foreach ($equipment in $equipments) {
    Write-Host "Equipment: $($equipment.DisplayName)"
    # Fetch and display desired equipment settings here
}

# Disconnect from Exchange Online
Disconnect-ExchangeOnline -Confirm:$false