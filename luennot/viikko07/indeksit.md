# Indeksit

Eräs tietokannan suorituskykyyn liittyvä asia on indeksointi. 

### Taulutyypit ja talletusrakenteet

- Datatiedosto koostuu 64 kilotavun extenteistä
- Extent sisältää 8 peräkkäistä 8 kilotavun sivua
- Sivu on aina 8 Kt ja on pienin IO-yksikkö muistin ja levyn välillä
    - Sivu sisältää 1–n kpl saman taulun tai indeksin riviä
    - Vakiomittaisen rivin pitää mahtua sivulle,  rivin maksimipituus on 8000 tavua
    - Poikkeus: vaihtuvamittaiset rivit ja lob-tietotyypit (varchar(MAX), navarchar(MAX), varbinary(MAX), text, ntext ja image sallivat 2 GB dataa)

Taulujen fyysinen tallennustapa:
- Klusteroitu taulu on taulu jolle on määritelty klusteroitu indeksi, sivut muodostavat linkitetyn listan
- Heap on taulu, jossa ei ole klusteroitua indeksiä (tavallisia voi olla), sivut eivät muodosta linkitettyä listaa

Rivien hakuun tietokantatiedoston sisältä SQL Server käyttää **IAM**-rakennetta (Index Allocation Map). 
Se on sisäinen tietorakenne, jota SQL Server käyttää seuraamaan, mitkä sivut kuuluvat mille indeksille tai taululle.

SQL Serverissä taulut ja indeksit tallennetaan sivuina (pages), kuten aikaisemmin jo todettiin. Näitä sivuja hallitaan extenteissä (8 sivun ryhmät). IAM-sivut seuraavat näitä extenttejä.

IAM-sivun tehtävänä on pitää kirjaa, mitkä extentit (fyysiset alueet levyllä) kuuluvat tietylle taululle tai indeksille.
- Yksi IAM-sivu kattaa 64 000 extenttiä (512 MB tietoa).
- Jokaisella tietokantaobjektilla (taululla tai indeksillä) on oma IAM-ketjunsa kutakin varausyksikköä kohden.

Kun SQL Server tarvitsee lukea tietoa (suorittaa hakua tai etsii päivitettäviä rivejä), se voi käyttää IAM-sivuja selvittääkseen nopeasti, missä kohdin levyä kyseisen taulun tai indeksin tiedot sijaitsevat ilman, että sen tarvitsee lukea koko tietokantatiedostoa läpi. IAM on siis eräänlainen hakemisto tietokannan sisällä, joka SQL Server käyttää hyväkseen hakiessaan tietoja levyltä. 

## Indeksi
Ilman indeksejä rivien haku pitää tehdä ns. Table Scan-toiminnolla eli selata kaikki rivit läpi. Taulun rivit löytyy IAM.n avulla. Indeksointi nopeuttaa haun kohteena olevien rivien löytymistä. Jos taulussa on vain vähän rivejä (kymmeniä tai satoja), on Table Scan tehokas tapa etsiä dataa. Useimmiten rivejä on kuitenkin paljon enemmän, jolloin jos haetaan where-ehdolla jotain tiettyjä rivejä, olisi hyvä löytää oikeat rivit mahdollisimman vähillä tiedosto-IO -toiminnoilla. Levykäsittely on hidasta verrattuna datan käsittelyyn keskusmuistissa.

Indeksit on toteutettu B-puu rakenteen avulla, josta löytyy joko rivin sisältämä sivu tai suoraan rivin positio. Indeksi tavoitteena on minimoida datan hakemiseen käytettävä aika ja levykäsittely. Indeksi siis parantaa suorituskykyä, mutta ei kaikissa tilanteissa. Indeksejä on myös ylläpidettävä (päivitettävä) aina kun taulun sisältö muuttuu indekseihin kuuluvien sarakkeiden osalta. Kaikki INSERT, UPDATE ja DELETE -toiminnot yleensä aiheuttavat indeksin B-puun päityksiä. Indeksille joutuu allokoimaan lisää sivuja tietokannasta ja tekemään ns. splittauksia eli B-puun sivuja jaetaan useampaan osaan. Kaikki indeksin muutokset vaativat siis prosessoriaikaa ja levy-IO toimintoja. Siksi pitää miettiä tarkkaan mitä kannattaa indeksoida suhteessa datan käsittelytapaan ja -logiikkaan. OLTP tietokannassa optimaalinen indeksointi on varmasti erilainen kuin OLAP-tietokannassa, jossa pääsääntöisesti tulee lukuoperaatoita kun OLTP:ssä tulee paljon päivitystoimintoja.


