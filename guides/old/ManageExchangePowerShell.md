# Administrasjon av postbokser og brukere i Microsoft 365 med PowerShell

Dette dokumentet fokuserer på hvordan systemadministratorer kan bruke PowerShell til å administrere brukere og postbokser i Microsoft 365, spesielt med fokus på Exchange Online. Studentene dine har allerede grunnleggende forståelse av PowerShell, så målet med dette dokumentet er å dekke vanlige bruksscenarier og de tilhørende kommandoene som benyttes til å utføre administrative oppgaver. Her vil vi gjennomgå administrasjon av postbokser, distribusjonsgrupper, e-postaktiverte sikkerhetsgrupper og mail flow-regler (transportregler).

## Administrasjon av postbokser

### Opprettelse og konfigurering av postbokser
En systemadministrator må ofte opprette nye postbokser for ansatte. Dette inkluderer å spesifisere grunnleggende informasjon som e-postadresse, alias og visningsnavn. Dette er en viktig oppgave når nye ansatte begynner i selskapet. Ved bruk av PowerShell kan man opprette postbokser på en effektiv måte, spesielt i større organisasjoner hvor det er behov for å automatisere prosessen for mange brukere.

For å opprette en ny postboks bruker man kommandoen `New-Mailbox`, som lar deg spesifisere detaljene for den nye brukeren, inkludert brukerens e-postadresse, alias og navn.

### Sette kvoter og begrensninger på postbokser
For å sikre at ingen enkeltbruker utnytter for mye lagringsplass på serveren, må systemadministratorer sette kvoter og begrensninger på postbokser. Dette inkluderer innstillinger for når brukeren mottar en advarsel om at postkassen er full, samt grenser for når de ikke lenger kan sende eller motta e-post.

Ved bruk av `Set-Mailbox`-kommandoen kan man justere disse kvotene for hver bruker individuelt. Dette er nyttig i organisasjoner hvor noen brukere, som ledere eller de som jobber med store mengder e-postdata, trenger høyere kvoter enn andre.

### Administrasjon av postboksrettigheter
Noen ganger må en bruker ha tilgang til en annen persons postboks, enten for å lese e-poster eller for å sende på vegne av noen andre. Dette er et vanlig scenario, for eksempel når en assistent trenger tilgang til en leders e-post. Med PowerShell kan systemadministratorer enkelt administrere disse tillatelsene.

Ved hjelp av kommandoene `Add-MailboxPermission` og `Remove-MailboxPermission` kan administratorer tildele eller fjerne rettigheter som gir tilgang til andre brukeres postbokser. Dette kan inkludere full tilgang eller spesifikke tillatelser som "SendAs" eller "SendOnBehalf".

### Konfigurering av postboksfunksjoner (f.eks. arkivpostbokser og rettslig tilbakeholdelse)
For å sikre overholdelse av lovgivning og intern politikk, kan organisasjoner aktivere spesielle postboksfunksjoner som arkivpostbokser og rettslig tilbakeholdelse (Litigation Hold). Arkivpostbokser gir ekstra lagringsplass for eldre e-post, mens rettslig tilbakeholdelse sørger for at innhold ikke slettes, selv om brukeren forsøker å fjerne e-poster.

Ved hjelp av `Enable-Mailbox` kan administratorer aktivere arkivpostbokser, mens `Set-Mailbox` lar administratorer sette postboksen i rettslig tilbakeholdelse. Dette er avgjørende for organisasjoner som er pålagt å beholde e-poster i en viss periode for juridiske formål.

## Distribusjonsgrupper og e-postaktiverte sikkerhetsgrupper

### Opprettelse og administrasjon av grupper
Distribusjonsgrupper brukes til å sende e-post til flere mottakere samtidig, mens e-postaktiverte sikkerhetsgrupper også brukes til å tildele tillatelser. En systemadministrator vil ofte opprette nye grupper for avdelinger eller prosjekter for å forenkle kommunikasjon og administrasjon.

