# Datan tuonti ja vienti, import- ja export-toiminnot

Yllättävän usein pitää dataa siirtää toiseen tietokantaan, sovellukseen, API-rajapintaan jne., tai omaan tietokantaan jostain muusta järjestelmästä. Tässä ei käsitellä ohjelmallisia ratkaisuja, vaan pohditaan hieman miten dataa voidaan siirtää esimerkiksi CSV-tiedostojen avulla SQL Serveriin (import) tai sieltä pois (export). Toki on muitakin siirtoformaatteja, esim. XML. 

### Serverin Import & Export -mahdollisuudet
🧰 1. SQL Server Import and Export Wizard (graafinen työkalu)
Käynnistyy SSMS:stä (hiiren oikealla tietokannan päällä → Tasks → Import/Export Data). Siirtomuotoina tai kohteina:
- Excel, CSV
- Toinen SQL Server
- ODBC- ja OLE DB -yhteydet
- Access-tiedostot
- Flat file (*.txt, *.csv)

✅ Helppo käyttää, hyvä ad-hoc-siirtoihin
❌ Vähemmän kontrollia, ei toistuviin/monimutkaisiin prosesseihin

📦 2. SQL Server Integration Services (SSIS)
Microsoftin ETL-työkalu datan siirtämiseen, muuntamiseen ja lataamiseen
- Tukee laajasti formaatteja ja ulkoisia järjestelmiä
- Toimii sekä SQL Server Management Studion että Visual Studion kautta
- Vaatii Visual Studion asennuksen ja tarvittavat osat (Data storage and processing). Community Edition on ilmainen ja riittää SSIS-projektien tekemiseen. Visua Studio on eri tuote kuin VS Code!

✅ Hyvin tehokas ja automatisoitavissa
✅ Tukee virheenkäsittelyä, ehtoja, muunnoksia
❌ Vaatii lisäasennuksia ja osaamista

🧮 3. T-SQL (BULK INSERT, OPENROWSET, BCP)
🔹 BULK INSERT – Tiedoston tuonti SQL-tauluun
```sql
BULK INSERT dbo.Tuotteet
FROM 'C:\data\tuotteet.csv'
WITH (
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    FIRSTROW = 2
);
```
🔹 OPENROWSET – Lue tiedosto tai ulkoinen lähde suoraan
```sql
SELECT *
FROM OPENROWSET(
    BULK 'C:\data\tuotteet.csv',
    FORMAT = 'CSV',
    FIRSTROW = 2
) AS Tuotteet;
```
🔹 bcp – Komentorivipohjainen työkalu (Bulk Copy Program)
```bash
bcp Tietokanta.dbo.Tuotteet out tuotteet.csv -c -t, -S serveri -T
```

✅ Nopeita ja hyviä automatisointiin
❌ Vaativat enemmän käsityötä ja virheidenhallintaa

🌐 4. Linked Servers
Mahdollistaa kyselyt muihin SQL Servereihin tai muihin järjestelmiin suoraan T-SQL:llä
```sql
SELECT *
FROM [ToinenPalvelin].[Tietokanta].[dbo].[Asiakkaat];
```
✅ Soveltuu jatkuvaan integraatioon
❌ Ylläpito ja suorituskyky voivat olla haasteita

☁️ 5. Azure Data Factory (pilviratkaisu)
Soveltuu erityisesti jos käytät Azure SQL, Blob Storagea tai muita pilvipalveluita
- Tukee satoja eri lähteitä: Google BigQuery, Amazon S3, SAP, Salesforce jne.

✅ Skaalautuva ja moderni
❌ Vaatii Azure-ympäristön ja erillistä konfiguraatiota

📝 5. Muita keinoja
- ohjelmalliset ratkaisut tai kolmannen osapuolen sovellukset

## ETL
Edellä oli mainittu ETL-prosessi. Pelkän datan import/export-toimintojen ohella tehdään 'laajempia' tiedon keräys tai muokkaustoimenpiteitä tietovarastojen välillä. Tästä käytetään termiä ETL (Extract-Transform-Load):
1. Extract (Poiminta): Tiedon kerääminen eri lähteistä, kuten tietokannoista, sovelluksista tai tiedostoista.
2. Transform (Muunnos): Tiedon muokkaaminen, kuten puhdistus, yhdistäminen ja muotoilu, jotta se sopii kohdejärjestelmään.
3. Load (Lataus): Muunnetun tiedon tallentaminen kohdejärjestelmään, kuten tietovarastoon tai analytiikkatyökaluun.​

