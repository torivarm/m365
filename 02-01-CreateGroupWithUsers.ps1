# Script to create M365 Group and manage permissions
# Ensure you're connected to Exchange Online before running this script

# Function to check if a user exists
function Test-UserExists {
    param($UserEmail)
    try {
        $user = Get-EXOMailbox -Identity $UserEmail -ErrorAction Stop
        return $true
    } catch {
        Write-Host "User $UserEmail not found." -ForegroundColor Yellow
        return $false
    }
}

# Parameters
$groupName = "TestGroup" # Change this to your desired group name
$groupEmail = "testgroup@m365tim.onmicrosoft.com" # Change this to your desired group email
$userEmails = @("Astrid.Evjen@m365tim.onmicrosoft.com", "Bente.Gundersen@m365tim.onmicrosoft.com") # Add your user emails here

# Check if the group already exists
$groupExists = $false
try {
    $existingGroup = Get-UnifiedGroup -Identity $groupName -ErrorAction Stop
    Write-Host "Group '$groupName' already exists." -ForegroundColor Yellow
    $groupExists = $true
} catch {
    Write-Host "Group '$groupName' does not exist. Proceeding with creation." -ForegroundColor Green
}

# Create the group if it doesn't exist
if (-not $groupExists) {
    try {
        $newGroup = New-UnifiedGroup -DisplayName $groupName -Alias $groupName -EmailAddresses $groupEmail -AccessType Private
        Write-Host "Group '$groupName' created successfully." -ForegroundColor Green
    } catch {
        Write-Host "Error creating group: $_" -ForegroundColor Red
        exit
    }
} else {
    $newGroup = $existingGroup
}

# Add users to the group and set permissions
foreach ($userEmail in $userEmails) {
    if (Test-UserExists -UserEmail $userEmail) {
        try {
            # Add user to the group
            Add-UnifiedGroupLinks -Identity $groupName -LinkType Members -Links $userEmail
            Write-Host "Added $userEmail to the group." -ForegroundColor Green

            # Grant Full Access permission
            Add-MailboxPermission -Identity $newGroup.ExternalDirectoryObjectId -User $userEmail -AccessRights FullAccess -InheritanceType All
            Write-Host "Granted Full Access permission for $userEmail." -ForegroundColor Green

            # Grant Send on Behalf permission
            Set-UnifiedGroup -Identity $groupName -GrantSendOnBehalfTo @{Add=$userEmail}
            Write-Host "Granted Send on Behalf permission for $userEmail." -ForegroundColor Green

            # Grant Send As permission
            Add-RecipientPermission -Identity $newGroup.ExternalDirectoryObjectId -Trustee $userEmail -AccessRights SendAs
            Write-Host "Granted Send As permission for $userEmail." -ForegroundColor Green

        } catch {
            Write-Host "Error processing user $userEmail : $_" -ForegroundColor Red
        }
    }
}

Write-Host "Script execution completed." -ForegroundColor Green