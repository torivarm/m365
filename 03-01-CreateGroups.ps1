$TenantID = "06bf9568-f5b8-4a8b-bef5-1f2291b53f76"
Connect-MgGraph -TenantId $TenantID -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All", "RoleManagement.ReadWrite.Directory"

# Create groups
Get-Help New-MgGroup -Online

# Create M365 Group for IT

$departments = @("Ledelse", "Utvikling", "Salg", "Kundesupport", "IT-drift", "Administrasjon")
foreach ($department in $departments) {
    $membershiprule = "user.department -eq `"$department`""
    $Params = @{
        DisplayName = "$department"
        Description = "Gruppe for ansatte i avdeligen $department"
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
    DisplayName = "m365-license"
    Description = "Members of this group will get a M365 license"
    MailEnabled = $false
    MailNickname = "m365-license"
    SecurityEnabled = $true
    GroupTypes = "assigned"
    }

New-MgGroup @Params


New-MgGroup -DisplayName 'm365-license' -MailEnabled:$False -MailNickname "m365-license" -SecurityEnabled