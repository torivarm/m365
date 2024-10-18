# PowerShell for Exchange Online Administrasjon

## Administrere Postbokser

I Exchange Online er administrasjon av postbokser en kritisk oppgave for systemadministratorer. PowerShell tilbyr kraftige verktøy for å effektivt håndtere disse oppgavene, spesielt når det gjelder operasjoner i stor skala.

### Opprette og Konfigurere Postbokser

For å opprette nye postbokser bruker vi `New-Mailbox` cmdlet. Denne kommandoen er essensiell når man skal sette opp e-postkontoer for nye ansatte eller opprette spesielle postbokser for prosjekter eller avdelinger. 

```powershell
New-Mailbox -Name "Ola Nordmann" -Alias ola.nordmann -UserPrincipalName ola.nordmann@bedrift.no -Password (ConvertTo-SecureString -String "P@ssw0rd" -AsPlainText -Force) -ResetPasswordOnNextLogon $true
```

Denne kommandoen oppretter en ny postboks for Ola Nordmann. Den setter opp brukernavnet, e-postadressen, og et midlertidig passord som må endres ved første pålogging. `UserPrincipalName` er viktig da den ofte brukes som påloggingsinformasjon for Microsoft 365-tjenester.

For å modifisere eksisterende postbokser, bruker vi `Set-Mailbox` cmdlet. Denne kommandoen er utrolig allsidig og kan brukes til å endre nesten alle aspekter ved en postboks.

```powershell
Set-Mailbox -Identity ola.nordmann@bedrift.no -ProhibitSendQuota 10GB -ProhibitSendReceiveQuota 12GB -IssueWarningQuota 9GB
```

I dette eksempelet setter vi kvoter for Ola Nordmanns postboks. Vi definerer grenser for når brukeren ikke lenger kan sende e-post (10GB), når de ikke kan sende eller motta (12GB), og når de skal få en advarsel (9GB). Dette er nyttig for å administrere lagringsplassen effektivt og forhindre at enkelte brukere overforbruker ressurser.

### Administrere Postbokstillatelser

Håndtering av tillatelser er en annen viktig oppgave. `Add-MailboxPermission` cmdlet brukes for å gi andre brukere tilgang til en postboks, noe som er spesielt nyttig for ledere og deres assistenter.

```powershell
Add-MailboxPermission -Identity "Leder Ledersen" -User "Assistent Assistentsen" -AccessRights FullAccess -InheritanceType All
```

Denne kommandoen gir Assistent Assistentsen full tilgang til Leder Ledersens postboks. "FullAccess" betyr at assistenten kan lese, sende og administrere e-poster på vegne av lederen. "InheritanceType All" sikrer at tillatelsene også gjelder for undermapper.

For å se eksisterende tillatelser, bruker vi `Get-MailboxPermission`:

```powershell
Get-MailboxPermission -Identity "Leder Ledersen"
```

Dette vil liste opp alle som har tilgang til Leder Ledersens postboks, inkludert hvilke spesifikke rettigheter de har.

### Konfigurere Avanserte Postboksfunksjoner

Exchange Online tilbyr avanserte funksjoner som arkivpostbokser og rettslig sperre. Disse kan aktiveres og konfigureres ved hjelp av `Set-Mailbox` cmdlet.

For å aktivere en arkivpostboks:

```powershell
Set-Mailbox -Identity ola.nordmann@bedrift.no -ArchiveDatabase (Get-MailboxDatabase) -ArchiveQuota 100GB -ArchiveWarningQuota 90GB
```

Dette kommandoeksempelet aktiverer arkivpostboksen for Ola Nordmann, setter en kvote på 100GB, og en advarsel når 90GB er nådd. Arkivpostbokser er nyttige for å holde hovedpostboksen ryddig samtidig som man beholder eldre e-poster tilgjengelige.

For å sette en postboks på rettslig sperre:

```powershell
Set-Mailbox -Identity ola.nordmann@bedrift.no -LitigationHoldEnabled $true -LitigationHoldDuration 365
```

