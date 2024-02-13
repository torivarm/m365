$Groups = Get-MgGroup -All
foreach ($Group in $Groups) {
    Write-Host "Group: $($Group.DisplayName)" -ForegroundColor Green
    # Determine membership type
    $membershipType = if ("DynamicMembership" -in $Group.GroupTypes) {"Dynamic"} else {"Assigned"}
    Write-Host "Membership Type: $membershipType" -ForegroundColor Green

    # Display membership rule if the group is dynamic
    if ($membershipType -eq "Dynamic" -and $Group.MembershipRule -ne $null) {
        Write-Host "Membership Rule: $($Group.MembershipRule)" -ForegroundColor Green
    }

    Write-Host "Members:" -ForegroundColor Green
    $members = Get-MgGroupMember -GroupId $Group.Id
    foreach ($member in $members) {
        if ($member.AdditionalProperties -and $member.AdditionalProperties.userPrincipalName) {
            Write-Host $($member.AdditionalProperties.userPrincipalName)
        } else {
            # Handling for objects without a userPrincipalName, e.g., service principals or devices
            Write-Host "Member (Not a user): $($member.Id)"
        }
    }
    Write-Host "-----------------" -ForegroundColor Green
}
