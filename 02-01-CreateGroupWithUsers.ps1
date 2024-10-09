# Script to create M365 Group and grant Full Access and Send As permissions
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
        Start-Sleep -Seconds 60  # Wait for group creation to propagate
    } catch {
        Write-Host "Error creating group: $_" -ForegroundColor Red
        exit
    }
} else {
    $newGroup = $existingGroup
}

# Get the group's details
$groupDetails = Get-UnifiedGroup -Identity $groupName | Select-Object ExternalDirectoryObjectId, PrimarySmtpAddress

# Process each user
foreach ($userEmail in $userEmails) {
    if (Test-UserExists -UserEmail $userEmail) {
        try {
            # Add user to the group
            Add-UnifiedGroupLinks -Identity $groupName -LinkType Members -Links $userEmail -Confirm:$false
            Write-Host "Added $userEmail to the group." -ForegroundColor Green

            # Grant Full Access permission
            # Note: Full Access for M365 Groups is typically managed through group membership
            Write-Host "Full Access granted through group membership for $userEmail." -ForegroundColor Green

            # Grant Send As permission
            Add-RecipientPermission -Identity $groupDetails.PrimarySmtpAddress -Trustee $userEmail -AccessRights SendAs -Confirm:$false
            Write-Host "Granted Send As permission for $userEmail." -ForegroundColor Green
        } catch {
            Write-Host "Error processing user $userEmail : $_" -ForegroundColor Red
        }
    }
}

Write-Host "Script execution completed." -ForegroundColor Green

# Display final permissions
Write-Host "`nFinal Permissions:" -ForegroundColor Cyan
Write-Host "Group Members (Full Access):" -ForegroundColor Yellow
try {
    Get-UnifiedGroupLinks -Identity $groupName -LinkType Members | Format-Table DisplayName, PrimarySmtpAddress
} catch {
    Write-Host "Unable to retrieve group members: $_" -ForegroundColor Red
}
Write-Host "Send As:" -ForegroundColor Yellow
try {
    Get-RecipientPermission -Identity $groupDetails.PrimarySmtpAddress | Where-Object {$_.AccessRights -eq "SendAs"} | Format-Table Trustee, AccessRights
} catch {
    Write-Host "Unable to retrieve Send As permissions: $_" -ForegroundColor Red
}