# Microsoft Graph med PowerShell - Enkel introduksjon

## Innholdsfortegnelse

1. [Hva er Microsoft Graph?](#1-hva-er-microsoft-graph)
2. [Installasjon og oppsett](#2-installasjon-og-oppsett)
3. [Autentisering og Scopes](#3-autentisering-og-scopes)
4. [Enkle eksempler med Graph](#4-enkle-eksempler-med-graph)
5. [Variabler og Graph](#5-variabler-og-graph)
6. [If/Else med Graph](#6-ifelse-med-graph)
7. [Løkker med Graph](#7-løkker-med-graph)
8. [Funksjoner med Graph](#8-funksjoner-med-graph)
9. [Feilhåndtering med Graph](#9-feilhåndtering-med-graph)
10. [Praktiske mini-script](#10-praktiske-mini-script)

---

## 1. Hva er Microsoft Graph?

Microsoft Graph er en API (Application Programming Interface) som lar deg kommunisere med Microsoft 365-tjenester via kode. I stedet for å bruke webgrensesnittet i Microsoft 365, kan du bruke PowerShell-kommandoer for å:

- Administrere brukere i Entra ID (tidligere Azure AD)
- Håndtere grupper og teams
- Jobbe med e-post, kalendere og filer
- Administrere SharePoint, OneDrive, og mer

**Hvorfor bruke Microsoft Graph?**
- ✅ Automatisering av repeterende oppgaver
- ✅ Behandle mange brukere samtidig
- ✅ Konsistent administrasjon
- ✅ Raskere enn manuell administrasjon

**Hva er forskjellen på Microsoft Graph og Entra ID?**
- **Entra ID** (tidligere Azure AD): Identitets- og tilgangsstyring i Microsoft 365
- **Microsoft Graph**: API-et/verktøyet vi bruker for å snakke med Entra ID og andre Microsoft 365-tjenester

---

## 2. Installasjon og oppsett

### Installere Microsoft Graph PowerShell-modul

Åpne PowerShell som administrator og kjør:

```powershell
# Installer Microsoft Graph-modulen (gjøres én gang)
Install-Module Microsoft.Graph -Scope CurrentUser -Force

# Sjekk at modulen er installert
Get-Module Microsoft.Graph -ListAvailable
```

### Viktige moduler

Microsoft Graph består av mange under-moduler. De viktigste for Entra ID:

```powershell
# Modul for brukeradministrasjon
Import-Module Microsoft.Graph.Users

# Modul for gruppeadministrasjon
Import-Module Microsoft.Graph.Groups

# Du kan også importere alt (tar litt lengre tid)
Import-Module Microsoft.Graph
```

> **Tips**: Første gang du installerer modulen kan det ta noen minutter.

---

## 3. Autentisering og Scopes

### Hva er Scopes?

**Scopes** (omfang) definerer hvilke tilganger skriptet ditt har i Microsoft 365. Det er som å si: "Jeg trenger tilgang til å lese brukere, men ikke endre dem".

Dette er basert på **minste tilgangs-prinsippet**: Gi kun de tilgangene som er nødvendig!

### Vanlige Scopes for Entra ID

| Scope | Hva det gir tilgang til |
|-------|-------------------------|
| `User.Read.All` | Lese informasjon om alle brukere |
| `User.ReadWrite.All` | Lese og endre brukere |
| `Group.Read.All` | Lese informasjon om grupper |
| `Group.ReadWrite.All` | Lese og endre grupper |
| `Directory.Read.All` | Lese katalogdata (brukere, grupper, etc.) |
| `Directory.ReadWrite.All` | Lese og skrive katalogdata |

### Koble til Microsoft Graph

```powershell
# Enkel tilkobling (du blir bedt om å logge inn i nettleser)
Connect-MgGraph

# Koble til med spesifikke scopes - ANBEFALT!
Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All"

# Sjekk hvilken bruker du er logget inn som
Get-MgContext | Select-Object -Property Account, Scopes

# Koble fra når du er ferdig
Disconnect-MgGraph
```

### Første test

```powershell
# 1. Koble til
Connect-MgGraph -Scopes "User.Read.All"

# 2. Hent informasjon om deg selv
Get-MgUser -UserId "<skriv inn din UPN: xx@xx.onmicrosoft.com>" | Select-Object DisplayName, UserPrincipalName, Id

# 3. Koble fra
Disconnect-MgGraph
```

> **Viktig**: Første gang du kobler til må du godkjenne tilgangene i nettleseren. Dette er normalt!

---

## 4. Enkle eksempler med Graph

### Eksempel 1: Hente en bruker

```powershell
# Koble til
Connect-MgGraph -Scopes "User.Read.All"

# Hent en spesifikk bruker (bruk din egen e-post - eller en annen bruker i din M365)
$bruker = Get-MgUser -UserId "ola.nordmann@dittdomene.no"

# Vis informasjon
Write-Host "Navn: $($bruker.DisplayName)"
Write-Host "E-post: $($bruker.UserPrincipalName)"
Write-Host "Jobb: $($bruker.JobTitle)"
```

### Eksempel 2: Liste de første 5 brukerne

```powershell
Connect-MgGraph -Scopes "User.Read.All"

# Hent de 5 første brukerne
$brukere = Get-MgUser -Top 5

# Vis dem i en tabell
$brukere | Select-Object DisplayName, UserPrincipalName, JobTitle | Format-Table
```

### Eksempel 3: Hente grupper

```powershell
Connect-MgGraph -Scopes "Group.Read.All"

# Hent de 5 første gruppene
$grupper = Get-MgGroup -Top 5

# Vis gruppene
foreach ($gruppe in $grupper) {
    Write-Host "Gruppenavn: $($gruppe.DisplayName)"
}
```

---

## 5. Variabler og Graph

Bruk variabler til å lagre informasjon fra Graph for senere bruk.

### Eksempel: Lagre brukerinformasjon

Husk at Get-MgUser kommandoen ikke tar med alle egenskaper til objektet om en ikke spesifiserer hva en ønsker.
Bruk Get-Member kommandoen for å liste ut alle mulige egenskaper en kan liste ut.
Eksempel:
```powershell
$minBruker = Get-MgUser -UserID "min UserPrincipalName"
$minBruker | Get-Member
```
---

```powershell
Connect-MgGraph -Scopes "User.Read.All"

# Hent bruker og lagre i variabel (Erstatt me med en brukers UserPrincipalName (UPN))
$minBruker = Get-MgUser -UserId "me" -Property UserPrincipalName,Department,DisplayName,JobTitle

# Bruk variabelen senere
$navn = $minBruker.DisplayName
$epost = $minBruker.UserPrincipalName
$avdeling = $minBruker.Department

Write-Host "=== Min informasjon ==="
Write-Host "Navn: $navn"
Write-Host "E-post: $epost"
Write-Host "Avdeling: $avdeling"
```

### Eksempel: Telle brukere

```powershell
Connect-MgGraph -Scopes "User.Read.All"

# Hent alle brukere og tell dem
$alleBrukere = Get-MgUser -All
$antallBrukere = $alleBrukere.Count

Write-Host "Totalt antall brukere: $antallBrukere"
```

---

## 6. If/Else med Graph

Bruk if/else til å gjøre forskjellige ting basert på data fra Graph.

### Eksempel: Sjekk om bruker har jobbtittel

```powershell
Connect-MgGraph -Scopes "User.Read.All"

$bruker = Get-MgUser -UserId "me"

if ($bruker.JobTitle) {
    Write-Host "$($bruker.DisplayName) jobber som $($bruker.JobTitle)"
}
else {
    Write-Host "$($bruker.DisplayName) har ingen jobbtittel registrert"
}
```

### Eksempel: Sjekk kontostatus

Husk at Get-MgUser kommandoen ikke tar med alle egenskaper til objektet om en ikke spesifiserer hva en ønsker.
Bruk Get-Member kommandoen for å liste ut alle mulige egenskaper en kan liste ut.

```powershell
Connect-MgGraph -Scopes "User.Read.All"

$bruker = Get-MgUser -UserId "me" -Property AccountEnabled,DisplayName,UserPrincipalName

if ($bruker.AccountEnabled -eq $true) {
    Write-Host "✅ Kontoen er aktiv" -ForegroundColor Green
}
else {
    Write-Host "❌ Kontoen er deaktivert" -ForegroundColor Red
}
```

### Eksempel: Filtrer basert på avdeling

```powershell
Connect-MgGraph -Scopes "User.Read.All"

# Hent bruker
$bruker = Get-MgUser -UserId "me" -Property Department,UserPrincipalName

# Sjekk avdeling
if ($bruker.Department -eq "IT") {
    Write-Host "Du jobber i IT-avdelingen! 💻"
}
elseif ($bruker.Department -eq "HR") {
    Write-Host "Du jobber i HR-avdelingen! 👥"
}
else {
    Write-Host "Avdeling: $($bruker.Department)"
}
```

---

## 7. Løkker med Graph

Løkker er perfekte når du skal behandle flere brukere eller grupper.

### Eksempel: Vis alle brukernavn

```powershell
Connect-MgGraph -Scopes "User.Read.All"

# Hent de 10 første brukerne
$brukere = Get-MgUser -Top 10

# Gå gjennom hver bruker
foreach ($bruker in $brukere) {
    Write-Host "👤 $($bruker.DisplayName) - $($bruker.UserPrincipalName)"
}
```

### Eksempel: Tell brukere per avdeling

```powershell
Connect-MgGraph -Scopes "User.Read.All"

# Hent alle brukere (eller bruk -Top for testing)
$brukere = Get-MgUser -Top 50

# Opprett en hashtable for telling
$avdelinger = @{}

# Tell brukere per avdeling
foreach ($bruker in $brukere) {
    if ($bruker.Department) {
        if ($avdelinger.ContainsKey($bruker.Department)) {
            $avdelinger[$bruker.Department]++
        }
        else {
            $avdelinger[$bruker.Department] = 1
        }
    }
}

# Vis resultatet
Write-Host "`n=== Brukere per avdeling ==="
foreach ($avdeling in $avdelinger.Keys) {
    Write-Host "$avdeling : $($avdelinger[$avdeling]) bruker(e)"
}
```

### Eksempel: Finn brukere uten jobbtittel

```powershell
Connect-MgGraph -Scopes "User.Read.All"

$brukere = Get-MgUser -Top 20
$utenJobbtittel = 0

foreach ($bruker in $brukere) {
    if (-not $bruker.JobTitle) {
        Write-Host "⚠️  $($bruker.DisplayName) mangler jobbtittel"
        $utenJobbtittel++
    }
}

Write-Host "`nTotalt $utenJobbtittel brukere mangler jobbtittel"
```

---

## 8. Funksjoner med Graph

Funksjoner gjør Graph-skript mer ryddig og gjenbrukbare.

### Eksempel: Funksjon for å hente brukerinfo

```powershell
function Get-BrukerInfo {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Epost
    )
    
    try {
        $bruker = Get-MgUser -UserId $Epost
        
        Write-Host "=== Brukerinformasjon ==="
        Write-Host "Navn: $($bruker.DisplayName)"
        Write-Host "E-post: $($bruker.UserPrincipalName)"
        Write-Host "Jobbtittel: $($bruker.JobTitle)"
        Write-Host "Avdeling: $($bruker.Department)"
        Write-Host "Konto aktiv: $($bruker.AccountEnabled)"
    }
    catch {
        Write-Host "❌ Kunne ikke hente bruker: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Bruk funksjonen
Connect-MgGraph -Scopes "User.Read.All"
Get-BrukerInfo -Epost "me"
```

### Eksempel: Funksjon for å søke etter brukere

```powershell
function Find-Brukere {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Sokeord
    )
    
    $brukere = Get-MgUser -Filter "startsWith(displayName,'$Sokeord')" -Top 10
    
    if ($brukere.Count -eq 0) {
        Write-Host "Ingen brukere funnet med søkeord: $Sokeord" -ForegroundColor Yellow
    }
    else {
        Write-Host "Fant $($brukere.Count) bruker(e):" -ForegroundColor Green
        $brukere | Select-Object DisplayName, UserPrincipalName | Format-Table
    }
}

# Bruk funksjonen
Connect-MgGraph -Scopes "User.Read.All"
Find-Brukere -Sokeord "Ola"
```

### Eksempel: Funksjon med flere parametere

```powershell
function Get-GruppeInfo {
    param(
        [Parameter(Mandatory=$true)]
        [string]$GruppeNavn,
        
        [switch]$VisMedlemmer
    )
    
    # Finn gruppe
    $gruppe = Get-MgGroup -Filter "displayName eq '$GruppeNavn'"
    
    if (-not $gruppe) {
        Write-Host "Fant ikke gruppe: $GruppeNavn" -ForegroundColor Red
        return
    }
    
    Write-Host "Gruppe: $($gruppe.DisplayName)"
    Write-Host "Beskrivelse: $($gruppe.Description)"
    
    if ($VisMedlemmer) {
        Write-Host "`nMedlemmer:"
        $medlemmer = Get-MgGroupMember -GroupId $gruppe.Id
        foreach ($medlem in $medlemmer) {
            $bruker = Get-MgUser -UserId $medlem.Id
            Write-Host "  - $($bruker.DisplayName)"
        }
    }
}

# Bruk funksjonen
Connect-MgGraph -Scopes "Group.Read.All", "GroupMember.Read.All"
Get-GruppeInfo -GruppeNavn "IT-team" -VisMedlemmer
```

---

## 9. Feilhåndtering med Graph

Graph-kommandoer kan feile av mange grunner. Bruk try/catch for robust kode.

### Eksempel: Håndter at bruker ikke finnes

```powershell
Connect-MgGraph -Scopes "User.Read.All"

$epost = "finnes.ikke@example.com"

try {
    $bruker = Get-MgUser -UserId $epost -ErrorAction Stop
    Write-Host "Bruker funnet: $($bruker.DisplayName)"
}
catch {
    Write-Host "❌ Kunne ikke finne bruker: $epost" -ForegroundColor Red
}
```

### Eksempel: Håndter manglende tilganger

```powershell
try {
    # Prøv å hente brukere uten å koble til først
    $brukere = Get-MgUser -Top 5 -ErrorAction Stop
    Write-Host "✅ Hentet $($brukere.Count) brukere"
}
catch {
    Write-Host "❌ Feil: Du må koble til Graph først!" -ForegroundColor Red
    Write-Host "Kjør: Connect-MgGraph -Scopes 'User.Read.All'" -ForegroundColor Yellow
}
```

### Eksempel: Komplett feilhåndtering

```powershell
function Get-BrukerSikker {
    param([string]$Epost)
    
    try {
        # Sjekk om vi er tilkoblet
        $context = Get-MgContext
        if (-not $context) {
            throw "Ikke tilkoblet Graph"
        }
        
        # Hent bruker
        $bruker = Get-MgUser -UserId $Epost -ErrorAction Stop
        
        Write-Host "✅ Bruker funnet!" -ForegroundColor Green
        Write-Host "Navn: $($bruker.DisplayName)"
        
        return $bruker
    }
    catch {
        Write-Host "❌ Feil: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Test funksjonen
Connect-MgGraph -Scopes "User.Read.All"
$resultat = Get-BrukerSikker -Epost "me"
```

---

## 10. Praktiske mini-script

### Mini-script 1: Brukerrapport

```powershell
# Lag en enkel rapport over brukere
Connect-MgGraph -Scopes "User.Read.All"

Write-Host "=== BRUKERRAPPORT ===" -ForegroundColor Cyan
Write-Host "Generert: $(Get-Date -Format 'dd.MM.yyyy HH:mm')`n"

# Hent brukere
$brukere = Get-MgUser -Top 20

# Statistikk
$totalt = $brukere.Count
$aktive = ($brukere | Where-Object {$_.AccountEnabled -eq $true}).Count
$inaktive = $totalt - $aktive

Write-Host "Total brukere: $totalt"
Write-Host "Aktive: $aktive" -ForegroundColor Green
Write-Host "Inaktive: $inaktive" -ForegroundColor Red

# Vis brukere uten avdeling
$utenAvdeling = $brukere | Where-Object {-not $_.Department}
if ($utenAvdeling) {
    Write-Host "`n⚠️  $($utenAvdeling.Count) brukere mangler avdeling:" -ForegroundColor Yellow
    foreach ($bruker in $utenAvdeling) {
        Write-Host "  - $($bruker.DisplayName)"
    }
}

Disconnect-MgGraph
```

### Mini-script 2: Søk etter bruker

```powershell
# Enkelt søkeverktøy
Connect-MgGraph -Scopes "User.Read.All"

$sok = Read-Host "Søk etter bruker (navn eller e-post)"

if ($sok) {
    # Søk i både navn og e-post
    $resultat = Get-MgUser -Filter "startsWith(displayName,'$sok') or startsWith(userPrincipalName,'$sok')" -Top 10
    
    if ($resultat) {
        Write-Host "`n✅ Fant $($resultat.Count) bruker(e):" -ForegroundColor Green
        $resultat | Select-Object DisplayName, UserPrincipalName, Department | Format-Table
    }
    else {
        Write-Host "`n❌ Ingen brukere funnet" -ForegroundColor Red
    }
}

Disconnect-MgGraph
```

### Mini-script 3: Gruppe-medlemmer

```powershell
# Vis medlemmer i en gruppe
Connect-MgGraph -Scopes "Group.Read.All", "GroupMember.Read.All"

# Hent alle grupper
$grupper = Get-MgGroup -Top 10

Write-Host "=== TILGJENGELIGE GRUPPER ===" -ForegroundColor Cyan
for ($i = 0; $i -lt $grupper.Count; $i++) {
    Write-Host "$($i+1). $($grupper[$i].DisplayName)"
}

$valg = Read-Host "`nVelg gruppe (nummer)"

if ($valg -match '^\d+$' -and [int]$valg -le $grupper.Count -and [int]$valg -gt 0) {
    $gruppe = $grupper[[int]$valg - 1]
    
    Write-Host "`n=== $($gruppe.DisplayName) ===" -ForegroundColor Green
    
    try {
        $medlemmer = Get-MgGroupMember -GroupId $gruppe.Id
        
        if ($medlemmer) {
            Write-Host "Medlemmer ($($medlemmer.Count)):"
            foreach ($medlem in $medlemmer) {
                $bruker = Get-MgUser -UserId $medlem.Id
                Write-Host "  👤 $($bruker.DisplayName) - $($bruker.UserPrincipalName)"
            }
        }
        else {
            Write-Host "Ingen medlemmer i gruppen"
        }
    }
    catch {
        Write-Host "Kunne ikke hente medlemmer: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Disconnect-MgGraph
```

### Mini-script 4: Lisens-oversikt (enkel)

```powershell
# Enkel lisensoversikt
Connect-MgGraph -Scopes "User.Read.All"

Write-Host "=== LISENS STATUS ===" -ForegroundColor Cyan

$brukere = Get-MgUser -Top 20

$medLisens = 0
$utenLisens = 0

foreach ($bruker in $brukere) {
    if ($bruker.AssignedLicenses.Count -gt 0) {
        $medLisens++
    }
    else {
        $utenLisens++
        Write-Host "⚠️  $($bruker.DisplayName) - Ingen lisens" -ForegroundColor Yellow
    }
}

Write-Host "`nOppsummering:"
Write-Host "Med lisens: $medLisens" -ForegroundColor Green
Write-Host "Uten lisens: $utenLisens" -ForegroundColor Red

Disconnect-MgGraph
```

### Mini-script 5: Kombiner flere konsepter

```powershell
# Komplett eksempel som kombinerer flere teknikker
function Get-BrukerStatistikk {
    param(
        [int]$AntallBrukere = 50
    )
    
    try {
        # Sjekk tilkobling
        if (-not (Get-MgContext)) {
            throw "Du må koble til Graph først"
        }
        
        Write-Host "Henter $AntallBrukere brukere..." -ForegroundColor Cyan
        $brukere = Get-MgUser -Top $AntallBrukere
        
        # Variabler for statistikk
        $stats = @{
            Totalt = $brukere.Count
            Aktive = 0
            MedJobbtittel = 0
            MedAvdeling = 0
            Avdelinger = @{}
        }
        
        # Analyser brukere med løkke
        foreach ($bruker in $brukere) {
            # If/else for status
            if ($bruker.AccountEnabled) {
                $stats.Aktive++
            }
            
            if ($bruker.JobTitle) {
                $stats.MedJobbtittel++
            }
            
            if ($bruker.Department) {
                $stats.MedAvdeling++
                
                # Tell per avdeling
                if ($stats.Avdelinger.ContainsKey($bruker.Department)) {
                    $stats.Avdelinger[$bruker.Department]++
                }
                else {
                    $stats.Avdelinger[$bruker.Department] = 1
                }
            }
        }
        
        # Vis resultat
        Write-Host "`n=== STATISTIKK ===" -ForegroundColor Green
        Write-Host "Totalt brukere: $($stats.Totalt)"
        Write-Host "Aktive: $($stats.Aktive)"
        Write-Host "Med jobbtittel: $($stats.MedJobbtittel)"
        Write-Host "Med avdeling: $($stats.MedAvdeling)"
        
        Write-Host "`n=== AVDELINGER ===" -ForegroundColor Cyan
        foreach ($avdeling in $stats.Avdelinger.Keys | Sort-Object) {
            Write-Host "$avdeling : $($stats.Avdelinger[$avdeling]) bruker(e)"
        }
        
        return $stats
    }
    catch {
        Write-Host "Feil: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Bruk
Connect-MgGraph -Scopes "User.Read.All"
$resultat = Get-BrukerStatistikk -AntallBrukere 100
Disconnect-MgGraph
```

---

## Vanlige utfordringer og løsninger

### Problem 1: "Authentication needed"

```powershell
# Løsning: Koble til først
Connect-MgGraph -Scopes "User.Read.All"
```

### Problem 2: "Insufficient privileges"

```powershell
# Løsning: Koble til med riktige scopes
Disconnect-MgGraph
Connect-MgGraph -Scopes "User.Read.All", "Group.Read.All"
```

### Problem 3: Får ikke vist alle brukere

```powershell
# Standard: Viser kun noen brukere
$brukere = Get-MgUser

# Løsning: Bruk -All for å hente alle
$alleBrukere = Get-MgUser -All

# Eller bruk -Top for å begrense
$brukere = Get-MgUser -Top 100
```

### Problem 4: Filter fungerer ikke

```powershell
# ❌ Feil: PowerShell-filter virker ikke på Graph
$brukere = Get-MgUser | Where-Object {$_.Department -eq "IT"}

# ✅ Riktig: Bruk Graph filter for bedre ytelse
$brukere = Get-MgUser -Filter "department eq 'IT'"
```

---

## Nyttige Graph-kommandoer

### Brukere

```powershell
# Hent én bruker
Get-MgUser -UserId "bruker@domene.no"

# Hent alle brukere
Get-MgUser -All

# Hent brukere med filter
Get-MgUser -Filter "department eq 'IT'"

# Hent brukere som starter med navn
Get-MgUser -Filter "startsWith(displayName,'Ola')"

# Hent kun spesifikke felter (raskere!)
Get-MgUser -Property DisplayName,UserPrincipalName,Department
```

### Grupper

```powershell
# Hent alle grupper
Get-MgGroup -Top 20

# Hent en spesifikk gruppe
Get-MgGroup -Filter "displayName eq 'IT-team'"

# Hent gruppemedlemmer
Get-MgGroupMember -GroupId "gruppe-id"
```

### Nyttige hjelpere

```powershell
# Sjekk tilkobling
Get-MgContext

# Se hvilke scopes du har
(Get-MgContext).Scopes

# Finn kommandoer
Get-Command -Module Microsoft.Graph.Users

# Få hjelp
Get-Help Get-MgUser -Full
```

---

## Tips og beste praksis

### ✅ GJØR:

1. **Alltid koble til med spesifikke scopes**
   ```powershell
   Connect-MgGraph -Scopes "User.Read.All"
   ```

2. **Bruk try/catch for feilhåndtering**
   ```powershell
   try {
       $bruker = Get-MgUser -UserId $epost -ErrorAction Stop
   }
   catch {
       Write-Host "Feil: $($_.Exception.Message)"
   }
   ```

3. **Koble fra når ferdig**
   ```powershell
   Disconnect-MgGraph
   ```

4. **Test med få brukere først**
   ```powershell
   Get-MgUser -Top 5  # Test med 5 brukere
   ```

### ❌ UNNGÅ:

1. **Ikke hent alle brukere uten grunn**
   ```powershell
   # ❌ Kan ta lang tid
   $alle = Get-MgUser -All
   
   # ✅ Bedre
   $noen = Get-MgUser -Top 100
   ```

2. **Ikke ignorer feil**
   ```powershell
   # ❌ Feil håndteres ikke
   $bruker = Get-MgUser -UserId $epost
   
   # ✅ Bedre
   try { $bruker = Get-MgUser -UserId $epost -ErrorAction Stop }
   catch { Write-Host "Feil!" }
   ```

---

## Oppsummering

Du har nå lært:

✅ Hva Microsoft Graph er og hvorfor vi bruker det  
✅ Hvordan installere og koble til Graph  
✅ Viktigheten av scopes og tilganger  
✅ Hvordan bruke variabler med Graph-data  
✅ Hvordan kombinere if/else med Graph  
✅ Hvordan bruke løkker for å behandle flere objekter  
✅ Hvordan lage funksjoner for Graph-operasjoner  
✅ Hvordan håndtere feil i Graph-script  
✅ Praktiske eksempler du kan bygge videre på  

### Neste steg:

1. Test eksemplene i din egen Microsoft 365-tenant
2. Kombiner teknikkene til dine egne script
3. Utforsk flere Graph-moduler (Teams, SharePoint, etc.)
4. Les Microsoft Graph dokumentasjon: https://learn.microsoft.com/graph

**Lykke til med Microsoft Graph og PowerShell!** 🚀
