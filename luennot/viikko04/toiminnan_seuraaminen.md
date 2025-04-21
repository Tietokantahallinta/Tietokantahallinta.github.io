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
    @source_name   = N'Asiakkaat',
    @role_name     = NULL;
-- muutokset esim. cdc.dbo_Asiakas_CT -taulusta.
```

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

## SQL Server Audit (Enterprise Edition)
Virallinen auditointimekanismi SQL Serverissä, mahdollistaa esim. SELECT-lauseiden lokituksen.
Käytettävissä vain Enterprise Edition -versiossa. Kirjaukset menevät audit-lokiin (tiedostoon tai Windows event logiin).
Ei käsitellä enempää koska Enterprise-versiota ei ole käytössä.

## Yhteenveto

| Menetelmä         | Vaatii Enterprise-version | Tukee automaattista historiaa | Vaatii triggerit | Tukee SELECT-lokistusta |
|-------------------|--------------------|-------------------------------|--------------------|---------------------------|
| CDC               | ❌ (myös Std)       | 🔶 (muutostiedot erikseen)    | ❌                 | ❌                        |
| Temporal Tables   | ❌ (myös Std)       | ✅                             | ❌                 | ❌                        |
| Trigger + Audit   | ❌                  | ✅ (räätälöity)                | ✅                 | ❌                        |
| SQL Audit         | ✅ (Enterprise)     | 🔶 (ei tietorivit, mutta loki) | ❌                 | ✅                        |



