$TenantID = "06bf9568-f5b8-4a8b-bef5-1f2291b53f76"
Connect-MgGraph -TenantId $TenantID -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All", "RoleManagement.ReadWrite.Directory"

# Create groups
Get-Help New-MgGroup -Online

# Create M365 Group for IT

$departments = @("HR", "IT", "Sales", "Marketing", "Finance", "Support")
foreach ($department in $departments) {
    $membershiprule = "user.department -eq `"$department`""
    $Params = @{
        DisplayName = "$department Team"
        Description = "Group for all $department employees"
        MailEnabled = $true
        MailNickname = $department
        SecurityEnabled = $true
        GroupTypes = @("Unified", "DynamicMembership")
        MembershipRule = $membershiprule
        MembershipRuleProcessingState = "On"
    }

    New-MgGroup @Params
}

# List group members - UserPrincipalName
$group = Get-MgGroup -Filter "displayName eq 'HR Team'"
(Get-MgGroupMember -GroupID $Group.Id).AdditionalProperties.userPrincipalName



$Params = @{
    DisplayName = "IT Team"
    Description = "Team for all IT employees"
    MailEnabled = $true
    MailNickname = "it"
    SecurityEnabled = $true
    GroupTypes = @("Unified", "DynamicMembership")
    MembershipRule = 'user.department -eq "IT"'
    MembershipRuleProcessingState = "On"
    }

New-MgGroup @Params


