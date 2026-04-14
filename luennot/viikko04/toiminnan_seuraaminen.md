# Toiminnan seuraaminen

Toiminnan seuraamista voi tehdä tutkimalla mitä komentoja tulee tietokantapalvelimelle suoritettavaksi ja kalliissa Enterprise Edition -versiossa saa myös SELECT-lauseiden lokituksen käyttöön. Helppo ja halpa tapa on käyttää SQL Server Profiler -sovellusta. 
Aika usein on myös tarpeen seurata miten data muuttuu ja kuka muutoksen tekee sekä milloin. Perinteinen ja edelleen paljon käytössä oleva tekniikka datamuutosten seurantaan perustuu triggereihin. Trigger kirjaa muutokset johonkin historia- tai AuditTrail-tauluun.

## Trigger ja auditTrail-taulu
Esimerkki toimintaideasta:
```sql
CREATE TRIGGER Asiakas_Audit
ON Asiakas AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    INSERT INTO AsiakasAudit (Toiminto, Aika, ID, VanhaNimi, UusiNimi)
    SELECT
        CASE 
            WHEN EXISTS(SELECT * FROM inserted) AND EXISTS(SELECT * FROM deleted) THEN 'UPDATE'
            WHEN EXISTS(SELECT * FROM inserted) THEN 'INSERT'
            ELSE 'DELETE'
        END,
        SYSDATETIME(),
        ISNULL(d.ID, i.ID),
        d.Nimi,
        i.Nimi
    FROM inserted i
    FULL OUTER JOIN deleted d ON i.ID = d.ID;
END
```

Triggerin avulla voi seurata juuri niitä tietoja, jotka ovat merkittäviä tai sitten kaikken sarakkeiden muutoksia. On mahdollista tehdä myös täysin geneerinen trigger, joka toimii kaikkien taulujen kanssa ja silloin kannattaa tehdä yksi geneerinen taulu muutosten seurantaan.

## Change Data Capture (CDC)
Tämän avulla voi seurata päivityskomentoja määritellyssä taulussa. CDC tallentaa muutokset erityisiin CDC-lokitauluihin. Ei vaadi triggerien käyttöä.
Esimerkki:

```sql
-- Ota CDC käyttöön tietokannassa
EXEC sys.sp_cdc_enable_db;

-- Ota CDC käyttöön taulussa
EXEC sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name   = N'Asiakas',
    @role_name     = NULL;
-- muutokset löytyy cdc.dbo_Asiakas_CT -taulusta
-- jonka SQL Server luo automaattisesti

-- Kaikki CDC:n seuraamat taulut
SELECT 
    source_schema + '.' + source_name AS SourceTable,
    capture_instance AS CaptureInstance,
    'cdc.' + capture_instance + '_CT' AS ChangeTable
FROM cdc.change_tables;
```

Tilanteesta riippuen, voi olla että CDC on laitettava päälle käyttäen SQl Server-logintunnusta, jos käyttäjätietojen lukeminen ei onnistu Windows-tunnukselta. Lisäksi SQL Server Agentti pitää olla käynnissä.


## Temporal Tables (System-Versioned Temporal Tables)
SQL Server ylläpitää automaattisesti historiatietoa taulussa. Jokaisella rivillä on voimassaoloajanjakso (ValidFrom–ValidTo).
Esimerkki:

```sql
CREATE TABLE Asiakkaat (
    ID INT PRIMARY KEY,
    Nimi NVARCHAR(100),
    Syntymaaika DATE,
    ValidFrom DATETIME2 GENERATED ALWAYS AS ROW START,
    ValidTo DATETIME2 GENERATED ALWAYS AS ROW END,
    PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.AsiakkaatHist));

-- versiot saa selville vaikka näin:
SELECT * FROM Asiakkaat FOR SYSTEM_TIME ALL WHERE ID = 1;
```

## Change Tracking
Tietokannassa ja tauluissa voidaan asettaa Change Tracking päälle. Silloin SQL Server seuraa taulun muutoksia. Helppo asettaa SSMS:n kautta. Change Tracking tallettaa vain muuttuneet rivit eikä talleta vanhoja arvoja, suorituskykymielessä halpa ratkaisu.

```sql
-- 1. Tietokannassa
ALTER DATABASE ToiminnanSeuranta
SET CHANGE_TRACKING = ON
(CHANGE_RETENTION = 2 DAYS, AUTO_CLEANUP = ON);

-- 2. Taulussa
ALTER TABLE dbo.Tuote
ENABLE CHANGE_TRACKING
WITH (TRACK_COLUMNS_UPDATED = ON);

-- Hae muuttuneet rivit

DECLARE @last_sync_version BIGINT = 0;
DECLARE @current_version BIGINT = CHANGE_TRACKING_CURRENT_VERSION();

SELECT 
    CT.TuoteID,
    CT.SYS_CHANGE_OPERATION,  -- I=INSERT, U=UPDATE, D=DELETE
    CT.SYS_CHANGE_VERSION,
    T.Nimi,
    T.Hinta
FROM CHANGETABLE(CHANGES dbo.Tuote, @last_sync_version) AS CT
LEFT JOIN dbo.Tuote T ON T.TuoteID = CT.TuoteID;
```