## Mitä yleensä kannattaa indeksoida:
1. Sarakkeet, joita käytetään WHERE-ehdoissa
```sql
SELECT * FROM Tuotteet WHERE Tyyppi = 'Elektroniikka';
-- Indeksoi Tyyppi
```

2. Sarakkeet, joita käytetään JOIN-operaatioissa
```sql
SELECT * FROM Tilaukset
JOIN Asiakkaat ON Tilaukset.AsiakasID = Asiakkaat.AsiakasID;
-- Indeksoi AsiakasID molemmissa tauluissa
```

3. Sarakkeet, joita käytetään ORDER BY -ehdossa
```sql
SELECT * FROM Tuotteet ORDER BY Hinta DESC;
-- Indeksi Hinta nopeuttaa lajittelua
```

4. Sarakkeet, joita käytetään GROUP BY -ehdossa
```sql
SELECT OsastoID, COUNT(*) FROM Työntekijät GROUP BY OsastoID;
-- Indeksi OsastoID voi parantaa suorituskykyä
```

5. Viiteavaimet (Foreign Keys)
- Usein hyvä indeksoida myös viiteavaimet, sillä ne osallistuvat JOIN:eihin ja viite-eheyden tarkistuksiin

6. Pääavaimet (Primary Keys)
- Pääavaimella tehdään hyvin usein hakuja ja käytetään muös JOIN:ssa liitosehtona, tämä olikin jo mainittu kohdassa 2, mutta vielä varmistuksena tässä ettei vain unohdu


### ❌ Indeksointi ei ole suositeltavaa:
- Sarakkeet, joissa on vain muutama mahdollinen arvo (esim. Sukupuoli, OnkoAktiivinen), siis huono selektiivisyys
- Sarakkeet, joita päivitetään usein
- Liian monta indeksiä per taulu — jokainen INSERT, UPDATE, DELETE vaikuttaa myös indekseihin





## SQL Serverin indeksit

