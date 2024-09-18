#$TenantID = "365f675a-0c84-46f1-a412-d9783a48076f"
Connect-MgGraph -TenantId $TenantID -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All", "RoleManagement.ReadWrite.Directory"

# Create users
Get-Help New-MgUser -Online

$PasswordProfile = @{
    Password = 'DemoPassword12345!'
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



$users = Import-CSV -Path '03-02-Users.csv' -Delimiter ","

$PasswordProfile = @{
    Password = 'DemoPassword12345!'
    }
foreach ($user in $users) {
    $Params = @{
        UserPrincipalName = $user.givenName + "." + $user.surName + "@minundervisning.onmicrosoft.com"
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
-PasswordProfile @{ Password = "adsfg3!weafg_fsdf"; ForceChangePasswordNextSignIn = $false } `
-GivenName "Tim" -Surname "Admin"

# Get the Global Administrator role definition
$globalAdminRole = Get-MgDirectoryRole | Where-Object { $_.DisplayName -eq "Global Administrator" }

# Assign the Global Administrator role to the new user
New-MgDirectoryRoleMember -DirectoryRoleId $globalAdminRole.Id -RoleMemberId $newUser.Id


