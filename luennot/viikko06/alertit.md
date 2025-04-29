# Hälytykset ja seuranta

1. 📌**Miksi seuranta ja hälytykset ovat tärkeitä?**
- Havaitset ongelmat ajoissa (ennen kuin käyttäjät huomaavat)
- Ehdit reagoida esim. levytilan loppumiseen, suorituskykyongelmiin tai virheisiin
- Auttaa jatkuvassa ylläpidossa ja optimoinnissa
- Vähentää seisokkeja ja tietoturvariskejä

2. 🔍 **Seurattavia asioita SQL Serverissä
**
| Mitä kannattaa seurata?           | Miksi?                                       |
|----------------------------------|----------------------------------------------|
| Levytila                          | Estää varmistusten ja lokien epäonnistumisen |
| Tietokannan koko ja kasvu         | Hallitsee levyresursseja                     |
| Lokitiedostojen koko              | Estää transaktiolokin täyttymisen            |
| Suorituskyky (CPU, I/O, memory)   | Tunnistaa kuormituspiikit ja pullonkaulat    |
| Deadlockit                        | Paljastaa sovelluslogiikan ongelmat          | 
| Vikatilanteet (virhekoodit)       | Nopeampi vianmääritys                        |
| Agent Job -epäonnistumiset        | Automaatiovirheiden havaitseminen            |


3. 🛠️ **Työkalut ja välineet SQL Serverin seurantaan**
🔹 SQL Server Management Studio (SSMS)
- Activity Monitor (Live overview)
- Performance Dashboard Reports (sisäänrakennetut)

🔹 SQL Server Agent Alerts
- Mahdollistaa hälytysten lähettämisen tiettyihin virheisiin (esim. Error 9002 = Transaction log full)

🔹 SQL Server Profiler 
- Tarkka mutta raskas 
- sopii mainiosti tiettyihin tilanteisiin
- toiminnan seuranta, trace:n voi tallentaa tiedostoon (tai tietokantaan)

🔹 Performance Monitor (Windowsin oma)
- Esim. SQLServer:Buffer Manager, SQLServer:SQL Statistics

🔹 Extended Events (suositeltava korvike Profilerille)

🔹 Third-party / ulkoiset työkalut (ei välttämätön, mutta voit mainita)
- Redgate SQL Monitor, SolarWinds, Zabbix, Nagios

4. 🚨 **SQL Server Agent Alerts:**

- Seurata virhekoodeja (esim. 823, 824, 825 → levyongelmat)
- Luoda hälytyksiä suorituskyvystä
- Asettaa operaattoreita, joille lähetetään sähköposti/SMS

🧩 Esimerkki: Hälytys, jos Transaction Log täynnä (Error 9002)
```sql
USE msdb;
EXEC msdb.dbo.sp_add_alert
    @name = N'Log täynnä',
    @message_id = 9002,
    @severity = 0,
    @enabled = 1,
    @delay_between_responses = 300,
    @include_event_description_in = 1,
    @notification_message = N'Transaktioloki täynnä!',
    @job_name = NULL,
    @operator_name = N'DBA',
    @category_name = N'[Uncategorized]',
    @performance_condition = NULL,
    @wmi_namespace = NULL,
    @wmi_query = NULL,
    @event_description_keyword = NULL;
```

➕ Lisäksi: määritä operaattori
```sql
EXEC msdb.dbo.sp_add_operator  
    @name = N'DBA',  
    @enabled = 1,  
    @email_address = N'dba@example.com';
```

5. 📈 **Automaattinen valvonta – mitä voi ajastaa?**
- Vapaata levytilaa mittaava skripti
- "Kaatuneet" Agent-työt
- Tarkistus: milloin viimeksi varmistus otettu?
- Tietokantojen tila (sys.databases – ovatko ONLINE, SUSPECT, RECOVERY_PENDING?)

6. ✉️ **Hälytykset sähköpostitse (Database Mail)**
- Database Mail pitää ottaa käyttöön ja konfiguroida, SQL Server Agent käyttää sitä lähettääkseen sähköposteja operaattoreille
- SMTP-konfiguraation voi tehdä helposti SSMS:ssä

7. **🧪 Hyviä käytäntöjä**
- Älä tee jatkuvaa seurantaa tuotantoon ilman suodatusta (voi hidastaa palvelinta)
- Käytä Extended Events Profilerin sijaan
- Seuraa trenditietoa – ei vain yksittäisiä piikkejä
- Testaa, että hälytykset todella tulevat perille
- Dokumentoi hälytykset: mitä ne tarkoittavat ja mitä toimenpiteitä vaativat


## Yhteenveto: seuranta ja hälytykset SQL Serverissä

- Seuranta auttaa ennaltaehkäisemään ongelmia
- Työkalut: SSMS, Agent Alerts, Extended Events, Performance Monitor
- Seurattavat asiat: levytila, CPU, lokit, virheet, kuormitus
- SQL Agent Alerts: virhekoodin perusteella lähetetty ilmoitus
- Database Mail: mahdollistaa sähköposti-ilmoitukset
- Suositus: suunnittele, testaa ja dokumentoi hälytykset!


### 🛠️ Esimerkki: Hälytys, kun SQL Agent Job epäonnistuu
SQL Serverissä voit tehdä hälytyksen, joka lähettää sähköpostin aina, kun Agent Job epäonnistuu. 
Tarvitset:
- Käytössä olevan Database Mail -asetuksen ja määritellyn Operatorin
- Agent Jobille määritellyn notifikaation