Pääjako SQL Serverin indekseissä on clustered ja non-clustered -indeksit, Näistä löytyy tiivis esitys [täältä](https://learn.microsoft.com/en-us/sql/relational-databases/indexes/clustered-and-nonclustered-indexes-described?view=sql-server-ver16).
Todellisuudessa SQL Server tukee ja käyttää montaa erilaista [indeksityyppiä](https://learn.microsoft.com/en-us/sql/relational-databases/indexes/indexes?view=sql-server-ver16). Näitä kaikkia ei käydä läpi tällä kurssilla, keskitytään ensi pääasiaan jotka on pakko tietää ja tuntea tietokantojen optimoinnissa ja hallinnassa.

### Indeksit taulun luonnissa
Kun luot taulun jossa on PRIMARY KEY, muodostuu automaattisesti myös indeksi, joka on clustered-tyyppinen (ja unique):
```sql
CREATE TABLE Esimerkki (
    ID INT PRIMARY KEY,
    Nimi NVARCHAR(100)
);

-- katso indeksit:
sp_help Esimerkki;
```

Jos jostain syystä halutaan 'normaali'-indeksi clusteroidun tilalle, voidaan indeksi poistaa ja luoda uudelleen tai sitten luonnin yhdeydessä määritetään indeksin tyyppi:
```sql
CREATE TABLE Esimerkki (
    ID INT NOT NULL,
    Nimi NVARCHAR(100),
    PRIMARY KEY NONCLUSTERED (ID)  -- Tässä määrätään, että indeksi on ei-klusteroitu
);
```

Clustered-indeksejä voi olla vain yksi per taulu. Tämä johtuu siitä, että tässä indeksissä rivit ovat fyysisesti oikeassa järjestyksessä sivun sisällä indeksin sarakkeen perusteella. Indeksipuun rakenne on matalampi kuin normaalissa indeksissä. Clustered-indeksin voi tehdä minkä tahansa sarakke(id)en perusteella, oletuksena avain on kuitenkin keskimäärin varsin hyvä.

[Kaavio](https://medium.com/@lorenzouriel/everything-you-need-to-know-about-index-in-sql-server-b142787f1d98) miltä indeksirakenne näyttää ja miten se toimii.


## Indeksin luonti

Indeksi luontikomento on perusmuodossa aika yksinkertainen:
```sql
CREATE [ UNIQUE ] [ CLUSTERED | NONCLUSTERED ] INDEX index_name
    ON <object> ( column [ ASC | DESC ] [ ,...n ] )
    [ INCLUDE ( column_name [ ,...n ] ) ]
```

SQL Serverin indeksin luonnissa on kuitenkin paljon erilaisia [säätömahdollisuuksia](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-index-transact-sql?view=sql-server-ver16), joita kaikkia ei tässä käydä läpi.

Muutama esimerkki:

```sql
CREATE INDEX idx_tuote_nimi IN Tuote(Nimi) 
    WITH (PAD_INDEX = ON, FILLFACTOR=80); -- lisäasetuksia 

-- tuotenumero pitää olla yksilöllinen:
CREATE UNIQUE INDEX idx_tuote_koodi ON Tuote(tuotenumero);

-- poistaminen
DROP INDEX idx_tuote_koodi ON Tuote;
-- TAI:
DROP INDEX Tuote.idx_tuote_koodi;
```
Huom. jos CREATE TABLE -komennossa sarakkeeseen liittyy UNIQUE-rajoite, muodostuu siitä automaattisesti UNIQUE-indeksi.


## Indeksisarakkeet ja INCLUDE

Indeksissä voidaan INCLUDE-lauseella ottaa mukaan myös lisäsarakkeita, jolloin kysely voidaan käsitellä vain indeksiä lukemalla ilman että tarvitsee taulun datasivuilta käydä hakemassa mitään. 
Esimerkki miten INCLUDE:lla lisätään dataa indeksisivuille:
```sql
CREATE NONCLUSTERED INDEX IX_Tuotteet_Tyyppi
    ON Tuotteet (Tyyppi)
    INCLUDE (Nimi, Hinta);
```

Perinteinen indeksi:
```sql
SELECT Name, ListPrice
FROM Production.Product
WHERE Color = 'Red';
```
Ilman sopivaa indeksiä SQL Server tekee taulun skannauksen (table scan) joka on hidasta isoissa tauluissa.
Lisätään indeksi, jossa on mukana muita sarakkeita:
```sql
CREATE NONCLUSTERED INDEX IX_Product_Color
    ON Production.Product (Color)
    INCLUDE (Name, ListPrice);
```
Mikä muuttuu?
- Color on hakusarake (seek key)
- Name ja ListPrice ovat katetut sarakkeet (include-indeksi)
- SQL Server voi nyt suorittaa pelkän indeksin haun (index seek) ilman viittauksia tauluun

**Suorituskykyparannus**
*Ilman indeksiä*
- Execution Plan: Table Scan
- Suoritus hidasta, etenkin isolla datalla

*Katetun indeksin jälkeen:*
- Execution Plan: Index Seek (IX_Product_Color)
- Koko kysely palautetaan suoraan indeksistä — ei tarvetta hakea rivejä taulusta


Käytä Actual Execution Plania SSMS:ssä ja aja seuraava komento:
```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT Name, ListPrice
    FROM Production.Product
    WHERE Color = 'Red';
```



## Splittaus ja Fillfactor

SQL Server tallentaa indeksejä 8 kilotavun sivuihin (pages) samoin kuin tietkannan taulujen rivejä. Kun indeksi on järjestetty (esim. B+-puuna) ja uusi rivi pitäisi lisätä väliin, mutta indeksisivulla ei ole tilaa, tapahtuu splittaus:
- Alkuperäinen sivu jaetaan kahtia.
- Noin puolet tiedoista siirtyy uudelle sivulle.
- Uusi rivi lisätään oikeaan paikkaan.
- Tämä lisää I/O-kuormaa, sirpaloittaa tietoa ja voi hidastaa suorituskykyä.

**Fillfactor** kertoo, kuinka täyteen SQL Server täyttää indeksin sivut uudelleenrakennuksen (REBUILD) tai luonnin yhteydessä.

| Fillfactor | Vapaa tila  | Käyttötapa                                                   |
|------------|-------------|--------------------------------------------------------------|
|100 %       | Ei vapaata  |Ei varaudu lisäyksiin väliin                                  |
|90 %        | 10 % tyhjää |Varaudutaan väliin tuleviin lisäyksiin (vähemmän splittauksia)|
|70 %        | 30 % tyhjää |Usein kirjoitettavat taulut                                   |

**Esimerkki**
```sql
-- 1. Luodaan testitaulu
CREATE TABLE Testi (
    ID INT PRIMARY KEY,
    Arvo CHAR(100)
);
GO

-- 2. Luodaan indeksi, jossa fillfactor 100 (ei tyhjää tilaa sivuilla)
CREATE NONCLUSTERED INDEX IX_Arvo_Tiivis
ON Testi (Arvo)
WITH (FILLFACTOR = 100);
GO

-- 3. Tai vaihtoehtoisesti: fillfactor 80 (jättää 20 % tilaa jokaiselle sivulle)
CREATE NONCLUSTERED INDEX IX_Arvo_Väljä
ON Testi (Arvo)
WITH (FILLFACTOR = 80);
GO
```

Mitä käytännössä tapahtuu?
- FILLFACTOR = 100: kaikki sivut täynnä. Jos yrität lisätä Arvo-sarakeväliin uuden rivin → pakko tehdä page split.
- FILLFACTOR = 80: jokaisella sivulla on 20 % tilaa tuleville arvoille → lisäys ilman splittausta mahdollista.

**Yhteenveto**

| Termi      | Tarkoitus                                                                |
|------------|--------------------------------------------------------------------------|
| Page Split | Sivu täyttyy, jaetaan kahteen osaan lisäyksen vuoksi                     |
| Fillfactor | Kuinka täyteen sivu alun perin täytetään (jotta vältettäisiin splittaus) |



## Indeksien huolto

Tietokantaa käytettäessä INSERT, UPDATE ja DELETE-komennot 'rikkovat' indeksipuun rakennetta (fragmentaatio). Siksi on hyvä aika ajoin tarkistaa mikä on indeksirakenteiden tilanne ja tehdä tarvittavat korjaustoimenpiteet.

### 🔍 Mitä on fragmentaatio?

Fragmentaatio tarkoittaa sitä, että indeksin sivut eivät ole järjestyksessä, mikä lisää levy-I/O:ta ja hidastaa suorituskykyä.

---

## 🛠️ Huoltotoimenpiteet

| Toiminto       | Käyttötilanne          | Vaikutus | Lukitukset        | Kuvaus                             |
|----------------|------------------------|----------|-------------------|------------------------------------|
| **REORGANIZE** | Fragmentaatio 5–30 %   | Kevyt    | Ei estä käyttöä   | Järjestelee indeksisivut uudelleen |
| **REBUILD**    | Fragmentaatio > 30 %   | Raskas   | Offline / Online* | Luo indeksin uudestaan             |

> *Online-vaihtoehto käytettävissä vain Enterprise Editionissa tai uudemmissa versioissa (myös Standard 2019+ tietyin ehdoin).

---

## 📊 Fragmentaation tarkistus

```sql
SELECT 
    dbschemas.[name] AS 'Schema',
    dbtables.[name] AS 'Table',
    dbindexes.[name] AS 'Index',
    indexstats.avg_fragmentation_in_percent
FROM sys.dm_db_index_physical_stats(DB_ID(), NULL, NULL, NULL, 'LIMITED') AS indexstats
JOIN sys.tables dbtables ON dbtables.[object_id] = indexstats.[object_id]
JOIN sys.schemas dbschemas ON dbtables.[schema_id] = dbschemas.[schema_id]
JOIN sys.indexes AS dbindexes ON dbindexes.[object_id] = indexstats.[object_id]
    AND indexstats.index_id = dbindexes.index_id
WHERE indexstats.database_id = DB_ID()
  AND dbindexes.name IS NOT NULL
ORDER BY indexstats.avg_fragmentation_in_percent DESC;
```

### Korjausesimerkit

**📌 1. REORGANIZE (pienempi huolto)**
```sql
ALTER INDEX IX_Tuotteet_Hinta ON Tuotteet
REORGANIZE;
```
- Tehdään yleensä fragmentaation ollessa 5–30 %
- Kevyt, ei aiheuta käyttökatkoa
- Hyvä ajoittaa hiljaiselle ajalle


**🔄 2. REBUILD (raskas mutta tehokas)**
```sql
ALTER INDEX IX_Tuotteet_Hinta ON Tuotteet
REBUILD WITH (FILLFACTOR = 90, ONLINE = ON);
```
- Suositellaan fragmentaation ollessa yli 30 %
- Luo indeksin täysin uudelleen
- *ONLINE = ON* sallii käytön samalla (vain Enterprise / myöhemmät versiot)

**Kaikki indeksit yhdellä komennolla**
```sql
-- Kaikkien taulun indeksien rebuild:
ALTER INDEX ALL ON Tuotteet REBUILD;

-- Tai reorganize:
ALTER INDEX ALL ON Tuotteet REORGANIZE;
```

**📅 Milloin huoltaa?**
- Säännöllinen ajastus (esim. yöaikaan, viikoittain)
- ETL- tai massapäivitysten jälkeen
- Suorituskykyongelmia tutkiessa
- Fragmentaation ylittäessä 5 % tai 30 % rajan

**🎓 Vinkki: Automaattinen huolto**
Voit automatisoida indeksien huollon SQL Server Agent -jobin tai huoltosuunnitelmien avulla. Kehittyneempi vaihtoehto on käyttää dynaamista skriptiä, joka valitsee REORGANIZE tai REBUILD automaattisesti fragmentaation perusteella.

-----


## Indeksoinnin vaikutus kyselyiden suorituksessa

SSMS:ssä voi laittaa päälle toiminnon *Show Actual Execution Plan*. Silloin SQL Server palauttaa tiedon, miten se on prosessoinut kyselyn. Jos SQL Server havaitsee, että kyselyn suoritus olisi tehokkaampi, jos jokin indeksi olisi olemassa, ilmoittaa se *Missing Index* ehdotuksen. 

#### Esimerkki AdventureWorks-tietokannasta

```sql
SELECT ProductID, OrderQty, UnitPrice
FROM Sales.SalesOrderDetail
WHERE ProductID = 870 AND SpecialOfferID = 1;
```
Kyseessä on varsin yksinkertaiselta näyttävä kysely yhteen tauluun, jossa on jo valmiiksi indeksejä. Olemassa olevat indeksit saat selville SSMS:n Object Explorerista tai TSQL:n avulla:

```sql
SELECT 
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_unique,
    i.is_primary_key,
    i.is_unique_constraint,
    c.name AS ColumnName,
    ic.is_included_column
FROM 
JOIN 
    sys.indexes i
    sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
JOIN 
    sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE 
    i.object_id = OBJECT_ID('Sales.SalesOrderDetail')
ORDER BY 
    i.name, ic.key_ordinal;

-- tai tiiviimmin, pelkät indeksien nimet:

EXEC sp_helpindex 'Sales.SalesOrderDetail';
```
Suorita lause niin, että saat takaisin Execution Planin. Tarkista että näkyviin tulee *Missing Index* -teksti. Hiiren oikeanpuoleisella näppäimellä saat esille valikon, josta löytyy valmiina ehdotettu indeksi.


Miksi ehdotus tulee? Sarakkeet ProductID ja SpecialOfferID eivät ole mukana missään olemassa olevassa indeksissä. Seuraavana pitääkin päättää luodaanko ehdotettu indeksi
```sql
/*
USE [AdventureWorks2012]
GO
CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
ON [Sales].[SalesOrderDetail] ([ProductID],[SpecialOfferID])
INCLUDE ([OrderQty],[UnitPrice])
GO
*/
```
vai onko tämä vain satunnainen hyvin harvoin suoritettava kysely, jolloin suorituskykyvaatimuksia ei oikeastaan ole lainkaan.

Voit myös selvittää palvelimen Dynamic Management Views (DMV) -näkymiltä SQL Serverin ehdottamia indeksejä:

```sql
SELECT 
    migs.avg_total_user_cost * migs.avg_user_impact * (migs.user_seeks + migs.user_scans) AS improvement_measure,
    mid.statement AS [SQL],
    mid.equality_columns,
    mid.inequality_columns,
    mid.included_columns,
    'CREATE INDEX IX_Suggested ON ' + mid.statement + 
        '(' + ISNULL(mid.equality_columns,'') + 
        CASE 
            WHEN mid.inequality_columns IS NOT NULL THEN ',' + mid.inequality_columns 
            ELSE '' 
        END + ')' +
        CASE 
            WHEN mid.included_columns IS NOT NULL THEN ' INCLUDE (' + mid.included_columns + ')' 
            ELSE '' 
        END AS create_index_statement
FROM sys.dm_db_missing_index_groups mig
JOIN sys.dm_db_missing_index_group_stats migs 
    ON migs.group_handle = mig.index_group_handle
JOIN sys.dm_db_missing_index_details mid 
    ON mig.index_handle = mid.index_handle
ORDER BY improvement_measure DESC;

```

**Dynamic Management Views (DMV)** ovat SQL Serverin tarjoamia erityisiä näkymiä, joiden avulla voit tarkastella palvelimen, tietokantojen ja kyselyjen tilaa, suorituskykyä ja diagnostiikkatietoja reaaliaikaisesti.

Niitä käytetään mm. seuraaviin tarkoituksiin:
- Tietokannan ja taulujen suorituskykyanalyysi
- Indeksien käyttö ja mahdolliset puuttuvat indeksit
- Kyselyjen resurssinkulutus
- Lukitusten ja odotusten diagnosointi
- Cachet ja buffer-poolien tarkastelu

🧱 DMV-näkymien rakenne
DMV:t ovat useimmiten nimetty muodossa **sys.dm_xxx**

DMV:t on jaoteltu eri aihealueisiin, esimerkiksi:

| Alue        | Esimerkki DMV                                                | Tarkoitus                     |
|-------------|--------------------------------------------------------------|-------------------------------|
| Kyselyt     | sys.dm_exec_query_stats, sys.dm_exec_requests                | Eniten resursseja käytössä    |
| Indeksit    | sys.dm_db_index_usage_stats, sys.dm_db_missing_index_details | Indekseien käyttö ja puutteet |
| Lukitukset  | sys.dm_tran_locks                                            | Lukitustilanteet              |
| Muisti      | sys.dm_os_memory_clerks                                      | Muistinkäyttöä                |
| Prosessorit | sys.dm_os_wait_stats                                         | Odotus (I/O, CPU jne.)        |

DMV:t ovat reaaliaikaisia, mutta usein perustuvat tilastoihin, jotka nollautuvat SQL Serverin uudelleenkäynnistyksen yhteydessä.

📌 Esimerkki: Puuttuvien indeksien katselu
```sql
SELECT * FROM sys.dm_db_missing_index_details;
```
Tämä näyttää tietoja tauluihin liittyvistä indekseistä, joita SQL Server on havainnut hyödyllisiksi mutta joita ei ole luotu.