Ved å bruke `New-DistributionGroup` kan administratorer opprette nye distribusjonsgrupper. Grupper kan konfigureres med e-postadresser, administratorer og andre egenskaper som bestemmer hvordan e-post blir distribuert i organisasjonen.

### Legge til og fjerne medlemmer
Når brukere blir med i eller forlater avdelinger eller prosjekter, må administratoren kunne legge til eller fjerne dem fra relevante grupper. Dette er viktig for å sikre at kun riktige brukere får tilgang til informasjon og e-postkommunikasjon.

Med `Add-DistributionGroupMember` kan man legge til brukere i en distribusjonsgruppe, mens `Remove-DistributionGroupMember` lar deg fjerne brukere fra gruppen. Dette sikrer at gruppemedlemskapet holdes oppdatert, noe som er avgjørende for riktig tilgangsstyring.

### Endring av gruppeegenskaper
Noen ganger trenger administratorer å endre innstillingene for en distribusjonsgruppe. Dette kan inkludere å endre e-postadressen til gruppen eller aktivere moderering slik at en bestemt person må godkjenne e-poster før de sendes til gruppen.

Ved å bruke `Set-DistributionGroup` kan administratorer enkelt oppdatere gruppens egenskaper. Dette kan inkludere endringer i innstillingene for moderering, begrensninger på hvem som kan sende e-post til gruppen, og andre viktige konfigurasjoner.

## Mail flow-regler (Transportregler)

### Opprettelse og administrasjon av mail flow-regler
Mail flow-regler, også kjent som transportregler, er nyttige for å kontrollere hvordan e-post flyter gjennom organisasjonen. Dette kan inkludere å legge til ansvarsfraskrivelser på utgående e-post, blokkere visse vedleggstyper eller forhindre at sensitiv informasjon sendes utenfor organisasjonen.

Ved bruk av `New-TransportRule` kan systemadministratorer lage regler som styrer hvordan e-post håndteres. For eksempel kan man lage en regel som legger til en ansvarsfraskrivelse på alle e-poster sendt til eksterne mottakere.

### Vanlige scenarier for mail flow-regler
Det finnes mange vanlige scenarier hvor mail flow-regler kan brukes. For eksempel kan man forhindre at bestemte filtyper, som .exe-filer, sendes via e-post, eller man kan blokkere e-poster som inneholder spesifikke nøkkelord i emnet eller e-postteksten.

Ved hjelp av `New-TransportRule` kan administratorer enkelt implementere slike regler. Dette kan bidra til å beskytte organisasjonen mot farlige vedlegg eller forhindre at sensitiv informasjon lekkes via e-post.

## Automatisering av daglige administrasjonsoppgaver

Systemadministratorer står ofte overfor repeterende oppgaver, som å lage rapporter, administrere brukere eller utføre vedlikeholdsoppgaver på postbokser. Ved å bruke PowerShell kan disse oppgavene automatiseres, noe som reduserer tid og innsats, samtidig som man sikrer nøyaktighet.

Ved å kombinere forskjellige kommandoer og bruke scripting-funksjonene i PowerShell kan man sette opp automatiserte oppgaver. Dette kan inkludere alt fra å eksportere rapporter til CSV-filer til å planlegge daglige eller ukentlige vedlikeholdsjobber som kjører automatisk.

For eksempel kan en administrator sette opp et script som automatisk eksporterer størrelsene på alle postboksene i organisasjonen til en CSV-fil hver uke. Dette gir en enkel måte å overvåke bruk av lagringsplass på uten manuell inngripen.

## Konklusjon
Denne gjennomgangen har gitt innsikt i typiske oppgaver som systemadministratorer utfører i Microsoft 365 og Exchange Online, samt hvordan disse oppgavene kan utføres ved hjelp av PowerShell. Fra å opprette og administrere postbokser til å sette opp mail flow-regler og automatisere oppgaver, kan PowerShell kraftig effektivisere daglig administrasjon og gi bedre kontroll over systemet. Ved å fokusere på praktiske eksempler og reelle bruksområder, vil studentene få en dypere forståelse av hvordan de kan bruke PowerShell i en organisasjonsmiljø.
