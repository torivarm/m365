# PowerShell Grunnleggende - Veiledning

## Innholdsfortegnelse

1. [Introduksjon til PowerShell](#1-introduksjon-til-powershell)
2. [Variabler](#2-variabler)
3. [If/Else - Betingelser](#3-ifelse---betingelser)
4. [Switch - Flerveis valg](#4-switch---flerveis-valg)
5. [Løkker - ForEach og For](#5-løkker---foreach-og-for)
6. [Feilhåndtering - Try/Catch](#6-feilhåndtering---trycatch)
7. [Funksjoner](#7-funksjoner)
8. [Import av datafiler](#8-import-av-datafiler)
9. [Objektbehandling og Pipelining](#9-objektbehandling-og-pipelining)
10. [Parametre](#10-parametre)
11. [Skript som verktøy](#11-skript-som-verktøy)

---

## 1. Introduksjon til PowerShell

PowerShell er et kraftig kommandolinjeverktøy og skriptspråk fra Microsoft. Det er spesielt utviklet for systemadministrasjon og automatisering av oppgaver. I motsetning til tradisjonelle kommandolinjeverktøy som arbeider med ren tekst, arbeider PowerShell med **objekter** - noe som gjør det enklere å manipulere og behandle data.

### Hvorfor lære PowerShell?

- **Automatisering**: Automatiser repeterende oppgaver
- **Administrasjon**: Administrer Windows, Azure, Microsoft 365 og mer
- **Effektivitet**: Utfør komplekse oppgaver med få kommandoer
- **Integrering**: Fungerer med mange Microsoft og tredjepartsprodukter

### Før du starter

- Åpne **PowerShell** eller **VS Code** med PowerShell-utvidelsen installert
- Test at PowerShell fungerer ved å skrive: `Write-Host "Hei, PowerShell!"`
- Alle eksempler i denne veiledningen kan kjøres direkte i VS Code

---

## 2. Variabler

Variabler brukes til å lagre data som du kan bruke senere i skriptet. I PowerShell starter alle variabler med et dollartegn `$`.

### Grunnleggende om variabler

```powershell
# Deklarere en variabel
$navn = "Ola Nordmann"
$alder = 25
$erStudent = $true

# Skrive ut variabler
Write-Host "Navn: $navn"
Write-Host "Alder: $alder"
Write-Host "Er student: $erStudent"
```

### Datatyper

PowerShell håndterer automatisk datatyper, men du kan også spesifisere dem:

```powershell
# Automatisk typing
$tall = 42
$tekst = "Hallo"
$desimaltall = 3.14

# Eksplisitt typing
[int]$heltall = 100
[string]$streng = "PowerShell"
[double]$desimal = 99.99
[bool]$sannhet = $true
```

### Enkelt eksempel å teste

```powershell
# Lag en enkel kalkulator med variabler
$tall1 = 10
$tall2 = 5

$sum = $tall1 + $tall2
$differanse = $tall1 - $tall2
$produkt = $tall1 * $tall2
$kvotient = $tall1 / $tall2

Write-Host "Sum: $sum"
Write-Host "Differanse: $differanse"
Write-Host "Produkt: $produkt"
Write-Host "Kvotient: $kvotient"
```

### Arrays (lister)

```powershell
# Opprette en array
$farger = @("Rød", "Grønn", "Blå")

# Hente verdier fra array (indeksering starter på 0)
Write-Host $farger[0]  # Output: Rød
Write-Host $farger[1]  # Output: Grønn

# Antall elementer i array
Write-Host "Antall farger: $($farger.Count)"
```

---

## 3. If/Else - Betingelser

If/Else brukes når du vil at skriptet skal gjøre forskjellige ting basert på om en betingelse er sann eller usann.

### Grunnleggende If-struktur

```powershell
$temperatur = 20

if ($temperatur -gt 25) {
    Write-Host "Det er varmt ute!"
}
elseif ($temperatur -gt 15) {
    Write-Host "Behagelig temperatur"
}
else {
    Write-Host "Det er kaldt ute"
}
```

### Sammenlign operatorer

I PowerShell bruker vi spesielle operatorer for sammenligning:

- `-eq` : Lik (equal)
- `-ne` : Ikke lik (not equal)
- `-gt` : Større enn (greater than)
- `-lt` : Mindre enn (less than)
- `-ge` : Større eller lik (greater or equal)
- `-le` : Mindre eller lik (less or equal)

### Praktisk eksempel: Karaktervurdering

```powershell
$poeng = 85

if ($poeng -ge 90) {
    $karakter = "A"
}
elseif ($poeng -ge 80) {
    $karakter = "B"
}
elseif ($poeng -ge 70) {
    $karakter = "C"
}
elseif ($poeng -ge 60) {
    $karakter = "D"
}
else {
    $karakter = "F"
}

Write-Host "Med $poeng poeng får du karakter: $karakter"
```

### Logiske operatorer

Du kan kombinere flere betingelser:

```powershell
$alder = 20
$harKjorekort = $true

# -and (begge må være sanne)
if ($alder -ge 18 -and $harKjorekort -eq $true) {
    Write-Host "Du kan kjøre bil"
}

# -or (minst én må være sann)
$erWeekend = $true
$erFerie = $false

if ($erWeekend -or $erFerie) {
    Write-Host "Du har fri!"
}

# -not (negerer en betingelse)
$regner = $false

if (-not $regner) {
    Write-Host "Du trenger ikke paraply"
}
```

---

## 4. Switch - Flerveis valg

Switch-setninger brukes når du har mange mulige verdier å sjekke. De er ryddigere enn mange if/elseif-setninger.

### Grunnleggende Switch

```powershell
$dag = "Mandag"

switch ($dag) {
    "Mandag" {
        Write-Host "Start på uken!"
    }
    "Fredag" {
        Write-Host "Snart helg!"
    }
    "Lørdag" {
        Write-Host "Helg!"
    }
    "Søndag" {
        Write-Host "Helg!"
    }
    default {
        Write-Host "En vanlig dag"
    }
}
```

### Switch med flere alternativer

```powershell
$maned = 12

switch ($maned) {
    {$_ -in 12,1,2} {
        Write-Host "Det er vinter"
    }
    {$_ -in 3,4,5} {
        Write-Host "Det er vår"
    }
    {$_ -in 6,7,8} {
        Write-Host "Det er sommer"
    }
    {$_ -in 9,10,11} {
        Write-Host "Det er høst"
    }
    default {
        Write-Host "Ugyldig måned"
    }
}
```

### Praktisk eksempel: Meny-system

```powershell
Write-Host "=== Meny ==="
Write-Host "1. Vis dato"
Write-Host "2. Vis klokkeslett"
Write-Host "3. Vis brukernavn"
Write-Host "4. Avslutt"

$valg = Read-Host "Velg et alternativ (1-4)"

switch ($valg) {
    "1" {
        Get-Date -Format "dddd dd.MM.yyyy"
    }
    "2" {
        Get-Date -Format "HH:mm:ss"
    }
    "3" {
        Write-Host "Brukernavn: $env:USERNAME"
    }
    "4" {
        Write-Host "Avslutter..."
    }
    default {
        Write-Host "Ugyldig valg!"
    }
}
```

---

## 5. Løkker - ForEach og For

Løkker brukes til å gjenta kode flere ganger. Dette er ekstremt nyttig når du skal behandle lister med data.

### ForEach-løkke

ForEach brukes til å iterere gjennom hver element i en samling:

```powershell
# Enkel ForEach-løkke
$byer = @("Oslo", "Bergen", "Trondheim", "Stavanger")

foreach ($by in $byer) {
    Write-Host "Jeg besøker $by"
}
```

### Praktisk eksempel: Prosessere filer

```powershell
# Liste over filnavn
$filer = @("dokument1.txt", "rapport2.txt", "notat3.txt")

foreach ($fil in $filer) {
    Write-Host "Behandler: $fil"
    # Her kunne du gjort noe med filen
}
```

### ForEach med indeks

```powershell
$studenter = @("Anna", "Bjørn", "Cathrine", "Daniel")

$indeks = 0
foreach ($student in $studenter) {
    $indeks++
    Write-Host "$indeks. $student"
}
```

### For-løkke

For-løkker brukes når du vet hvor mange ganger du skal iterere:

```powershell
# Teller fra 1 til 5
for ($i = 1; $i -le 5; $i++) {
    Write-Host "Telling: $i"
}
```

### Gangetabell med For-løkke

```powershell
$tall = 7

Write-Host "Gangetabell for $tall"
Write-Host "===================="

for ($i = 1; $i -le 10; $i++) {
    $resultat = $tall * $i
    Write-Host "$tall x $i = $resultat"
}
```

### While-løkke (bonus)

While fortsetter så lenge en betingelse er sann:

```powershell
$teller = 1

while ($teller -le 5) {
    Write-Host "Runde: $teller"
    $teller++
}
```

### Break og Continue

```powershell
# Break - stopper løkken helt
for ($i = 1; $i -le 10; $i++) {
    if ($i -eq 5) {
        Write-Host "Stopper ved 5"
        break
    }
    Write-Host $i
}

Write-Host "---"

# Continue - hopper over resten av denne iterasjonen
for ($i = 1; $i -le 5; $i++) {
    if ($i -eq 3) {
        Write-Host "Hopper over 3"
        continue
    }
    Write-Host $i
}
```

---

## 6. Feilhåndtering - Try/Catch

Feilhåndtering gjør skriptene dine mer robuste ved å fange opp feil uten at skriptet krasjer.

### Grunnleggende Try/Catch

```powershell
try {
    # Kode som kan feile
    $tall = 10 / 0  # Dette vil gi en feil
}
catch {
    # Kode som kjøres hvis det oppstår en feil
    Write-Host "Det oppsto en feil: $($_.Exception.Message)"
}
```

### Praktisk eksempel: Filbehandling

```powershell
$filsti = "C:\IkkeEksisterende\fil.txt"

try {
    $innhold = Get-Content -Path $filsti -ErrorAction Stop
    Write-Host "Fil lest vellykket"
}
catch {
    Write-Host "Kunne ikke lese filen: $($_.Exception.Message)"
}
```

### Try/Catch/Finally

Finally-blokken kjøres alltid, uansett om det oppsto en feil eller ikke:

```powershell
try {
    Write-Host "Forsøker å koble til database..."
    # Simuler tilkobling
    $tilkoblet = $true
    Write-Host "Tilkoblet!"
}
catch {
    Write-Host "Tilkobling feilet: $($_.Exception.Message)"
}
finally {
    Write-Host "Rydder opp ressurser..."
    # Kode som alltid skal kjøres
}
```

### Spesifikke feiltyper

```powershell
try {
    # Prøv å konvertere tekst til tall
    [int]$tall = "ikke et tall"
}
catch [System.InvalidCastException] {
    Write-Host "Kunne ikke konvertere til tall"
}
catch {
    Write-Host "En annen type feil oppsto"
}
```

### Enkelt eksempel: Brukerinput med validering

```powershell
$gyldigInput = $false

while (-not $gyldigInput) {
    $input = Read-Host "Skriv inn et tall mellom 1 og 10"
    
    try {
        [int]$tall = $input
        
        if ($tall -ge 1 -and $tall -le 10) {
            Write-Host "Takk! Du skrev inn: $tall"
            $gyldigInput = $true
        }
        else {
            Write-Host "Tallet må være mellom 1 og 10"
        }
    }
    catch {
        Write-Host "Det var ikke et gyldig tall. Prøv igjen."
    }
}
```

---

## 7. Funksjoner

Funksjoner lar deg pakke kode som kan gjenbrukes. De gjør koden mer organisert og lettere å vedlikeholde.

### Enkel funksjon

```powershell
function Skriv-Hilsen {
    Write-Host "Hei, velkommen til PowerShell!"
}

# Kalle funksjonen
Skriv-Hilsen
```

### Funksjon med parametere

```powershell
function Skriv-PersonligHilsen {
    param(
        $Navn
    )
    Write-Host "Hei, $Navn! Velkommen!"
}

# Bruke funksjonen
Skriv-PersonligHilsen -Navn "Ola"
Skriv-PersonligHilsen -Navn "Kari"
```

### Funksjon med flere parametere

```powershell
function Beregn-Areal {
    param(
        [double]$Lengde,
        [double]$Bredde
    )
    
    $areal = $Lengde * $Bredde
    Write-Host "Arealet er: $areal kvadratmeter"
}

Beregn-Areal -Lengde 5 -Bredde 10
```

### Funksjon med returverdi

```powershell
function Multipliser-Tall {
    param(
        [int]$Tall1,
        [int]$Tall2
    )
    
    $resultat = $Tall1 * $Tall2
    return $resultat
}

# Bruke returverdien
$svar = Multipliser-Tall -Tall1 7 -Tall2 6
Write-Host "7 x 6 = $svar"
```

### Funksjon med standardverdier

```powershell
function Skriv-Melding {
    param(
        [string]$Melding = "Standard melding",
        [string]$Farge = "Green"
    )
    
    Write-Host $Melding -ForegroundColor $Farge
}

# Med standardverdier
Skriv-Melding

# Med egne verdier
Skriv-Melding -Melding "Min egen melding" -Farge "Yellow"
```

### Praktisk eksempel: Temperaturkonvertering

```powershell
function Konverter-CelsiusTilFahrenheit {
    param(
        [double]$Celsius
    )
    
    $fahrenheit = ($Celsius * 9/5) + 32
    return $fahrenheit
}

function Konverter-FahrenheitTilCelsius {
    param(
        [double]$Fahrenheit
    )
    
    $celsius = ($Fahrenheit - 32) * 5/9
    return [math]::Round($celsius, 2)
}

# Test funksjonene
$tempC = 25
$tempF = Konverter-CelsiusTilFahrenheit -Celsius $tempC
Write-Host "$tempC°C er $tempF°F"

$tempF2 = 77
$tempC2 = Konverter-FahrenheitTilCelsius -Fahrenheit $tempF2
Write-Host "$tempF2°F er $tempC2°C"
```

---

## 8. Import av datafiler

PowerShell kan enkelt importere data fra forskjellige filformater. Dette er svært nyttig for å behandle data fra andre systemer.

### Import fra CSV-fil

Først, la oss lage en enkel CSV-fil du kan teste med:

```powershell
# Lag testdata
$testData = @"
Navn,Alder,By
Anna Hansen,25,Oslo
Bjørn Olsen,30,Bergen
Cathrine Berg,28,Trondheim
Daniel Vik,22,Stavanger
"@

# Lagre til fil
$testData | Out-File -FilePath "studenter.csv" -Encoding UTF8

Write-Host "Testfil opprettet: studenter.csv"
```

Nå kan vi importere og behandle dataen:

```powershell
# Importer CSV
$studenter = Import-Csv -Path "studenter.csv" -Delimiter ","

# Vis alle studenter
foreach ($student in $studenter) {
    Write-Host "$($student.Navn) er $($student.Alder) år og bor i $($student.By)"
}
```

### Filtrere importert data

```powershell
# Import CSV
$studenter = Import-Csv -Path "studenter.csv"

# Filtrer studenter over 25 år
$elderStudenter = $studenter | Where-Object { $_.Alder -gt 25 }

Write-Host "Studenter over 25 år:"
foreach ($student in $elderStudenter) {
    Write-Host "- $($student.Navn), $($student.Alder) år"
}
```

### Import fra JSON

```powershell
# Lag JSON-testdata
$jsonData = @"
{
    "studenter": [
        {"navn": "Emma", "emner": ["IT1001", "IT1002"]},
        {"navn": "Filip", "emner": ["IT1001", "IT1003"]}
    ]
}
"@

# Lagre til fil
$jsonData | Out-File -FilePath "studenter.json" -Encoding UTF8

# Importer JSON
$data = Get-Content -Path "studenter.json" | ConvertFrom-Json

# Behandle data
foreach ($student in $data.studenter) {
    Write-Host "$($student.navn) tar følgende emner:"
    foreach ($emne in $student.emner) {
        Write-Host "  - $emne"
    }
}
```

### Eksportere data

```powershell
# Lag en liste med objekter
$personer = @(
    [PSCustomObject]@{Navn="Ola"; Alder=30; Jobb="Utvikler"}
    [PSCustomObject]@{Navn="Kari"; Alder=28; Jobb="Designer"}
    [PSCustomObject]@{Navn="Per"; Alder=35; Jobb="Konsulent"}
)

# Eksporter til CSV
$personer | Export-Csv -Path "personer.csv" -NoTypeInformation -Encoding UTF8

# Eksporter til JSON
$personer | ConvertTo-Json | Out-File -FilePath "personer.json" -Encoding UTF8

Write-Host "Data eksportert til personer.csv og personer.json"
```

---

## 9. Objektbehandling og Pipelining

PowerShell arbeider med objekter, og pipelining (`|`) lar deg sende output fra en kommando direkte til en annen.

### Grunnleggende pipelining

```powershell
# Hent prosesser og filtrer
Get-Process | Where-Object {$_.ProcessName -like "power*"}

# Telle antall
Get-Process | Measure-Object

# Sortere
Get-Service | Sort-Object Status | Select-Object -First 5
```

### Enkelt eksempel med egne objekter

```powershell
# Lag en liste med bøker
$boker = @(
    [PSCustomObject]@{Tittel="Bok 1"; Forfatter="Forfatter A"; Aar=2020}
    [PSCustomObject]@{Tittel="Bok 2"; Forfatter="Forfatter B"; Aar=2019}
    [PSCustomObject]@{Tittel="Bok 3"; Forfatter="Forfatter A"; Aar=2021}
    [PSCustomObject]@{Tittel="Bok 4"; Forfatter="Forfatter C"; Aar=2020}
)

# Filtrer bøker fra 2020
Write-Host "Bøker fra 2020:"
$boker | Where-Object {$_.Aar -eq 2020} | ForEach-Object {
    Write-Host "- $($_.Tittel) av $($_.Forfatter)"
}

# Sorter etter år
Write-Host "`nBøker sortert etter år:"
$boker | Sort-Object Aar | ForEach-Object {
    Write-Host "$($_.Aar): $($_.Tittel)"
}

# Grupper etter forfatter
Write-Host "`nBøker gruppert etter forfatter:"
$boker | Group-Object Forfatter | ForEach-Object {
    Write-Host "$($_.Name): $($_.Count) bok(er)"
}
```

### Vanlige pipeline-kommandoer

```powershell
# Where-Object - filtrering
1..10 | Where-Object {$_ -gt 5}

# Select-Object - velg egenskaper
Get-Service | Select-Object Name, Status | Select-Object -First 3

# ForEach-Object - behandle hvert objekt
1..5 | ForEach-Object {$_ * 2}

# Sort-Object - sortering
5,3,8,1,9 | Sort-Object

# Measure-Object - beregninger
1..100 | Measure-Object -Sum -Average -Maximum -Minimum
```

### Praktisk eksempel: Analyse av filer

```powershell
# Analyser filer i en mappe (bruk din egen mappe)
$mappe = $env:TEMP  # Midlertidig mappe

# Hent statistikk
$filer = Get-ChildItem -Path $mappe -File | Select-Object -First 20

Write-Host "Analyse av filer i $mappe"
Write-Host "=" * 50

# Totalt antall
$antall = ($filer | Measure-Object).Count
Write-Host "Antall filer: $antall"

# Største fil
$storst = $filer | Sort-Object Length -Descending | Select-Object -First 1
Write-Host "Største fil: $($storst.Name) - $([math]::Round($storst.Length/1KB, 2)) KB"

# Total størrelse
$totalStorrelse = ($filer | Measure-Object -Property Length -Sum).Sum
Write-Host "Total størrelse: $([math]::Round($totalStorrelse/1MB, 2)) MB"

# Gruppe etter filtype
Write-Host "`nFiler gruppert etter type:"
$filer | Group-Object Extension | Sort-Object Count -Descending | ForEach-Object {
    Write-Host "  $($_.Name): $($_.Count) fil(er)"
}
```

---

## 10. Parametre

Parametere gjør skriptene dine fleksible ved å la brukeren sende inn verdier når skriptet kjøres.

### Enkle parametere

```powershell
# Lagre dette som et skript: Skript1.ps1
param(
    [string]$Navn,
    [int]$Alder
)

Write-Host "Hei, $Navn!"
Write-Host "Du er $Alder år gammel"
```

Kjør skriptet:
```powershell
.\Skript1.ps1 -Navn "Ola" -Alder 25
```

### Obligatoriske parametere

```powershell
# Lagre som Skript2.ps1
param(
    [Parameter(Mandatory=$true)]
    [string]$Brukernavn,
    
    [Parameter(Mandatory=$false)]
    [string]$Hilsen = "Velkommen"
)

Write-Host "$Hilsen, $Brukernavn!"
```

### Parametere med validering

```powershell
# Lagre som Skript3.ps1
param(
    [Parameter(Mandatory=$true)]
    [ValidateRange(1, 120)]
    [int]$Alder,
    
    [Parameter(Mandatory=$true)]
    [ValidateSet("Oslo", "Bergen", "Trondheim", "Stavanger")]
    [string]$By
)

Write-Host "Du er $Alder år og bor i $By"
```

### Flere parametere med hjelpetekst

```powershell
# Lagre som Beregn-Stromkostnad.ps1
<#
.SYNOPSIS
    Beregner månedlig strømkostnad
    
.DESCRIPTION
    Dette skriptet beregner månedlig strømkostnad basert på forbruk og pris
    
.PARAMETER Forbruk
    Månedsforbruk i kWh (kilowattimer)
    
.PARAMETER PrisPerKwh
    Strømpris i kroner per kWh
    
.EXAMPLE
    .\Beregn-Stromkostnad.ps1 -Forbruk 500 -PrisPerKwh 1.50
#>

param(
    [Parameter(Mandatory=$true, HelpMessage="Månedsforbruk i kWh")]
    [ValidateRange(0, 10000)]
    [int]$Forbruk,
    
    [Parameter(Mandatory=$true, HelpMessage="Pris per kWh i kroner")]
    [ValidateRange(0.1, 10)]
    [double]$PrisPerKwh
)

# Beregn månedskostnad
$kostnad = [math]::Round($Forbruk * $PrisPerKwh, 2)

# Vis resultat
Write-Host "Månedlig strømkostnad: $kostnad kr"
Write-Host "Gjennomsnittlig daglig kostnad: $([math]::Round($kostnad / 30, 2)) kr"

# Kategorisering av forbruk
if ($Forbruk -lt 300) {
    Write-Host "Forbrukskategori: Lavt forbruk" -ForegroundColor Green
}
elseif ($Forbruk -lt 600) {
    Write-Host "Forbrukskategori: Normalt forbruk" -ForegroundColor Yellow
}
elseif ($Forbruk -lt 1000) {
    Write-Host "Forbrukskategori: Høyt forbruk" -ForegroundColor DarkYellow
}
else {
    Write-Host "Forbrukskategori: Svært høyt forbruk" -ForegroundColor Red
}
```

### Switch-parametere (boolean)

```powershell
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
```

Kjør med switches:
```powershell
.\Skriv-Melding.ps1 -Melding "test" -Farge -Stor
```

---

## 11. Skript som verktøy

Når du kombinerer alt du har lært, kan du lage nyttige verktøy. Her er et komplett eksempel.

### Eksempel: Student-administrasjonsverktøy

```powershell
# Lagre som Student-Admin.ps1

<#
.SYNOPSIS
    Enkelt verktøy for å administrere studenter
    
.DESCRIPTION
    Dette skriptet lar deg legge til, vise og søke etter studenter
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("Legg til", "Vis alle", "Søk", "Avslutt")]
    [string]$Handling
)

# Filsti for studentdata
$dataFil = "studenter_data.csv"

# Funksjon for å legge til student
function LeggTil-Student {
    Write-Host "`n=== Legg til ny student ===" -ForegroundColor Green
    
    $navn = Read-Host "Navn"
    $alder = Read-Host "Alder"
    $studieprogram = Read-Host "Studieprogram"
    
    # Lag objekt
    $student = [PSCustomObject]@{
        Navn = $navn
        Alder = $alder
        Studieprogram = $studieprogram
        Registrert = (Get-Date -Format "yyyy-MM-dd")
    }
    
    # Lagre til fil
    if (Test-Path $dataFil) {
        $student | Export-Csv -Path $dataFil -Append -NoTypeInformation -Encoding UTF8
    }
    else {
        $student | Export-Csv -Path $dataFil -NoTypeInformation -Encoding UTF8
    }
    
    Write-Host "Student lagt til!" -ForegroundColor Green
}

# Funksjon for å vise alle studenter
function Vis-AlleStudenter {
    Write-Host "`n=== Alle studenter ===" -ForegroundColor Cyan
    
    if (Test-Path $dataFil) {
        $studenter = Import-Csv -Path $dataFil
        
        if ($studenter.Count -eq 0) {
            Write-Host "Ingen studenter registrert ennå" -ForegroundColor Yellow
            return
        }
        
        foreach ($student in $studenter) {
            Write-Host "`nNavn: $($student.Navn)"
            Write-Host "Alder: $($student.Alder)"
            Write-Host "Studieprogram: $($student.Studieprogram)"
            Write-Host "Registrert: $($student.Registrert)"
            Write-Host "-" * 40
        }
        
        Write-Host "`nTotalt: $($studenter.Count) student(er)" -ForegroundColor Green
    }
    else {
        Write-Host "Ingen studenter registrert ennå" -ForegroundColor Yellow
    }
}

# Funksjon for å søke etter student
function Sok-Student {
    Write-Host "`n=== Søk etter student ===" -ForegroundColor Cyan
    
    if (-not (Test-Path $dataFil)) {
        Write-Host "Ingen studenter registrert ennå" -ForegroundColor Yellow
        return
    }
    
    $sokeord = Read-Host "Skriv inn navn (helt eller delvis)"
    $studenter = Import-Csv -Path $dataFil
    
    $resultat = $studenter | Where-Object {$_.Navn -like "*$sokeord*"}
    
    if ($resultat) {
        Write-Host "`nFant $($resultat.Count) student(er):" -ForegroundColor Green
        foreach ($student in $resultat) {
            Write-Host "`nNavn: $($student.Navn)"
            Write-Host "Alder: $($student.Alder)"
            Write-Host "Studieprogram: $($student.Studieprogram)"
            Write-Host "Registrert: $($student.Registrert)"
            Write-Host "-" * 40
        }
    }
    else {
        Write-Host "Ingen studenter funnet" -ForegroundColor Yellow
    }
}

# Hovedmeny
function Vis-Meny {
    while ($true) {
        Write-Host "`n╔══════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║   STUDENT-ADMINISTRASJON             ║" -ForegroundColor Cyan
        Write-Host "╚══════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host "1. Legg til ny student"
        Write-Host "2. Vis alle studenter"
        Write-Host "3. Søk etter student"
        Write-Host "4. Avslutt"
        Write-Host ""
        
        $valg = Read-Host "Velg et alternativ (1-4)"
        
        switch ($valg) {
            "1" { LeggTil-Student }
            "2" { Vis-AlleStudenter }
            "3" { Sok-Student }
            "4" { 
                Write-Host "`nAvslutter..." -ForegroundColor Yellow
                return
            }
            default { 
                Write-Host "Ugyldig valg, prøv igjen" -ForegroundColor Red
            }
        }
    }
}

# Start programmet
if ($Handling) {
    switch ($Handling) {
        "Legg til" { LeggTil-Student }
        "Vis alle" { Vis-AlleStudenter }
        "Søk" { Sok-Student }
        "Avslutt" { exit }
    }
}
else {
    Vis-Meny
}
```

### Kjøre verktøyet

```powershell
# Interaktiv modus
.\Student-Admin.ps1

# Eller med parameter
.\Student-Admin.ps1 -Handling "Vis alle"
```

### Enklere eksempel: Fil-organisator

```powershell
# Lagre som Organiser-Filer.ps1

<#
.SYNOPSIS
    Organiserer filer i mapper basert på filtype
#>

param(
    [Parameter(Mandatory=$true)]
    [string]$KildeMappe,
    
    [switch]$Testmodus
)

function Organiser-Filer {
    param($Mappe)
    
    try {
        # Sjekk at mappen eksisterer
        if (-not (Test-Path $Mappe)) {
            throw "Mappen eksisterer ikke: $Mappe"
        }
        
        # Hent alle filer
        $filer = Get-ChildItem -Path $Mappe -File
        
        Write-Host "Fant $($filer.Count) filer" -ForegroundColor Cyan
        
        foreach ($fil in $filer) {
            $filtype = $fil.Extension.TrimStart('.')
            
            if ([string]::IsNullOrEmpty($filtype)) {
                $filtype = "Ingen-extension"
            }
            
            $destinasjonMappe = Join-Path $Mappe $filtype
            
            # Opprett mappe hvis den ikke finnes
            if (-not (Test-Path $destinasjonMappe)) {
                if ($Testmodus) {
                    Write-Host "Ville opprettet mappe: $destinasjonMappe" -ForegroundColor Yellow
                }
                else {
                    New-Item -Path $destinasjonMappe -ItemType Directory | Out-Null
                    Write-Host "Opprettet mappe: $filtype" -ForegroundColor Green
                }
            }
            
            # Flytt fil
            $destinasjon = Join-Path $destinasjonMappe $fil.Name
            
            if ($Testmodus) {
                Write-Host "Ville flyttet: $($fil.Name) -> $filtype\" -ForegroundColor Yellow
            }
            else {
                Move-Item -Path $fil.FullName -Destination $destinasjon
                Write-Host "Flyttet: $($fil.Name) -> $filtype\" -ForegroundColor Green
            }
        }
        
        if ($Testmodus) {
            Write-Host "`nDette var en test. Ingen filer ble flyttet." -ForegroundColor Yellow
        }
        else {
            Write-Host "`nFiler organisert!" -ForegroundColor Green
        }
    }
    catch {
        Write-Host "Feil oppsto: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Kjør organisering
Organiser-Filer -Mappe $KildeMappe
```

Kjør med:
```powershell
# Testmodus først for å se hva som vil skje
.\Organiser-Filer.ps1 -KildeMappe "C:\MinMappe" -Testmodus

# Kjør for ekte
.\Organiser-Filer.ps1 -KildeMappe "C:\MinMappe"
```

---

## Oppsummering og beste praksis

### Viktige punkter å huske:

1. **Variabler**: Start alltid med `$` og bruk beskrivende navn
2. **If/Else**: Bruk for enkle valg og beslutninger
3. **Switch**: Bruk for mange mulige verdier
4. **Løkker**: ForEach for samlinger, For når du vet antall iterasjoner
5. **Try/Catch**: Fang alltid feil i produksjonsskrip
6. **Funksjoner**: Bruk for gjenbrukbar kode
7. **Pipelining**: Utnytt kraften i objektbehandling
8. **Parametere**: Gjør skriptene fleksible
9. **Kommentarer**: Kommenter koden din!
10. **Testing**: Test alltid skriptene grundig

### Gode vaner:

```powershell
# ✅ GODT: Beskrivende variabelnavn
$studentNavn = "Ola Nordmann"

# ❌ DÅRLIG: Uklare variabelnavn
$x = "Ola Nordmann"

# ✅ GODT: Kommentarer
# Henter alle aktive brukere fra systemet
$brukere = Get-ADUser -Filter {Enabled -eq $true}

# ✅ GODT: Feilhåndtering
try {
    $data = Import-Csv -Path $filsti -ErrorAction Stop
}
catch {
    Write-Host "Kunne ikke lese fil: $($_.Exception.Message)"
    exit
}

# ✅ GODT: Bruk av funksjoner for gjenbruk
function Get-DiskInfo {
    param($DriveLetter)
    
    Get-PSDrive $DriveLetter | Select-Object Used, Free
}
```

### Egenlæring:

1. Øv på eksemplene i denne veiledningen
2. Prøv å lage egne små skript for daglige oppgaver
3. Utforsk PowerShell-moduler for spesifikke oppgaver

---

## Tilleggsressurser

- **Microsoft Docs**: https://docs.microsoft.com/powershell
- **PowerShell Gallery**: https://www.powershellgallery.com
- **SS64 PowerShell**: https://ss64.com/ps/

Lykke til med PowerShell! 🚀