Denne kommandoen aktiverer rettslig sperre på Ola Nordmanns postboks for ett år. Dette sikrer at alle e-poster og elementer beholdes, selv om brukeren sletter dem, noe som er kritisk for juridiske og etterforskningsmessige formål.

## Administrere Distribusjonsgrupper og E-postaktiverte Sikkerhetsgrupper

Grupper er essensielle for effektiv kommunikasjon og tilgangsstyring i organisasjoner. PowerShell gir administratorer muligheten til å opprette og administrere disse gruppene effektivt.

### Opprette og Administrere Grupper

For å opprette en ny distribusjonsgruppe, bruker vi `New-DistributionGroup` cmdlet:

```powershell
New-DistributionGroup -Name "Salgsavdeling" -Alias salg -PrimarySmtpAddress salg@bedrift.no -Members ola.nordmann@bedrift.no,kari.nordmann@bedrift.no
```

Denne kommandoen oppretter en ny distribusjonsgruppe kalt "Salgsavdeling" med to initielle medlemmer. Distribusjonsgrupper er ideelle for å sende e-poster til flere mottakere samtidig.

For å opprette en dynamisk distribusjonsgruppe som automatisk inkluderer medlemmer basert på attributter, bruker vi `New-DynamicDistributionGroup`:

```powershell
New-DynamicDistributionGroup -Name "Alle i Oslo" -IncludedRecipients MailboxUsers -ConditionalStateOrProvince Oslo
```

Denne gruppen vil automatisk inkludere alle brukere med postbokser som har Oslo angitt som sitt fylke. Dynamiske grupper er nyttige for å håndtere medlemskap i store organisasjoner hvor manuell oppdatering ville vært tidkrevende.

### Administrere Gruppemedlemskap

For å legge til medlemmer i en eksisterende gruppe, bruker vi `Add-DistributionGroupMember`:

```powershell
Add-DistributionGroupMember -Identity "Salgsavdeling" -Member ny.ansatt@bedrift.no
```

Denne kommandoen legger til en ny ansatt i salgsavdelingens distribusjonsgruppe. For å fjerne medlemmer, bruker vi tilsvarende `Remove-DistributionGroupMember`.

For å se medlemmene i en gruppe, bruker vi `Get-DistributionGroupMember`:

```powershell
Get-DistributionGroupMember -Identity "Salgsavdeling"
```

Dette vil liste opp alle medlemmene i Salgsavdeling-gruppen, noe som er nyttig for å verifisere gruppens sammensetning.

### Konvertere Grupper

I noen tilfeller kan det være nødvendig å konvertere en distribusjonsgruppe til en e-postaktivert sikkerhetsgruppe for økt sikkerhet. Dette kan gjøres ved å først opprette en ny e-postaktivert sikkerhetsgruppe og deretter kopiere medlemmene:

```powershell
New-MailEnabledSecurityGroup -Name "Salg Sikkerhet" -Alias salgsikkerhet -PrimarySmtpAddress salgsikkerhet@bedrift.no
$medlemmer = Get-DistributionGroupMember -Identity "Salgsavdeling"
$medlemmer | ForEach-Object {Add-DistributionGroupMember -Identity "Salg Sikkerhet" -Member $_.PrimarySmtpAddress}
```

Disse kommandoene oppretter først en ny e-postaktivert sikkerhetsgruppe, henter deretter medlemmene fra den originale distribusjonsgruppen, og legger dem til i den nye sikkerhetsgruppen. E-postaktiverte sikkerhetsgrupper kombinerer fordelene med distribusjonsgrupper og sikkerhetsgrupper, noe som gir mer granulær kontroll over tilganger og kommunikasjon.

## Administrere E-postflytregler (Transportregler)

E-postflytregler, også kjent som transportregler, er kraftige verktøy for å kontrollere e-postflyten i organisasjonen. De kan brukes til å implementere sikkerhetsretningslinjer, sikre samsvar med forskrifter, og automatisere e-posthåndtering.

### Opprette og Administrere E-postflytregler

For å opprette en ny e-postflytregel, bruker vi `New-TransportRule` cmdlet. Her er et eksempel på en regel som legger til en ansvarsfraskrivelse på alle utgående e-poster:

