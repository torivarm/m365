# Check if ExchangeOnlineManagement module is installed
# The ! is the same as -not. If the module is not found, it will be installed.
# I could also have used -eq $null instead of !. like in the Microsoft.Graph example.

if (!(Get-Module -ListAvailable -Name ExchangeOnlineManagement)) {

    Write-Host "ExchangeOnlineManagement module not found. Installing..."
    Install-Module -Name ExchangeOnlineManagement -Force -AllowClobber
    # -AllowClobber is used to allow the module to overwrite existing commands

} 

else {

    Write-Host "ExchangeOnlineManagement module is already installed."

}

# Import the module
Import-Module ExchangeOnlineManagement

# Connect to Exchange Online
try {

    Connect-ExchangeOnline -ShowProgress $true
    Write-Host "Successfully connected to Exchange Online."

} 

catch {

    Write-Host "Error connecting to Exchange Online: $_"

}