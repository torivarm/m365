# test-miljø.ps1
# Dette scriptet verifiserer PowerShell-installasjonen

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "PowerShell Miljø Verifisering" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Vis PowerShell-versjon
Write-Host "PowerShell Versjon:" -ForegroundColor Yellow
$PSVersionTable.PSVersion
Write-Host ""

# Vis operativsystem
Write-Host "Operativsystem:" -ForegroundColor Yellow
if ($IsWindows) {
    Write-Host "Windows" -ForegroundColor Green
} elseif ($IsMacOS) {
    Write-Host "macOS" -ForegroundColor Green
} elseif ($IsLinux) {
    Write-Host "Linux" -ForegroundColor Green
}
Write-Host ""

# Vis Execution Policy (kun Windows)
if ($IsWindows) {
    Write-Host "Execution Policy:" -ForegroundColor Yellow
    Get-ExecutionPolicy -Scope CurrentUser
    Write-Host ""
}

# Test at vi kan lage og lese filer
Write-Host "Filsystem-test:" -ForegroundColor Yellow
$testFile = "test-output.txt"
"Test fullført $(Get-Date)" | Out-File $testFile
if (Test-Path $testFile) {
    Write-Host "✅ Kan skrive og lese filer" -ForegroundColor Green
    Remove-Item $testFile
} else {
    Write-Host "❌ Problem med filsystemtilgang" -ForegroundColor Red
}
Write-Host ""

Write-Host "====================================" -ForegroundColor Cyan
Write-Host "Verifisering fullført!" -ForegroundColor Green
Write-Host "Du er klar til å jobbe med PowerShell og Microsoft 365!" -ForegroundColor Green
Write-Host "====================================" -ForegroundColor Cyan