## Ledger-taulu
Ledger-taulu on uusin taulutyyppi (SQL Server 2022-versiosta eteenpäin). Muutoshistorian seuranta on taattu, muutoksia ei siis voi hävittää tai muuttaa kuten AuditTrail + trigger -tyyppisessä ratkaisussa.

Kaksi tyyppiä:
1. Updateable Ledger Tables (Päivitettävät)
- Sallii INSERT, UPDATE, DELETE
- Käyttää SYSTEM_VERSIONING (temporal tables) -teknologiaa
- Luo automaattisesti history-taulun ja ledger view -näkymän
- Tallentaa kaikki muutokset ja niiden hash-arvot

2. Append-Only Ledger Tables (Vain lisäys)
•	Sallii vain INSERT
- Sallii vain INSERT
- Ei tarvitse history-taulua
- Kevyempi vaihtoehto
- Sopii lokitauluille

**Keskeiset ominaisuudet:**

| Ominaisuus | Kuvaus |
|------------|--------|
|SHA-256 hash |	Jokainen rivi saa hash-arvon |
| Muuttumattomuus | Muutokset voidaan todentaa blockchain-tyyppisesti |
| Tietoturva | Estää peukaloinnin myös admin-tasolla |
| Auditointihistoria | Täydellinen muutoshistoria |
| Database Ledger	| Tietokanta pitää kirjaa kaikista muutoksista |

**Päivitettävä**
```sql
CREATE TABLE dbo.TilitapahtumaLedger
(
    TapahtumaID INT IDENTITY PRIMARY KEY,
    TiliNumero NVARCHAR(20) NOT NULL,
    Summa DECIMAL(18,2) NOT NULL,
    Paivays DATETIME2 NOT NULL
)
WITH 
(
    SYSTEM_VERSIONING = ON,
    LEDGER = ON
);
```

**Append-only**
```sql
CREATE TABLE dbo.KayttajaLokiLedger
(
    LokiID INT IDENTITY PRIMARY KEY,
    KayttajaID INT NOT NULL,
    Toiminto NVARCHAR(100) NOT NULL,
    Aika DATETIME2 NOT NULL
)
WITH (LEDGER = ON (APPEND_ONLY = ON));
```

### Yhteenveto

| Ominaisuus | Ledger | CDC | Temporal Tables | Change Tracking | Triggers |
|------------|--------|-----|-----------------|-----------------|----------|
| **Kryptografinen varmistus** | ✓ SHA-256 | ✗ | ✗ | ✗ | ✗ |
| **Vanhat arvot** | ✓ | ✓ | ✓ | ✗ | ✓ (itse toteutettava) |
| **Automaattinen** | ✓ | ✓ | ✓ | ✓ | ✗ |
| **Vaatii SQL Agent** | ✗ | ✓ | ✗ | ✗ | ✗ |
| **Suorituskyky** | Paras | Hyvä | Hyvä | Erinomainen | Heikoin |
| **Muokattavissa** | ✗ | ✗ | ✗ | ✗ | ✓ |
| **Aikamatkustus, ajan mukaan historia** | ✓ | ✗ | ✓ | ✗ | ✗ |
| **Versionhallinta** | ✓ | ✓ | ✓ | Vain muutos-info | ✓ (itse toteutettava) |
| **Pudotetun datan säilytys** | ✓ | ✗ | ✗ | ✗ | ✗ |
| **SQL Server versio** | 2022+ | 2008+ | 2016+ | 2008+ | Kaikki |
| **Kuormitus** | Matala | Keskitaso | Keskitaso | Erittäin matala | Korkea |
| **Compliance-tuki (laki ja säännökset)** | ✓ Blockchain | Hyvä | Kohtalainen | Heikko | Riippuu toteutuksesta |
| **Käyttötapaus** | Talous, audit | ETL, replikointi | Historiakyselyt | Synkronointi | Monimutkainen logiikka |

Käyttösuositukset:
- Ledger: Kriittinen data (talous, terveys, juridiset asiakirjat)
- CDC: ETL-prosessit, datavarasto, replikointi
- Temporal Tables: Aikapistekyselyt, "aikamatkustus", versionhallinta
- Change Tracking: Kevyt muutosseuranta
- Triggers: Monimutkainen liiketoimintalogiikka, räätälöidyt validoinnit


## SQL Server Audit (Enterprise Edition)
Virallinen auditointimekanismi SQL Serverissä, mahdollistaa esim. SELECT-lauseiden lokituksen.
Käytettävissä vain Enterprise Edition -versiossa. Kirjaukset menevät audit-lokiin (tiedostoon tai Windows event logiin).
Ei käsitellä enempää koska Enterprise-versiota ei ole käytössä.

<!--
## Yhteenveto

| Menetelmä         | Vaatii Enterprise-version | Tukee automaattista historiaa | Vaatii triggerit | Tukee SELECT-lokistusta |
|-------------------|--------------------|-------------------------------|--------------------|---------------------------|
| CDC               | ❌ (myös Std)       | 🔶 (muutostiedot erikseen)    | ❌                 | ❌                        |
| Temporal Tables   | ❌ (myös Std)       | ✅                             | ❌                 | ❌                        |
| Trigger + Audit   | ❌                  | ✅ (räätälöity)                | ✅                 | ❌                        |
| SQL Audit         | ✅ (Enterprise)     | 🔶 (ei tietorivit, mutta loki) | ❌                 | ✅                        |
-->