🔹 A. Luo operaattori (DBA, sähköpostiosoite)
```sql
USE msdb;
EXEC msdb.dbo.sp_add_operator  
    @name = N'DBA',  
    @enabled = 1,  
    @email_address = N'dba@example.com';
```

🔹 B. Määritä Agent Jobin alertti epäonnistumiselle

Tämä tehdään SSMS:ssä graafisesti tai T-SQL:llä. Alla T-SQL-esimerkki:

```sql
EXEC msdb.dbo.sp_update_job  
    @job_name = N'Backup Job',  
    @notify_level_eventlog = 2,  -- Kirjaa epäonnistumisen event logiin
    @notify_level_email = 2,     -- 2 = vain epäonnistumisesta
    @notify_email_operator_name = N'DBA';
```

🔁 Tee tuo jokaiselle tärkeälle jobille, jonka epäonnistumisesta haluat ilmoituksen.

### 💾 2. SQL-kysely levytilan seurantaan
Tämä T-SQL-komento näyttää vapaata levytilaa (MB) kaikilla asemilla, joihin SQL Serverillä on pääsy:

```sql
EXEC xp_fixeddrives;
```

🔹 Jos haluat modernimman version, käytä sys.dm_os_volume_stats (versiosta SQL Server 2008 R2 SP1 alkaen):
```sql
SELECT
    vs.volume_mount_point AS [Drive],
    vs.logical_volume_name AS [Label],
    CONVERT(DECIMAL(10,2), vs.total_bytes / 1048576.0) AS [Total_MB],
    CONVERT(DECIMAL(10,2), vs.available_bytes / 1048576.0) AS [Free_MB],
    CONVERT(DECIMAL(5,2), 100.0 * vs.available_bytes / vs.total_bytes) AS [Free_%]
FROM sys.master_files mf
CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) vs
GROUP BY vs.volume_mount_point, vs.logical_volume_name, vs.total_bytes, vs.available_bytes
ORDER BY [Free_%];
```

🔍 Tällä saa yksityiskohtaisen näkymän jokaisen levyn tilasta, hyödyllinen käytössä olevien levyjen osalta.



## 🛠️ Automaattinen hälytys – Levytila vähissä

Tässä esimerkissä SQL Server seuraa levytilaa ja lähettää sähköpostihälytyksen, jos jollain käytössä olevalla asemalla on alle 10 % vapaata tilaa.

### 📌 Vaihe 1: Stored Procedure – levytilan tarkistus ja sähköposti

```sql
USE msdb;
GO

IF OBJECT_ID('dbo.CheckDiskSpaceAndAlert', 'P') IS NOT NULL
    DROP PROCEDURE dbo.CheckDiskSpaceAndAlert;
GO

CREATE PROCEDURE dbo.CheckDiskSpaceAndAlert
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @threshold DECIMAL(5,2) = 10.0;
    DECLARE @alertMessage NVARCHAR(MAX) = '';
    
    ;WITH VolumeInfo AS (
        SELECT
            vs.volume_mount_point AS Drive,
            vs.logical_volume_name AS Label,
            CONVERT(DECIMAL(10,2), vs.total_bytes / 1048576.0) AS Total_MB,
            CONVERT(DECIMAL(10,2), vs.available_bytes / 1048576.0) AS Free_MB,
            CONVERT(DECIMAL(5,2), 100.0 * vs.available_bytes / vs.total_bytes) AS Free_Pct
        FROM sys.master_files mf
        CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) vs
        GROUP BY vs.volume_mount_point, vs.logical_volume_name, vs.total_bytes, vs.available_bytes
    )
    SELECT @alertMessage = @alertMessage +
        'LEVY: ' + Drive + ' (' + Label + ') – VAPAAA: ' +
        CAST(Free_MB AS VARCHAR(10)) + ' MB (' +
        CAST(Free_Pct AS VARCHAR(5)) + '%)' + CHAR(13) + CHAR(10)
    FROM VolumeInfo
    WHERE Free_Pct < @threshold;

    IF LEN(@alertMessage) > 0
    BEGIN
        EXEC msdb.dbo.sp_send_dbmail
            @profile_name = 'SQLMailProfile',  -- Vaihda oikeaksi profiiliksi
            @recipients = 'dba@example.com',
            @subject = 'SQL Server Levytila Vähissä!',
            @body = 'Seuraavat levyt ovat kriittisesti täynnä:' + CHAR(13) + CHAR(10) + @alertMessage;
    END
END;
```

📅 Vaihe 2: Ajastus SQL Agent Jobilla
1. Luo uusi SQL Agent Job nimeltä **Check Disk Space**
2. Lisää askel:
- Tyyppi: Transact-SQL script
- Komento: EXEC dbo.CheckDiskSpaceAndAlert;
- Tietokanta: msdb

3. Aikatauluta esim. kahdesti päivässä
4. (Valinnainen) Lisää sähköposti-ilmoitus, jos jobi epäonnistuu

✅ Hyödyt
- Ehkäisee tilannteen, jossa varmistus tai tietokantaoperaatio epäonnistuu täyden levyn vuoksi
- Täysin automatisoitu ja sähköposti hälyttää nopeasti
- Esimerkki proaktiivisesta seurannasta tuotantoympäristössä



