# Check if Microsoft Graph PowerShell module is installed
$module = Get-Module -Name Microsoft.Graph -ListAvailable

if ($module -eq $null) {
    Write-Host "Microsoft Graph PowerShell module is not installed. Installing now..."
    
    # Setting PSrepository to PSGallery as trusted (needs to be set only once)
    # Check if PSGallery is already trusted
    $trusted = Get-PSRepository -Name PSGallery | Select-Object -ExpandProperty InstallationPolicy
    if ($trusted -ne "Trusted") {
        Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    }

    # Install the module (-scope is for Windows only, not needed for and macOS/Linux)
    Install-Module -Name Microsoft.Graph -Scope CurrentUser -Force
    
    Write-Host "Microsoft Graph PowerShell module has been installed successfully."
} else {
    Write-Host "Microsoft Graph PowerShell module is already installed."
}

# Connection to my M365 Tenant with Microsoft Graph PowerShell module
# Change to your TenantID!!
$TenantID = "c2f75ca6-3a2c-4bd7-a8c3-7a0eb0be99e6" # <-- Remember to change this to your TenantID
Connect-MgGraph -TenantId $TenantID `
    -Scopes "User.ReadWrite.All", `
            "Group.ReadWrite.All", `
            "Directory.ReadWrite.All", `
            "RoleManagement.ReadWrite.Directory"

$Details = Get-MgContext
$Scopes = $Details | Select-Object -ExpandProperty Scopes
$Scopes = $Scopes -join ","
$OrgName = (Get-MgOrganization).DisplayName
""
""
"Microsoft Graph current session details:"
"---------------------------------------"
"Tenant Id = $($Details.TenantId)"
"Client Id = $($Details.ClientId)"
"Org name  = $OrgName"
"App Name  = $($Details.AppName)"
"Account   = $($Details.Account)"
"Scopes    = $Scopes"
"---------------------------------------"