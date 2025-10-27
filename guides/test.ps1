# Lagre som Skriv-Melding.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$Melding,
    
    [switch]$Farge,
    [switch]$Stor
)

if ($Stor) {
    $Melding = $Melding.ToUpper()
}

if ($Farge) {
    Write-Host $Melding -ForegroundColor Cyan
}
else {
    Write-Host $Melding
}