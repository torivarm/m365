$TenantID = "06bf9568-f5b8-4a8b-bef5-1f2291b53f76"
Connect-MgGraph -TenantId $TenantID -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All", "RoleManagement.ReadWrite.Directory"

# List Users
Get-Help Get-MgUser -Online
Get-MgUser
Get-MgUser -Filter "startswith(displayName,'John')"
Get-MgUser -Filter "startswith(displayName,'John')" -Select "id,displayName,mail"
Get-MgUser -Filter "startswith(displayName,'A')" -Select "id,displayName,mail" -Top 5
Get-MgUser -Filter "department eq 'HR'"
Get-MgUser -Filter "department eq 'HR'" -Select "id,displayName,mail"
Get-MgUser -Filter "department eq 'HR'" -Select "id,displayName,mail" -Top 5
Get-MgUser -Filter "department eq 'HR' and accountEnabled eq true"
Get-MgUser -Filter "department eq 'HR' and startswith(displayName,'A') and accountEnabled eq true"
Get-MgUser -Filter "department eq 'HR' and displayName eq 'Hans Hansen' and accountEnabled eq true"

# Set User
Get-Help Update-MgUser -Online
$User = Get-MgUser -Filter "displayName eq 'Hans Hansen'"
$User | Get-Member -MemberType Property
$User | Update-MgUser -Department "HR"




$User = Get-MgUser -Filter "displayName eq 'Hans Hansen'" -Property department,displayname,id,city,companyname,jobtitle,country
Update-MgUser -UserId $User.id -Department "HR" -JobTitle "HR Man"

Get-MgUser -Filter "JobTitle eq 'HR Man'"
$Users = Get-MgUser -Property department,displayname,id,city,companyname,jobtitle,country

$Users = Get-MgUser -Property department,displayname,id,city,companyname | Select-Object displayname,id,department,city,companyname,jobtitle | ft

foreach ($User in $Users) {
    [string]$Userid = $User.id
    Write-Host "User ID: $Userid" -ForegroundColor green
    Write-Host "Update city, companyname, country for user: $Userid" -ForegroundColor green
    Update-MgUser -UserId $Userid -City "Trondheim" -Country "Norway" -CompanyName "Demo Company"
}




Update-MgUser -UserId $User.id -Department "HR" -JobTitle "HR Manager"
$User | Select-object displayName, id, mail, userPrincipalName, department, jobtitle, city, country, companyname
Update-MgUser -UserId $User.id -Department "HR" -JobTitle "HR Manager" -City "Trondheim"
Update-MgUser -UserId $User.id -Department "HR" -JobTitle "HR Manager" -City "Trondheim" -Country "Norway"
Update-MgUser -UserId $User.id -Department "HR" -JobTitle "HR Manager" -City "Trondheim" -Country "Norway" -CompanyName "Demo Company"


# New User


Get-Help New-MgUser -Online
$PasswordProfile = @{
    Password = 'DemoPassword12345!  '
    }

$allUsers = Import-CSV -Path "C:\temp\users.csv"
foreach ($user in $allUsers) {
    New-MgUser -UserPrincipalName $user.UserPrincipalName `
                -DisplayName $user.DisplayName `
                -MailNickName $user.MailNickName `
                -PasswordProfile $PasswordProfile `
                -Department $user.Department `
                -JobTitle $user.JobTitle `
                -City $user.City `
                -Country $user.Country `
                -CompanyName $user.CompanyName `
                -AccountEnabled
}




New-MgUser -UserPrincipalName "per.person@edudev365.onmicrosoft.com" `
                    -DisplayName "Per Person" `
                    -MailNickName "per.person" `
                    -PasswordProfile $PasswordProfile `
                    -Department "IT" `
                    -JobTitle "IT Manager" `
                    -City "Trondheim" `
                    -Country "Norway" `
                    -CompanyName "Demo Company" `
                    -AccountEnabled





# Find members in Group
Get-Help Update-MgGroup -Online
Get-MgGroup
Get-MgGroup -Filter "startswith(displayName,'grp')"
$Group = Get-MgGroup -Filter "displayName eq 'grp_demo'"
$Group.Id
$Group | Get-Member -MemberType Property
Get-MgGroupMember -GroupId $Group.Id
(Get-MgGroupMember -GroupID $Group.Id).AdditionalProperties.userPrincipalName