```powershell
New-TransportRule -Name "Legg til ansvarsfraskrivelse" -FromScope "InOrganization" -SentToScope "NotInOrganization" -ApplyHtmlDisclaimerText "<p>Denne e-posten er konfidensiell og kun ment for den tiltenkte mottakeren.</p>" -ApplyHtmlDisclaimerLocation "Append" -ApplyHtmlDisclaimerFallbackAction Wrap
```

Denne regelen legger til en HTML-formatert ansvarsfraskrivelse på alle e-poster sendt fra organisasjonen til eksterne mottakere. "Append" betyr at ansvarsfraskrivelsen legges til på slutten av e-posten, og "Wrap" er en reserveløsning hvis e-posten ikke kan modifiseres direkte.

For å forhindre datatap kan vi opprette en regel som blokkerer utsendelse av sensitive opplysninger:

```powershell
New-TransportRule -Name "Blokker kredittkortnumre" -FromScope "InOrganization" -SentToScope "NotInOrganization" -MessageContainsDataClassifications @{Name="Credit Card Number"} -RejectMessageReasonText "E-posten ble blokkert fordi den kan inneholde kredittkortnumre." -Mode Enforce
```

Denne regelen søker etter mønstre som ligner kredittkortnumre i utgående e-poster og blokkerer dem hvis de blir funnet. Den gir også en forklaring til avsenderen om hvorfor e-posten ble blokkert.

### Modifisere Eksisterende Regler

For å endre en eksisterende regel, bruker vi `Set-TransportRule`:

```powershell
Set-TransportRule -Identity "Legg til ansvarsfraskrivelse" -ApplyHtmlDisclaimerText "<p>Oppdatert: Denne e-posten er konfidensiell og kun ment for den tiltenkte mottakeren. Ikke videresend uten tillatelse.</p>"
```

Denne kommandoen oppdaterer teksten i ansvarsfraskrivelsen for den tidligere opprettede regelen.

### Vise og Diagnostisere Regler

For å se alle aktive transportregler, kan vi bruke `Get-TransportRule`:

```powershell
Get-TransportRule | Format-Table Name, State, Priority
```

Dette gir en oversikt over alle regler, deres status (aktiv eller inaktiv), og deres prioritet. Prioriteten er viktig fordi regler anvendes i prioritert rekkefølge, og prosesseringen stopper når en regel matches, med mindre annet er spesifisert.

For å diagnostisere hvordan regler påvirker spesifikke e-poster, kan vi bruke `Test-TransportRule`:

```powershell
Test-TransportRule -SenderAddress ola.nordmann@bedrift.no -RecipientAddress ekstern@example.com -Message "Test melding med sensitiv informasjon: 1234-5678-9012-3456"
```

Denne kommandoen simulerer sending av en e-post og viser hvilke regler som ville blitt utløst, noe som er nyttig for feilsøking og verifisering av reglenes funksjonalitet.

Gjennom effektiv bruk av disse PowerShell-cmdletene kan systemadministratorer raskt og effektivt administrere Exchange Online-miljøer, automatisere repetitive oppgaver, og implementere organisasjonens retningslinjer for e-postkommunikasjon og sikkerhet.

# PowerShell for Exchange Online Administrasjon

[Previous content remains unchanged]

## Administrere Microsoft 365 Grupper

Microsoft 365 Grupper er en viktig del av mange organisasjoners samarbeidsinfrastruktur. Disse gruppene kombinerer funksjonaliteten til distribusjonsgrupper med tilleggsfunksjoner som delte innbokser, kalendere, og SharePoint-områder. Som administrator er det viktig å kunne effektivt administrere disse gruppene, og PowerShell gir oss verktøyene for å gjøre dette på en effektiv måte.

### Liste opp alle Microsoft 365 Grupper

For å få en oversikt over alle Microsoft 365 Grupper i din Exchange Online-miljø, kan du bruke `Get-UnifiedGroup` cmdlet. Denne kommandoen gir deg grunnleggende informasjon om hver gruppe. Her er et eksempel på hvordan du kan bruke denne kommandoen:

