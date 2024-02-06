$TenantID = "06bf9568-f5b8-4a8b-bef5-1f2291b53f76"
Connect-MgGraph -TenantId $TenantID -Scopes "User.ReadWrite.All", "Group.ReadWrite.All", "Directory.ReadWrite.All", "RoleManagement.ReadWrite.Directory"

# List Users
Get-Help Get-MgUser -Online
Get-MgUser
Get-MgUser -Filter "startswith(displayName,'A')"
Get-MgUser -Filter "startswith(displayName,'A')" -Select "id,displayName,mail"
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




$User = Get-MgUser -Filter "displayName eq 'Hans Hansen'" -Property department,displayname,id,city,companyname,jobtitle
Get-MgUser -Property department,displayname,id,city,companyname| Select-Object displayname,id,department,city,companyname | ft
$User | Update-MgUser -Department "HR" -JobTitle "HR Manager"
$User | Update-MgUser -Department "HR" -JobTitle "HR Manager" -City "Trondheim"
$User | Update-MgUser -Department "HR" -JobTitle "HR Manager" -City "Trondheim" -Country "Norway"