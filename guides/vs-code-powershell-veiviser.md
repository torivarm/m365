# Kom i gang med VS Code og PowerShell Core for Microsoft 365

## 📚 Innholdsfortegnelse
1. [Introduksjon](#introduksjon)
2. [Installere Visual Studio Code](#installere-visual-studio-code)
3. [Installere PowerShell Core](#installere-powershell-core)
4. [Konfigurere Execution Policy](#konfigurere-execution-policy)
5. [Verifisere installasjonen](#verifisere-installasjonen)
6. [Neste steg](#neste-steg)

---

## Introduksjon

Denne veiviseren hjelper deg med å sette opp et moderne utviklingsmiljø for å arbeide med PowerShell mot Microsoft 365. Du vil lære å:

- ✅ Installere Visual Studio Code (VS Code) - en kraftig og gratis kodeeditor
- ✅ Installere PowerShell Core - den moderne versjonen av PowerShell som fungerer på alle plattformer
- ✅ Konfigurere nødvendige sikkerhetsinnstillinger for å kjøre egne script
- ✅ Verifisere at alt fungerer korrekt

> **💡 Tips:** PowerShell Core (PowerShell 7+) er den moderne versjonen av PowerShell som fungerer på Windows, macOS og Linux. Den erstatter Windows PowerShell 5.1 og anbefales for all ny utvikling.

---

## Installere Visual Studio Code

Visual Studio Code er en gratis, lett og kraftig kodeeditor fra Microsoft som gir deg:
- Syntaksutheving for PowerShell
- IntelliSense (automatisk kodefullføring)
- Integrert terminal
- Feilsøkingsverktøy
- Git-integrasjon

### 🪟 Windows-installasjon

1. **Last ned VS Code**
   - Gå til [https://code.visualstudio.com](https://code.visualstudio.com)
   - Klikk på "Download for Windows"
   - Velg "User Installer" (64-bit) for enklest installasjon

2. **Kjør installasjonen**
   - Dobbeltklikk på den nedlastede filen (f.eks. `VSCodeUserSetup-x64-1.85.0.exe`)
   - Følg installasjonsveiviseren:
     - Godta lisensavtalen
     - **VIKTIG:** Huk av for følgende alternativer:
       - ☑️ "Add 'Open with Code' action to Windows Explorer file context menu"
       - ☑️ "Add 'Open with Code' action to Windows Explorer directory context menu"
       - ☑️ "Register Code as an editor for supported file types"
       - ☑️ "Add to PATH (requires shell restart)"
   - Klikk "Install" og vent til installasjonen er ferdig

3. **Start VS Code**
   - Klikk "Launch Visual Studio Code" når installasjonen er ferdig
   - Eller finn VS Code i Start-menyen

### 🍎 macOS-installasjon

1. **Last ned VS Code**
   - Gå til [https://code.visualstudio.com](https://code.visualstudio.com)
   - Klikk på "Download for macOS"
   - Velg riktig versjon for din Mac:
     - Apple Silicon (M1/M2/M3) → "Apple Silicon"
     - Intel-basert Mac → "Intel Chip"

2. **Installer VS Code**
   - Åpne den nedlastede `.zip`-filen
   - Dra `Visual Studio Code.app` til Applications-mappen
   - Første gang du åpner VS Code:
     - Høyreklikk på VS Code i Applications
     - Velg "Open" (Åpne)
     - Klikk "Open" i dialogboksen som vises

3. **Legg til VS Code i PATH (valgfritt, men anbefalt)**
   - Åpne VS Code
   - Trykk `Cmd+Shift+P` for å åpne Command Palette
   - Skriv "shell command" og velg "Shell Command: Install 'code' command in PATH"
   - Du kan nå åpne VS Code fra Terminal med kommandoen `code`

---

## Installere PowerShell Core

### 🪟 Windows-installasjon av PowerShell Core

1. **Last ned PowerShell Core**
   - Gå til [https://github.com/PowerShell/PowerShell/releases/latest](https://github.com/PowerShell/PowerShell/releases/latest)
   - Under "Assets", finn og last ned:
     - `PowerShell-7.x.x-win-x64.msi` (for 64-bit Windows)

2. **Installer PowerShell Core**
   - Dobbeltklikk på den nedlastede `.msi`-filen
   - Følg installasjonsveiviseren:
     - Godta lisensavtalen
     - Behold standard installasjonssti
     - Huk av for "Add PowerShell to PATH environment variable"
     - Klikk "Install"

3. **Verifiser installasjonen**
   ```powershell
   # Åpne PowerShell Core (søk etter "pwsh" i Start-menyen)
   $PSVersionTable
   ```
   Du skal se versjon 7.x eller høyere under `PSVersion`.

### 🍎 macOS-installasjon av PowerShell Core

#### Metode 1: Homebrew (Anbefalt)

1. **Installer Homebrew** (hvis du ikke har det fra før)
   ```bash
   # Åpne Terminal og kjør:
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Installer PowerShell Core**
   ```bash
   # Installer PowerShell
   brew install --cask powershell
   
   # Verifiser installasjonen
   pwsh --version
   ```

#### Metode 2: Direkte nedlasting

1. **Last ned installasjonspakken**
   - Gå til [https://github.com/PowerShell/PowerShell/releases/latest](https://github.com/PowerShell/PowerShell/releases/latest)
   - Last ned riktig versjon:
     - Apple Silicon (M1/M2/M3): `powershell-7.x.x-osx-arm64.pkg`
     - Intel Mac: `powershell-7.x.x-osx-x64.pkg`

2. **Installer PowerShell Core**
   - Dobbeltklikk på den nedlastede `.pkg`-filen
   - Følg installasjonsveiviseren
   - Du må kanskje godkjenne installasjonen i System Preferences → Security & Privacy

---

## Installere PowerShell-utvidelsen i VS Code

1. **Åpne VS Code**

2. **Åpne Extensions-panelet**
   - Klikk på Extensions-ikonet i sidepanelet (eller trykk `Ctrl+Shift+X` på Windows, `Cmd+Shift+X` på macOS)

3. **Søk og installer PowerShell-utvidelsen**
   - Søk etter "PowerShell"
   - Finn utvidelsen fra Microsoft (offisiell utgiver)
   - Klikk "Install"
   - Vent til installasjonen er ferdig

4. **Restart VS Code** for å aktivere utvidelsen fullstendig

---

## Konfigurere Execution Policy

Execution Policy er en sikkerhetsfunksjon i PowerShell som bestemmer hvilke script som kan kjøres. For utviklingsformål må vi justere denne.

### 🪟 Windows Execution Policy

1. **Åpne PowerShell Core som Administrator**
   - Høyreklikk på PowerShell Core (pwsh) i Start-menyen
   - Velg "Run as Administrator" (Kjør som administrator)

2. **Sjekk gjeldende policy**
   ```powershell
   Get-ExecutionPolicy -List
   ```
   
3. **Sett Execution Policy for CurrentUser**
   ```powershell
   # For utviklingsformål, sett RemoteSigned for din bruker
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   
   # Bekreft endringen når du blir spurt
   # Skriv 'Y' og trykk Enter
   ```

4. **Verifiser endringen**
   ```powershell
   Get-ExecutionPolicy -Scope CurrentUser
   # Skal vise: RemoteSigned
   ```

#### Forklaring av Execution Policy-nivåer:
- **Restricted**: Ingen script kan kjøres (standard på Windows-klienter)
- **AllSigned**: Kun signerte script kan kjøres
- **RemoteSigned**: Lokale script kan kjøres, nedlastede script må være signerte (anbefalt for utvikling)
- **Unrestricted**: Alle script kan kjøres (advarsel vises for nedlastede script)
- **Bypass**: Ingen restriksjoner (bruk kun midlertidig for testing)

> **⚠️ Sikkerhetsmerknad:** RemoteSigned gir en god balanse mellom sikkerhet og brukervennlighet for utvikling. Den lar deg kjøre egne script, men beskytter mot usignerte script lastet ned fra internett.

### 🍎 macOS og Linux

På macOS og Linux er Execution Policy satt til "Unrestricted" som standard og kan ikke endres. Dette er fordi disse operativsystemene bruker andre sikkerhetsmekanismer (som filrettigheter).

---

## Verifisere installasjonen

La oss sikre at alt fungerer korrekt ved å lage og kjøre et enkelt testscript.

### 1. Opprett et testscript i VS Code

1. **Åpne VS Code**
2. **Opprett en ny fil** (`Ctrl+N` / `Cmd+N`)
3. **Lagre filen** som `test-miljø.ps1` (`Ctrl+S` / `Cmd+S`)
4. **Skriv inn følgende testscript:**

```powershell
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
```

### 2. Kjør scriptet

**I VS Code:**
1. Åpne den integrerte terminalen (`Ctrl+`` ` eller `View → Terminal`)
2. Sørg for at du er i riktig mappe hvor du lagret scriptet
3. Kjør scriptet:
   ```powershell
   .\test-miljø.ps1
   ```

**Forventet resultat:**
- Du skal se informasjon om PowerShell-versjonen (7.x eller høyere)
- Operativsystem skal vises korrekt
- Filsystem-testen skal vise "✅ Kan skrive og lese filer"
- På Windows skal Execution Policy vise "RemoteSigned"

---

## Feilsøking

### 🔧 Vanlige problemer og løsninger

#### Problem: "cannot be loaded because running scripts is disabled"
**Løsning:** Du må sette Execution Policy. Se seksjonen [Konfigurere Execution Policy](#konfigurere-execution-policy).

#### Problem: PowerShell-utvidelsen laster ikke i VS Code
**Løsning:** 
1. Sjekk at PowerShell Core er installert (`pwsh --version` i terminal)
2. Restart VS Code
3. Reinstaller PowerShell-utvidelsen

#### Problem: 'pwsh' er ikke gjenkjent som kommando (Windows)
**Løsning:** PowerShell Core er ikke i PATH. Reinstaller og huk av for "Add to PATH" under installasjonen.

#### Problem: VS Code åpner Windows PowerShell i stedet for PowerShell Core
**Løsning:**
1. Trykk `Ctrl+Shift+P` i VS Code
2. Søk etter "Terminal: Select Default Profile"
3. Velg "PowerShell" (ikke "Windows PowerShell")

---

## Neste steg

Gratulerer! 🎉 Du har nå satt opp et moderne PowerShell-utviklingsmiljø. Her er noen forslag til hva du kan gjøre videre:

1. **Installer Microsoft 365 PowerShell-moduler**
   - Microsoft Graph PowerShell SDK
   - Exchange Online Management
   - Teams PowerShell Module

2. **Lær grunnleggende PowerShell-kommandoer**
   - Get-Help
   - Get-Command
   - Get-Member

3. **Utforsk VS Code-funksjoner**
   - Snippets for raskere koding
   - Git-integrasjon for versjonskontroll
   - Debugging av PowerShell-script

4. **Øv på Microsoft 365-automatisering**
   - Koble til Microsoft 365-tjenester
   - Hente brukerinformasjon
   - Administrere grupper og teams

---

## 📚 Nyttige ressurser

- [PowerShell Dokumentasjon](https://docs.microsoft.com/powershell/)
- [VS Code PowerShell Extension Guide](https://code.visualstudio.com/docs/languages/powershell)
- [Microsoft Graph PowerShell SDK](https://docs.microsoft.com/powershell/microsoftgraph/)
- [PowerShell Gallery](https://www.powershellgallery.com/) - for å finne og dele PowerShell-moduler

---

*Sist oppdatert: Oktober 2025*
*Versjon: 1.0*