```powershell
Get-UnifiedGroup | Select-Object DisplayName, PrimarySmtpAddress, ExternalDirectoryObjectId
```

Når du kjører denne kommandoen, vil PowerShell returnere en liste over alle M365 Grupper i miljøet ditt. For hver gruppe vil du se visningsnavnet, den primære e-postadressen, og den eksterne katalog-objekt-ID-en. Den eksterne katalog-objekt-ID-en er spesielt nyttig fordi den er den unike identifikatoren for gruppen på tvers av alle Microsoft 365-tjenester.

### Finne Gruppepostbokser

Hver Microsoft 365 Gruppe har en tilknyttet gruppepostboks. For å finne spesifikk informasjon om disse gruppepostboksene, kan du bruke `Get-Mailbox` cmdlet med `-GroupMailbox` parameteren. Her er hvordan du kan gjøre dette:

```powershell
Get-Mailbox -GroupMailbox | Select-Object DisplayName, PrimarySmtpAddress, ExternalDirectoryObjectId
```

Denne kommandoen vil gi deg en liste over alle gruppepostbokser, inkludert deres visningsnavn, primære e-postadresser, og eksterne katalog-objekt-ID-er. Dette er nyttig når du trenger å administrere eller feilsøke problemer spesifikt relatert til gruppepostbokser.

### Detaljert Informasjon om en Spesifikk Gruppe

Noen ganger trenger du mer detaljert informasjon om en bestemt gruppe. I slike tilfeller kan du bruke `Get-UnifiedGroup` cmdlet med `-Identity` parameteren, og sende resultatet til `Format-List` for å få en mer omfattende visning. Her er et eksempel:

```powershell
Get-UnifiedGroup -Identity "GruppeNavn" | Format-List
```

I denne kommandoen må du erstatte "GruppeNavn" med det faktiske navnet eller e-postadressen til gruppen du er interessert i. Denne kommandoen vil gi deg en detaljert liste over alle egenskapene til den spesifikke gruppen, inkludert innstillinger for medlemskap, tillatelser, og tilknyttede ressurser.

### Eksportere Gruppeinformasjon til CSV

For rapportering eller videre analyse kan det være nyttig å eksportere informasjonen om M365 Grupper til en CSV-fil. Dette kan du gjøre med følgende kommando:

```powershell
Get-UnifiedGroup | Select-Object DisplayName, PrimarySmtpAddress, ExternalDirectoryObjectId | Export-Csv -Path "C:\M365Grupper.csv" -NoTypeInformation
```

Denne kommandoen vil opprette en CSV-fil med navnet "M365Grupper.csv" i C:-katalogen. Du kan selvfølgelig endre filbanen etter behov. Filen vil inneholde visningsnavnet, den primære e-postadressen, og den eksterne katalog-objekt-ID-en for hver M365 Gruppe i miljøet ditt.

### Filtrere Grupperesultater

I større organisasjoner kan antallet M365 Grupper være betydelig, og det kan være nyttig å filtrere resultatene for å finne spesifikke grupper. Du kan bruke `-Filter` parameteren med `Get-UnifiedGroup` cmdlet for å oppnå dette. Her er et eksempel:

```powershell
Get-UnifiedGroup -Filter {DisplayName -like "*Prosjekt*"} | Select-Object DisplayName, PrimarySmtpAddress
```

Denne kommandoen vil returnere en liste over grupper som har ordet "Prosjekt" i visningsnavnet sitt, sammen med deres primære e-postadresser. Du kan tilpasse filteret etter dine spesifikke behov.

Det er viktig å merke seg at for å kjøre disse kommandoene, må du ha de nødvendige administrative rettighetene i ditt Microsoft 365-miljø. Hvis du støter på problemer med tillatelser, kan det være nødvendig å kontakte din globale administrator.

Ved å bruke disse PowerShell-kommandoene effektivt, kan du raskt få oversikt over og administrere Microsoft 365 Grupper i ditt Exchange Online-miljø. Dette er spesielt nyttig for å holde orden i større miljøer, utføre revisjoner, eller feilsøke problemer relatert til gruppepostbokser og -tillatelser.