Tämä prosessi on keskeinen osa tiedonhallintaa ja analytiikkaa, sillä se mahdollistaa tiedon yhdistämisen eri lähteistä ja sen hyödyntämisen päätöksenteossa. Lisää yleistä tietoa löytyy esimerkiksi [wikipediasta](https://en.wikipedia.org/wiki/Extract%2C_transform%2C_load).


### Esimerkki CSV- tiedoston import-toiminnosta:

CSV-tiedoston *tuotteet.csv* sisältö:
```txt
TuoteID,Tuotenimi,Hinta
1,Kahvi,5.95
2,Tee,3.75
3,Mehu,2.99
```

Miten tämä sisältö tuodaan Tuotteet-tauluun? Tai miten Tuotteet.csv voidaan muodostaa tietokannan datan perusteella?
Koska tällä kertaa ei ole asennettuna Visual Studiota eikä siis saada tehtyä SSIS-pakettia, käytetään toista tapaa. Tietokannasta voidaan siirtää dataa muualle tai tuoda dataa erilaisista tietolähteistä toiminnolla <Tietokanta> | Tasks | Import/Export Data..., kokeillaan siis tätä.

### Datan Export

1. valitse tietokanta ==> Tasks -> Export Data... (--> SQL Server Import and Export Wizard)
2. valitse Data Source (listan viimeinen!)
3. täytä kirjautumistiedot 
4. valitse kohde, esimerkiksi Flat File ja määritä tiedoston nimi sekä muut tarvittavat tiedot
5. valitse joko taulu tai taulut (kaikki rivit) tai kirjoita SQL-lause, jonka perusteella data haetaan tietokannasta
6. aseta siirron (datan) ominaisuudet
7. suorita tai tallenna tai molemmat, suorituksesta tulee vaiheittainen raportti, jos on ongelmia, näkyy virheilmoitus raportti-ikkunassa.

Huomaa, että tässä vaiheessa voit tallentaa export-toiminnon SSIS-paketiksi joko tietokantaan tai tiedostoon. Jos export pitää suorittaa myöhemmin, voi talletetun SSIS-paketin ajaa tarvittaessa uudelleen tai sen voi ajastaa SQL Server Agent:lla

Kokeillaan seuraavana tiedon tuontia: 
1. Luo SQL-taulu (kohde)
```sql
CREATE TABLE dbo.Tuotteet (
    TuoteID INT PRIMARY KEY,
    Tuotenimi NVARCHAR(40),
    Hinta DECIMAL(10, 2)
);
```
2. Käytetään aikaisemmin esitettyä Tuotteet.CSV-tiedostoa
3. Tee edellistä esimerkkiä mukaillen Import Data... -toiminto. 

4. Lisää CSV-lähde Flat File Source ja valitse Valitse tuotteet.csv, jonka olet tallettanut tiedostona johonkin sopivaan hakemistoon. Määritä sarake-erottimeksi pilkku ,
ja aseta otsikkorivi: Column names in the first data row

5. Lisää SQL Server -kohde ja valitse tauluksi Tuotteet sekä tee sarakkeiden mäppäys:
- TuoteID → TuoteID
- Tuotenimi → Tuotenimi
- Hinta → Hinta

5. Aja paketti ja tallenna se tietostoon tai tietokantaan, ja sen jälkeeen tarkista mikä on tietokannassa taulun sisältö.

Jos dataa pitäisi muuttaa, käsitellä tai konvertoida, tarvitaan Visual Studiota ja kokonaista työkalua laajemman SSIS-paketin tekemiseen.
[SSIS Tutorial](https://learn.microsoft.com/en-us/sql/integration-services/lesson-1-create-a-project-and-basic-package-with-ssis?view=sql-server-ver16) kannattaa käydä läpi, jos SSIS-paketteja aikoo tehdä. Youtubesta löytyy tutoria-videoita runsaasti. SSIS-projektin ja myös juuri tekemäsi paketin voi ajoittaa SQL Server Agentin avulla toistuvaksi ajoksi (esim. päivittäin).



### 🕒 SQL Server Agentin käyttö SSIS-paketin ajoittamiseen

🧩 Osa 1: SQL Server Agent – SSIS-paketin ajo
SQL Server Agent on SQL Serverin oma ajoitusmoottori, jolla voit ajastaa SSIS-pakettien (ja muiden toimintojen) suorittamisen, esim. joka yö klo 02:00.

👣 Vaiheet – Ajo SSIS-paketille SQL Server Agentilla
1. asenna SSIS-paketti tai edellisen esimerkin mukaisesti se löytyy tiedostosta (.dtsx) tai msdb-tietokannasta.

2. Avaa SQL Server Agent (varmista että se on käynnissä), hiiren oikealla: Jobs → New Job...

3. Jobin määrittely
- Name: esim. TuotteidenTuonti
- Siirry Steps välilehdelle → New...
- Lisää Step
    - Name: esim. AjaTuonti
    - Type: SQL Server Integration Services Package
    - Package source: valitse mistä paketti haetaan (SSIS Catalog / File system)
    - Package: valitse .dtsx tai deployed paketti
    - Käyttäjä: valitse tarvittaessa käyttöoikeuksin varustettu SQL Agent -proxy

4. Schedule-välilehti, luo uusi ajoitus, esim.
- Daily, Occurs once at 2:00 AM
5. Tallenna, jobi on valmis ja ajetaan automaattisesti.



### 🛠️ Tietojen siirto toiseen SQL Server -tietokantaan
Yksi yleinen tapa siirtää dataa SQL Serveristä toiseen SQL Serveriin (esim. eri instanssiin tai ympäristöön: testi → tuotanto) on käyttää SSIS:ää, mutta komentorivityökaluilla kuten bcp ja sqlcmd voidaan myös tehdä paljon.

Esimerkki: Tiedon kopiointi kahden SQL Serverin välillä (INSERT ... SELECT)
Jos yhteys molempiin onnistuu, voit tehdä suoran siirron:

```sql
-- Kohdetietokannassa (esim. tuotanto):
INSERT INTO Tuotteet (TuoteID, Tuotenimi, Hinta)
SELECT TuoteID, Tuotenimi, Hinta
FROM [TestiPalvelin].[TestiTietokanta].[dbo].[Tuotteet];
```
📌 Edellyttää linkitetyn palvelimen (sp_addlinkedserver) tai avointa yhteyttä kohteeseen.

Esimerkki 2: SSIS siirtona kahden SQL-tietokannan välillä
Voit tehdä SSIS-paketin:


###  Komentorivityökalut SQL Serverille

1. bcp – Bulk Copy Program
Kopioi tauluja tai kyselyn tuloksia tiedostoksi tai takaisin SQL Serveriin.

Esimerkki: Export CSV
```bash
bcp "SELECT TuoteID, Tuotenimi, Hinta FROM Tuotteet"
   queryout tuotteet.csv
   -c -t, -S localhost -U käyttäjä -P salasana
````
Esimerkki: Import CSV
```bash
bcp dbo.Tuotteet in tuotteet.csv -c -t, -S localhost -U käyttäjä -P salasana
```
BCP on hyvin perinteinen työkalu tiedon siirtoo, se on nopea ja sopii isoille tietomäärille, mutta ei sisällä mitään varsinaista käsittelylogiikkaa tai validointia eli on parhaimmillaan "raakadatan" käsittelyssä. Tukee vain taulun tai kyselyn tuloksen käsittelyä, ei mitään monimutkaista logiikkaa.

**sqlcmd** – komentoriviltä SQL-kyselyjä
```bash
sqlcmd -S localhost -U käyttäjä -P salasana -Q "SELECT COUNT(*) FROM Tuotteet"
```

Komentorivipohjaisia toimintoja voi suorittaa PowerShell- tai Komentotulkista suoraan joten ne voi tarvittessa ajastaa Windowsin Task Scheduler-toiminnoilla. Ajastukseen ja muutenkin suoritukseen pystyy käyttämään myös SQL Server Agent:tia.


**bcp-esimerkkikomento ja ajastus**
```cmd
bcp dbo.Tuotteet in "C:\Data\tuotteet.csv" -S .\SQLEXPRESS -U käyttäjä -P salasana -c -t, -r\n -d Tietokanta
```
SSMS ja sieltä valitaan Object Explorerista SQL Server Agent ==> Jobs. SQL Server Agent Service toimii jollain Account:lla (käyttäjätili) ja sillä pitää olla riittävästi oikeuksia käytettäviin hakemistoihin (olla oikeudet CSV-tiedoston sijaintiin) ja jos kirjautuminen tietokantaa on Integrated-tyyppinen, on myös login oltava kunnossa.


📅 Schedule (Ajastus)
Siirry Schedules-välilehdelle → New
- Aseta esim. Daily @ 03:00
 
Tallenna Job ja kokeile suorittaa se heti ilman ajastusta testitarkoituksessa.

🧩 Error handling ja logitus (lisävinkkejä)
Jobin History-välilehdellä näet onnistumisen/virheet. Voit ohjata virheet >> logi.txt komentorivillä varsin helposti:

```cmd
bcp dbo.Tuotteet in "C:\Data\tuotteet.csv" -S .\SQLEXPRESS -U käyttäjä -P salasana -c -t, -r\n -d Tietokanta >> C:\Logs\bcp_log.txt 
```


