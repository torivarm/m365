# $TenantID = "06bf9568-f5b8-4a8b-bef5-1f2291b53f76"
# Connect-MgGraph -TenantId $TenantID -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All", "RoleManagement.ReadWrite.Directory"

# Create users
Get-Help New-MgUser -Online

$PasswordProfile = @{
    Password = 'DemoPassword12345!  '
    }

$Params = @{
    UserPrincipalName = "Hedda.Hansen@edudev365.onmicrosoft.com"
    DisplayName = "Hedda Hansen"
    GivenName = "Hedda"
    Surname = "Hansen"
    MailNickname = "hedda.hansen"
    AccountEnabled = $true
    PasswordProfile = $PasswordProfile
    Department = "Support"
    CompanyName = "Demo Company"
    Country = "Norway"
    City = "Trondheim"
    JobTitle = "Support Specialist"
}

New-MgUser @Params



$users = Import-CSV -Path '/Users/melling/git-projects/m365/03-02-Users.csv' -Delimiter ","

$PasswordProfile = @{
    Password = 'DemoPassword12345!  '
    }
foreach ($user in $users) {
    $Params = @{
        UserPrincipalName = $user.GivenName + "." + $user.Surname + "@edudev365.onmicrosoft.com"
        DisplayName = $user.GivenName + " " + $user.Surname
        GivenName = $user.GivenName
        Surname = $user.Surname
        MailNickname = $user.GivenName + "." + $user.Surname
        AccountEnabled = $true
        PasswordProfile = $PasswordProfile
        Department = $user.Department
        CompanyName = $user.CompanyName
        Country = $user.Country
        City = $user.City
    }
    
    New-MgUser @Params
}


$group = Get-MgGroup -Filter "displayName eq 'Support Team'"
(Get-MgGroupMember -GroupID $Group.Id).AdditionalProperties.userPrincipalName