#$TenantID = "c2f75ca6-3a2c-4bd7-a8c3-7a0eb0be99e6"
Connect-MgGraph -TenantId $TenantID -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All", "RoleManagement.ReadWrite.Directory"

# Create users
Get-Help New-MgUser -Online

$PasswordProfile = @{
    Password = 'dfsdfasd_Asd2dd'
    }

$Params = @{
    UserPrincipalName = "Hedda.Hansen@<yourtenant>.onmicrosoft.com"
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



$users = Import-CSV -Path '03-02-Users.csv' -Delimiter ","

$PasswordProfile = @{
    Password = 'dsdfsdfsdfsdfsdf123123'
    }
foreach ($user in $users) {
    $Params = @{
        UserPrincipalName = $user.givenName + "." + $user.surName + "@<yourtenant>.onmicrosoft.com"
        DisplayName = $user.givenName + " " + $user.surname
        GivenName = $user.GivenName
        Surname = $user.Surname
        MailNickname = $user.givenName + "." + $user.surname
        AccountEnabled = $true
        PasswordProfile = $PasswordProfile
        Department = $user.Department
        CompanyName = $user.CompanyName
        Country = $user.Country
        City = $user.City
        JobTitle = $user.JobTitle
    }
    $Params
    New-MgUser @Params
}



$group = Get-MgGroup -Filter "displayName eq 'HR Team'"
(Get-MgGroupMember -GroupID $Group.Id).AdditionalProperties.userPrincipalName




# $users = Get-MGUser | Where-Object { $_.DisplayName -ne 'Tor Ivar Melling' }
foreach ($user in $users) {
    $getuser = Get-MgUser -Filter "givenName eq '$($user.givenName)'"
    Remove-MgUser -UserId $getuser.Id
}


# Create a new user
$newUser = New-MgUser -AccountEnabled -DisplayName "Tim Admin" -MailNickname "TimAdmin" `
-UserPrincipalName "TimAdmin@minundervisning.onmicrosoft.com" `
-PasswordProfile @{ Password = "asdfsdf31231231_asf"; ForceChangePasswordNextSignIn = $false } `
-GivenName "Tim" -Surname "Admin"

# Get the Global Administrator role definition
$globalAdminRole = Get-MgDirectoryRole | Where-Object { $_.DisplayName -eq "Global Administrator" }

# Assign the Global Administrator role to the new user
New-MgDirectoryRoleMember -DirectoryRoleId $globalAdminRole.Id -RoleMemberId $newUser.Id


