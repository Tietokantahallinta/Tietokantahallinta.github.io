# Tietokannan varmistukset ja palautukset

Tieto on arvokasta, virheellinen tai puuttuva tieto on arvotonta. Tietokannoissa voi aina mennä jotain pieleen ja siksi tietojen varmistaminen ja palauttaminen on keskeistä liiketoiminnan jatkuvuuden kannalta. Riski ilman varmistuksia on tiedon menetys ja siitä aiheutuvat virhetilanteet tai jopa liiketoiminnan keskeytykset.

Varmistukset (BACKUP) pitää ottaa säännöllisesti ja varmistussuunnitelma tehdään sen perusteella, miten paljon ollaan valmiita menettämään dataa pahimmassa tapauksessa. Samoin varmistusten lisäksi pitää harjoitella ja testata tietokannan palauttaminen RESTORE), varmistuksesta ei ole apua, jos palautus ei onnistu tai palauttaminen kestää liian kauan.
**Varmistusstrategiat**
1. **RPO (Recovery Point Objective):**
- Kuinka paljon tietoa voidaan menettää.

2. **RTO (Recovery Time Objective):**
- Kuinka nopeasti järjestelmä pitää palauttaa.
3. **3-2-1-sääntö:**
- 3 kopiota tiedoista
- 2 eri mediaa
- 1 kopio eri fyysisessä sijainnissa



## Miksi varmistuksia pitää ottaa: jotain voi mennä rikki!

🔧 1. Laitteistoviat (Hardware failure)
- Kiintolevyn tai SSD:n fyysinen vika voi rikkoa tietokantatiedostoja (*.mdf, *.ldf).
- RAID-järjestelmän hajoaminen tai virheellinen konfigurointi voi aiheuttaa tiedostojen vioittumisen.

💡 2. Tiedostojärjestelmä- tai I/O-virheet
- Tietokanta voi vioittua, jos Windowsin tiedostojärjestelmässä tapahtuu virhe (esim. huono sektori levyllä).
- I/O-virheet voivat johtaa siihen, että SQL Server ei voi lukea tai kirjoittaa tietoja oikein.

⚡ 3. Virtakatko tai äkillinen sammutus
- Jos palvelin sammutetaan äkillisesti (esim. sähkökatko), käynnissä olevat transaktiot voivat jäädä puolitiehen.
- Vaikka SQL Server palauttaa usein tilan transaktiolokista, joskus tämä voi epäonnistua.

💾 4. Tietokannan looginen vioittuminen
- Sovellusbugit tai käyttäjän virheet voivat rikkoa tietorakenteita.
- Korruptoitunut tietue, indeksi tai sivurakenne (page corruption) voi estää tiedon käytön.

🔐 5. Haittaohjelmat tai kiristyshaittaohjelmat
- Tietokantatiedostot voidaan salata tai muuttaa käyttökelvottomiksi.
- Joissain tapauksissa haittaohjelma voi poistaa tai vahingoittaa tiedostoja.

🧑‍💻 6. Inhimilliset virheet
- Tietojen tai tietokantojen vahingossa poistaminen (DROP DATABASE).
- Taulujen, indeksien tai muiden rakenteiden virheellinen muuttaminen.

🧩 7. SQL Server -bugit tai virheellinen konfigurointi
- Harvinaisissa tapauksissa SQL Serverin ohjelmavirhe voi aiheuttaa vioittumista.
- Esimerkiksi tempdb:n toimintahäiriö voi estää koko palvelimen käynnistymisen.
- Levytilan loppuminen estää tietokannan käytön, onneksi tästä selviää ilman datan palautusta jos levytilaa järjsetyy lisää.

🔁 Milloin palautus varmuuskopiosta on ainoa ratkaisu?
- Jos tiedostot ovat fyysisesti vioittuneet.
- Jos looginen vioittuminen on vakava (esim. useita sivuja rikki eikä CHECKDB korjaa).
- Jos palautus halutaan tiettyyn ajankohtaan (ennen virhettä tai väärää päivitystä).

## Mitä kannattaa huomioida mahdollisten virheitilanteiden välttämiseksi

🔒 1. Tee säännölliset varmuuskopiot (BACKUP)
- Täysi varmuuskopio (FULL) vähintään kerran päivässä.
- Transaktiolokin varmuuskopio (LOG) usein, esim. 15 min välein — erityisesti tuotantoympäristöissä.
- Testaa palautus säännöllisesti: pelkkä varmuuskopio ei riitä, ellei se toimi.

🧪 2. Aja CHECKDB säännöllisesti
- Komento DBCC CHECKDB tarkistaa tietokannan sisäisen eheyden.
- Ajoita se yöllä tai hiljaisina aikoina.
- Jos CHECKDB löytää virheitä, toimi heti: varmuuskopioi ja harkitse palautusta tai korjausta (REPAIR_ALLOW_DATA_LOSS vain viimeisenä keinona).

⚙️ 3. Käytä luotettavaa ja suojattua tallennustilaa
- Käytä RAID 10 tai muuta vikasietoista levyjärjestelmää.
- Varmista, että levyillä ei ole huonoja sektoreita.
- Käytä UPS-laitetta (keskeytymätön virransyöttö) sähkökatkojen varalta.

🧍‍♂️ 4. Rajoita ja hallitse käyttöoikeuksia
- Estä ei-teknistä henkilökuntaa suorittamasta kriittisiä DDL-toimintoja (kuten DROP, ALTER).
- Käytä roolipohjaista käyttöoikeushallintaa.
- Aktivoi auditoiva lokitus (esim. SQL Server Audit) tärkeille muutoksille.

🌐 5. Pidä SQL Server ja Windows ajan tasalla
- Asenna turva- ja bugikorjaukset (Service Packit, Cumulative Updates).
- Vanhat versiot sisältävät tunnettuja haavoittuvuuksia ja bugeja.

🔁 6. Suojaa ympäristö haittaohjelmilta
- Käytä ajantasaista virustorjuntaa, mutta älä skannaa SQL:n tietokantatiedostoja reaaliajassa (ne voivat lukittua!).
- Pidä palomuurisäännöt ja käyttöoikeudet minimissä.

📊 7. Seuraa suorituskykyä ja järjestelmälogia
- Monitoroi levyviiveitä (I/O latency), muistin käyttöä ja prosessikuormaa.
- Tarkkaile SQL Serverin virhelokia (ERRORLOG) ja tapahtumalokia (Event Viewer).

🗂️ 8. Älä pidä tietokantaa liian suurena ilman huoltoa
- Suorita indeksien uudelleenrakennus ja statistiikan päivitys säännöllisesti.
- Vältä levytilan loppumista — se voi pysäyttää koko palvelimen.

🧭 Yhteenvetona:

| Suositus               | Hyöty                                  |
|------------------------|----------------------------------------|
| Varmuuskopiot          | Mahdollistaa palautuksen               |
| CHECKDB                | Paljastaa vioittumiset ajoissa         |
| RAID + UPS             | Suojaa laitevioilta ja sähkökatkoilta  |
| Käyttöoikeushallinta   | Ehkäisee inhimilliset virheet          |
| Päivitykset ja suojaus | Estää tunnetut uhat ja haavoittuvuudet |


## SQL Server Eheysmallit (Recovery Models)
Recovery model on tärkeä osa SQL Serverin varmuuskopiointistrategiaa, sillä se määrittää, kuinka SQL Server tallentaa transaktioita ja kuinka varmuuskopiot otetaan. Se vaikuttaa siihen, kuinka paljon tietoa voidaan palauttaa ja kuinka tarkasti tietokanta voidaan palauttaa haluttuun ajankohtaan. Recovery Model asetetaan jokaiselle tietokannalle erikseen. **SSMS**: valitse tietokanta ==> Properties ==> Options ==> recovery Models-valinta.

SQL Serverissä on kolme pääasiallista recovery modelia: Simple, Full ja Bulk-Logged. Ne määrittävät, kuinka SQL Server käsittelee transaktiotietoja ja kuinka varmuuskopiot toimivat.

1. Simple Recovery Model
- SQL Server tallentaa vain sen hetkiset tiedot ja ei pidä kirjaa transaktioista pysyvästi. Transaktiolokit (logit) eivät kasva jatkuvasti, vaan ne "kierrätetään" eli vanhat transaktiotiedot poistetaan, kun varmuuskopiot otetaan.
- Tämä tarkoittaa, että vain täydelliset varmuuskopiot (FULL) ovat käytettävissä palautukseen, eikä transaktiolokin varmuuskopioita voi käyttää. Palauttaminen tapahtuu viimeisimmän täydellisen varmuuskopion ja mahdollisten erillisten differential-varmuuskopioiden avulla.
**Hyödyt ja haitat**:
- Hyöty: Yksinkertainen hallita ja transaktiolokit eivät kasva hallitsemattomiksi.
- Haitat: Et voi palauttaa tietokantaa tarkalleen tiettyyn ajankohtaan, koska transaktiolokit eivät ole käytettävissä.

Sopii parhaitensovelluksiin, joissa ei ole kriittistä tarvetta palauttaa tietoja tarkalleen tiettyyn hetkeen (esim. kehitysympäristöt tai pienet tietokannat, joissa tiedot eivät ole kriittisiä).

2. Full Recovery Model
- SQL Server tallentaa kaikki transaktiot täydellisesti ja säilyttää ne lokitiedostoissa (transaction log).
- Tällä mallilla voit tehdä täydellisiä varmuuskopioita (FULL) sekä transaktiolokin varmuuskopioita (LOG). Tämä mahdollistaa tietokannan palauttamisen tarkalleen haluttuun hetkeen, kunhan olet ottanut varmuuskopiot ajoittain.
- Tällöin, jos tietokanta menee rikki, voit palauttaa sen täydellisesti varmuuskopioista ja mahdollisesti myös transaktiolokeista, jolloin menetetyt tiedot voidaan minimoida.

**Hyödyt ja haitat**:
- Hyöty: Voit palauttaa tietokannan mihin tahansa ajankohtaan, koska kaikki transaktiot tallennetaan.
- Haitat: Transaktiolokit voivat kasvaa erittäin suuriksi, ja siksi niitä täytyy varmuuskopioida säännöllisesti (log backup). Ilman log varmuuskopioita tietokanta voi käydä liian suureksi ja estää palautukset.

Sopii parhaiten mihin tahansa ympäristöön, jossa tietojen eheys ja saatavuus ovat kriittisiä ja tietokannan tietoja on ylläpidettävä tarkasti.

3. Bulk-Logged Recovery Model
- Bulk-Logged recovery model on eräänlainen välimuoto Full ja Simple mallien välillä.
- Transaktiolokit tallennetaan normaalisti, mutta tietyt suuret tiedonmuokkaukset, kuten bulk-insertit (esim. suurten tietomäärien lataaminen tauluun), tallennetaan lokiin vähemmän yksityiskohtaisesti.
- Tämä voi johtaa siihen, että tiettyjä tietokannan toimenpiteitä ei voi palauttaa niin tarkasti kuin Full-recovery modelissa. Varmuuskopioiden ottaminen toimii samalla tavalla kuin Full-mallissa, mutta bulk-lataukset eivät ole täysin todenmukaisia transaktiolokeissa.

**Hyödyt ja haitat**:
- Hyöty: Suuri suorituskyky ja vähemmän levytilaa käytetään bulk-toimintojen aikana.
- Haitat: Palautus ei ole yhtä tarkka kuin Full-mallissa, ja ei-logged-toimenpiteet voivat jäädä palauttamatta.

Sopii parhaiten ympäristöihin, joissa suorituskyky on tärkeä ja joissa on tarve käsitellä suuria tietomääriä (esim. datan siirtoja), mutta samalla tarvitaan varmuuskopioita, jotta voidaan palauttaa normaali käyttötila.

### Varmuuskopioiden tyypit ja niiden yhteys recovery modeen

| Recovery Model | Täydellinen varmuuskopio (FULL) | Transaktiolokin varmuuskopio (LOG) | Differential varmuuskopio (DIFF)                  |
|----------------|---------------------------------|------------------------------------|---------------------------------------------------|
| Simple         | Kyllä                           | Ei                                 | Kyllä (vain ennen viimeisintä FULL varmuuskopiota)|
| Full           | Kyllä                           | Kyllä                              | Kyllä                                             |
| Bulk-Logged    | Kyllä                           | Kyllä (vain tietyt toiminnot)      | Kyllä                                             |

- Täydellinen varmuuskopio (FULL) tallentaa koko tietokannan tilan.
- Transaktiolokin varmuuskopio (LOG) tallentaa kaikki tehdyt muutokset ja mahdollistaa palautuksen mihin tahansa ajankohtaan (Full-malli).
- Differential varmuuskopio (DIFF) tallentaa vain sen osan tiedoista, jotka ovat muuttuneet viimeisen täydellisen varmuuskopion jälkeen. Tämä on hyödyllinen, jos tarvitset palautusta tiettyyn ajankohtaan, mutta haluat vähemmän varmuuskopion kokoa kuin täydellisessä varmuuskopiossa.

**Yhteenveto**:
- Simple Recovery Model: Vain täydelliset varmuuskopiot. Ei transaktiolokin varmuuskopioita. Palautus viimeisimpään täydelliseen varmuuskopioon.
- Full Recovery Model: Täydelliset varmuuskopiot ja transaktiolokin varmuuskopiot. Mahdollistaa palautuksen tarkalleen haluttuun ajankohtaan.
- Bulk-Logged Recovery Model: Bulk-toiminnot eivät tallennu transaktiologiin normaalisti. Muuten samanlaiset varmuuskopiot kuin Full-mallissa.

----


## Varmistukset SQL Serverissä
Varmistuksien ottamiseen on kolme erilaista menetelmää:
1. Täysi varmistus (Full Backup):
- Kopioi koko tietokannan yhdellä kertaa.
2. Lokivarmistus (Transaction Log Backup):
- Varmistaa transaktiolokin ja mahdollistaa pistepalautukset.
3. Erovarmistus (Differential Backup):
- Varmistaa muutokset viimeisestä täydestä varmistuksesta lähtien.

## Tietokannan varmistus 

On hyvä osata varmistukset ja palautukset sekä SSMS:n käyttöliittymän kautta, että T-SQL -komennoilla.

1. Tietokannan varmuuskopiointi

Oletetaan, että tietokannan nimi on MyDatabase ja että varmuuskopio otetaan paikalliselle levylle tiedostoon C:\Backups\MyDatabase.bak.

a. Täydellinen varmuuskopio
```sql
BACKUP DATABASE MyDatabase
TO DISK = 'C:\Backups\MyDatabase.bak'
WITH FORMAT, INIT, NAME = 'Full Backup of MyDatabase';
```
- FORMAT: Tämä luo uuden varmuuskopiotiedoston ja poistaa vanhat varmuuskopiot.
- INIT: Jos tiedosto on jo olemassa, se ylikirjoitetaan.
- NAME: Antaa varmuuskopiolle nimen.

b. Transaktiolokin varmuuskopio (Full Recovery Modelissa)
Jos MyDatabase on määritelty Full Recovery Model -malliin, sinun tulee ottaa myös transaktiolokin varmuuskopiot säännöllisesti, jotta voit palauttaa tietokannan mihin tahansa ajankohtaan.

```sql
BACKUP LOG MyDatabase
TO DISK = 'C:\Backups\MyDatabase_Log.trn'
WITH INIT, NAME = 'Transaction Log Backup for MyDatabase';
```
- Tämä komento ottaa varmuuskopion vain transaktiolokeista.
- Varmista, että transaktiolokin varmuuskopiot otetaan ennen kuin lokit kasvaa liian suuriksi.

c. Differential varmuuskopio 
- Jos haluat ottaa differential varmuuskopion, joka tallentaa vain muutokset edellisestä täydellisestä varmuuskopiosta, käytä seuraavaa komentoa:

```sql
BACKUP DATABASE MyDatabase
TO DISK = 'C:\Backups\MyDatabase_Diff.bak'
WITH DIFFERENTIAL, NAME = 'Differential Backup of MyDatabase';
```
- DIFFERENTIAL: Tämä komento ottaa varmuuskopion vain muutoksista, jotka ovat tapahtuneet viimeisen täydellisen varmuuskopion jälkeen.

##  Tietokannan palautus
Nyt kun varmuuskopiot on otettu, voimme palauttaa tietokannan eri tavoilla riippuen siitä, mitä varmuuskopioita on käytettävissä ja mikä recovery model on käytössä.

a. Palautus täydellisestä varmuuskopiosta
- Jos tarvitset palautuksen viimeisimmästä täydellisestä varmuuskopiosta, käytä seuraavaa komentoa:
```sql
RESTORE DATABASE MyDatabase
FROM DISK = 'C:\Backups\MyDatabase.bak'
WITH REPLACE, NORECOVERY;
```
- WITH REPLACE: Tämä ylikirjoittaa olemassa olevan tietokannan, jos se on jo olemassa.
- NORECOVERY: Tämä jätättää tietokannan "restore" tilaan, jolloin voit jatkaa palauttamista esimerkiksi differential- tai transaktiolokin varmuuskopion kanssa.

b. Palautus täydellisestä varmuuskopiosta ja transaktiolokeista (Full Recovery Model)
- Jos sinulla on myös transaktiolokin varmuuskopioita ja haluat palauttaa tietokannan mihin tahansa ajankohtaan, palautusprosessi on seuraava:
- Palauta täydellinen varmuuskopio:
```sql
RESTORE DATABASE MyDatabase
FROM DISK = 'C:\Backups\MyDatabase.bak'
WITH REPLACE, NORECOVERY;
```
- Palauta transaktiolokin varmuuskopio (joka on otettu täydellisen varmuuskopion jälkeen):

```sql
RESTORE LOG MyDatabase
FROM DISK = 'C:\Backups\MyDatabase_Log.trn'
WITH NORECOVERY;
```
- NORECOVERY: Tämä pitää tietokannan palautustilassa, jotta voit palauttaa lisää lokitiedostoja tarvittaessa.

- Palauta viimeinen transaktiolokin varmuuskopio ja aseta tietokanta käyttövalmiiksi:

```sql
RESTORE LOG MyDatabase
FROM DISK = 'C:\Backups\MyDatabase_Log.trn'
WITH RECOVERY;
```
- WITH RECOVERY: Tämä asettaa tietokannan valmiiksi käytettäväksi palautuksen jälkeen.

c. Palautus differential varmuuskopiosta
- Jos sinulla on differential varmuuskopio ja haluat palauttaa sen, prosessi on seuraava:
- Palauta viimeisin täysi varmuuskopio:

```sql
RESTORE DATABASE MyDatabase
FROM DISK = 'C:\Backups\MyDatabase.bak'
WITH REPLACE, NORECOVERY;
```

Palauta differential varmuuskopio:

```sql
Copy
FROM DISK = 'C:\Backups\MyDatabase_Diff.bak'
WITH RECOVERY;
```
- Tämä palauttaa viimeisimmän täydellisen varmuuskopion ja sen jälkeen tapahtuneet muutokset.

------------
## Point-in-Time Recovery (PITR)

Point-in-Time Recovery tarkoittaa tietokannan palauttamista johonkin tarkkaan ajankohtaan menneisyydessä — ei vain viimeisimpään varmistukseen, vaan esimerkiksi sekuntien tarkkuudella ennen virheellistä tapahtumaa.

### Miksi PITR on tärkeä?
- Jos joku tekee virheen (esim. vahingossa poistaa tauluja tai päivittää vääriä tietoja), voit palauttaa tietokannan hetkeen juuri ennen virhettä.
- Se estää suuremman tietojen menetyksen verrattuna siihen, että palautettaisiin edellinen täysi varmistus (joka voi olla useiden tuntien tai päivien vanha).

### Miten PITR toimii käytännössä SQL Serverissä?
1. Täysi varmistus otetaan ensin.
2. Transaktiolokivarmistuksia otetaan säännöllisesti.
3. Kun pitää palauttaa:
- Palautetaan ensin täysi varmistus ilman lopullista "RECOVERY" -vaihetta (WITH NORECOVERY).
- Sitten palautetaan transaktiolokit ja pysäytetään palautus siihen tarkkaan hetkeen (WITH STOPAT).

**Esimerkki:**<br>
Oletetaan, että klo 14:00 otettiin täysi varmistus.<br>
Klo 15:00 joku poistaa vahingossa tärkeän taulun.<br>
Sinulla on transaktiolokivarmistukset.<br>

*Haluat palauttaa tilanteen klo 14:59:30:*

```sql
-- Palautetaan täysi varmistus ilman viimeistelyä
RESTORE DATABASE MyDatabase
FROM DISK = 'C:\Backup\MyDatabase_FULL.bak'
WITH NORECOVERY;

-- Palautetaan lokivarmistus ja pysäytetään tarkkaan aikaan
RESTORE LOG MyDatabase
FROM DISK = 'C:\Backup\MyDatabase_LOG.trn'
WITH STOPAT = '2025-04-28T14:59:30', RECOVERY;
```

Nyt tietokanta on palautettu sekunnilleen ennen virhettä.

**Tärkeää huomata:**
- PITR onnistuu vain jos transaktiolokit ovat käytettävissä.
- Tietokannan täytyy olla FULL- tai BULK-LOGGED-tilassa (ei SIMPLE-tila).


#### 📜 Point-in-Time Recovery -demo (PITR) – esimerkki-skripti
```sql
-- 1. Luo testiympäristö: uusi tietokanta ja taulu
CREATE DATABASE PITRDemoDB;
GO

USE PITRDemoDB;
GO

CREATE TABLE DemoTable (
    ID INT PRIMARY KEY,
    Info NVARCHAR(100)
);
GO

-- 2. Lisää alkuperäistä dataa
INSERT INTO DemoTable (ID, Info) VALUES (1, 'Alkuperäinen tieto');
GO

-- 3. Ota TÄYSI varmistus heti
BACKUP DATABASE PITRDemoDB
TO DISK = 'C:\Backup\PITRDemoDB_FULL.bak'
WITH INIT, NAME = 'PITR Täysi varmistus';
GO

-- 4. Tee lisää muokkauksia (simuloidaan normaalia käyttöä)
INSERT INTO DemoTable (ID, Info) VALUES (2, 'Lisätty tieto 1');
WAITFOR DELAY '00:00:05'; -- pieni viive, että aika muuttuu
INSERT INTO DemoTable (ID, Info) VALUES (3, 'Lisätty tieto 2');
GO

-- 5. Ota transaktiolokin varmistus
BACKUP LOG PITRDemoDB
TO DISK = 'C:\Backup\PITRDemoDB_LOG1.trn'
WITH INIT, NAME = 'PITR Lokivarmistus 1';
GO

-- 6. Simuloidaan VIRHE: joku poistaa taulun
DROP TABLE DemoTable;
GO

-- 7. Ota uusi transaktiolokivarmistus (sisältää virheen)
BACKUP LOG PITRDemoDB
TO DISK = 'C:\Backup\PITRDemoDB_LOG2.trn'
WITH INIT, NAME = 'PITR Lokivarmistus 2';
GO
```
#### 🛠 Palautusvaiheet – Point-in-Time Recovery
```sql
-- 1. Pudota hävitä tai riko tietokanta (simuloidaan tilanne jossa pitää palauttaa kokonaan)
USE master;
GO
ALTER DATABASE PITRDemoDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
DROP DATABASE PITRDemoDB;
GO

-- 2. Palautetaan täysi varmistus ILMAN lopullista palautusta
RESTORE DATABASE PITRDemoDB
FROM DISK = 'C:\Backup\PITRDemoDB_FULL.bak'
WITH NORECOVERY;
GO

-- 3. Palautetaan ensimmäinen lokivarmistus, ja STOPAT ennen virhettä
RESTORE LOG PITRDemoDB
FROM DISK = 'C:\Backup\PITRDemoDB_LOG1.trn'
WITH STOPAT = '2025-04-28T12:34:50', -- <-- Aika hetki ennen virhettä (säädä kellonaika)
RECOVERY;
GO

-- 4. Tarkista palautus
USE PITRDemoDB;
SELECT * FROM DemoTable;
```
----------

## Miten SQL Server -varmistukset kannattaa ajastaa?
1. Ymmärrä tarpeet:
- RPO (Recovery Point Objective)<br>
= Kuinka paljon tietoa voidaan menettää? (esim. 5 min, 1 tunti, 1 päivä?)

- RTO (Recovery Time Objective)<br>
= Kuinka nopeasti järjestelmä pitää palauttaa? (esim. 30 min, 2 tuntia?)

#### Eräs ajastusmalli

|-----------------|------------------------------------------|--------------------------------------|
| Varmistustyyppi | Kuinka usein?                            | Tavoite                              |
|-----------------|------------------------------------------|--------------------------------------|
| Täysi varmistus | 1x vuorokaudessa (esim. yöllä klo 02:00) | Palautuspiste edelliseen päivään     |
| Erovarmistus    | 2–4x päivän aikana (esim. 6h välein)     | Palautus viimeiseen erohetkeen       |
| Lokivarmistus   | 10–15 minuutin välein                    | Mahdollistaa point-in-time recoveryn |
|-----------------|------------------------------------------|--------------------------------------|


**Pieni tuotantotietokanta (vähemmän kriittinen):**
- Täysi varmistus klo 02:00
- Erovarmistus klo 08:00, 14:00, 20:00
- Lokivarmistukset 30 minuutin välein

**Kriittinen tuotantotietokanta (pankki, verkkokauppa tms.):**
- Täysi varmistus klo 02:00
- Erovarmistus 4 tunnin välein (06:00, 10:00, 14:00, 18:00, 22:00)
- Lokivarmistukset 5–10 minuutin välein

**🔥 Miksi näin?**
- Täysi varmistus on raskas → tehdään silloin, kun käyttö on vähäisintä (yöllä).
- diff-varmistukset ovat kevyempiä → nopeuttavat palautuksia ilman raskasta täyden varmistuksen käyttöä.
- Lokivarmistukset mahdollistavat tarkkuuden, esim. palautuksen 09:23, eikä vain viimeiseen diff- tai full-varmistukseen.


## Ajastaminen SQL Serverissä

Toimintojen ajastamiseen käytetään SQL Server Agent:ia. Huomaa, että sen pitää olla käynnissa ja luultavasti joudut päivittämään käynnistysasetuksia (Services) asennusken jälkeen. Agentin pitää käynnistyä automaattisesti ja lisäksi tarkista minkä käyttäjän oikeuksilla se toimii. Yleensä tehdää erillinen palvelutunnus joka luvitetaan tietokantaan (Login ja User) ja sitä ei käytetä mihinkään muuhun tarkoitukseen. Tämän palvelutunnuksen salasana ei vanhene automaattisesti esimerkiksi kuukauden välein, vaan vaihtaminen tehdään hallitusti. Mitä tapahtuu, jos salasana vanhenee ja ajastuksien takana olevat skriptit eivät toimikkaan?


**Jobit rakennetaan vaikka näin:** 
- yksi jobi täyteen varmistukseen, 
- toinen erovarmistuksiin, 
- kolmas lokivarmistuksiin.

Tutustu myös Maintenance Plan Wizard:iin, jossa voi tehdä paljon asioita graafisen käyttöliittymän kautta SSMS:n avulla.

#### Esimerkki ajastus-idea:

(SQL Server Agent Job, joka tekee lokivarmistuksen 15 min välein)

```sql
BACKUP LOG MyDatabase
TO DISK = 'D:\Backups\MyDatabase_LOG.trn'
WITH INIT, NAME = '15 min Lokivarmistus';
```


#### 🛡️ Parhaita käytäntöjä ajastukseen:
- Valvo varmistustöiden onnistumisia (lähetä hälytys epäonnistumisista).
- Siivoa vanhat varmistukset automaattisesti ja manuaalisesti tarpeen mukaan (levytilanhallinta).
- Testaa palautuksia säännöllisesti — varmistus ilman palautustestiä on yhtä tyhjän kanssa.

#### 📍 Yhteenveto:
- Tee täysi varmistus kerran päivässä.
- Tee erovarmistuksia päivän mittaan.
- Tee lokivarmistuksia usein (10–30 min välein).
- Automatisoi kaikki SQL Server Agntilla.

## Varmistukset SQL Serverin ulkopuolelta
Varmistukset voi tehdä SQLCMD-sovelluksen avulla ja ajastaa Windowsin Task Schedulerilla. Tarvitaan ensin cmd-tiedosto (tai bat) joka sisältää varmistuksen ottamisen. Tässä esimerkissä otetaan varmistuksen joka päivä ja kierrätetään varmistustiedostoa viikon kuluttua:
```code
sqlcmd -E -Q "backup database Formula1 to disk = 'c:\temp\cmdtesti\F1.bak' "
Xcopy .\F1.bak .\F1_%date:~0,3%.bak /Y /-I
```
Ajastus Task Schedulerilla. Tämä on siis vaihtoehtoinen ja täysin toimiva tapa ottaa ajastettuja varmistuksia.


<!-- 
//TODO
### 🛡️ SQL Server Varmistusten Ajastussuunnitelma
Varmistusten Tyypit ja Ajastus

Varmistustyyppi	Ajankohta	Toistuvuus	Huomioita
Täysi varmistus	02:00 yöllä	1x päivässä	Raskas operaatio, vähän käyttäjiä
Erovarmistus	08:00, 14:00, 20:00	3x päivässä	Nopeampi palautus
Lokivarmistus	Joka 15. minuutti (00, 15, 30, 45)	96x päivässä	Point-in-time recovery mahdollinen
SQL Server Agent -työt (Jobs)

Työ	Toiminto	Ajoitukset
FullBackupJob	Täysi varmistus (BACKUP DATABASE)	Kerran vuorokaudessa klo 02:00
DiffBackupJob	Erovarmistus (BACKUP DATABASE WITH DIFFERENTIAL)	Kolmesti päivässä (08:00, 14:00, 20:00)
LogBackupJob	Lokivarmistus (BACKUP LOG)	15 min välein
Esimerkkikuvaukset
Täysi varmistus (Full Backup)
sql
Copy
Edit
BACKUP DATABASE MyDatabase
TO DISK = 'D:\Backups\MyDatabase_FULL.bak'
WITH INIT, FORMAT, NAME = 'Täysi varmistus';
Aikataulu: Kerran päivässä klo 02:00

SQL Server Agent Job: FullBackupJob

Erovarmistus (Differential Backup)
sql
Copy
Edit
BACKUP DATABASE MyDatabase
TO DISK = 'D:\Backups\MyDatabase_DIFF.bak'
WITH DIFFERENTIAL, INIT, NAME = 'Erovarmistus';
Aikataulu: 08:00, 14:00 ja 20:00

SQL Server Agent Job: DiffBackupJob

Lokivarmistus (Transaction Log Backup)
sql
Copy
Edit
BACKUP LOG MyDatabase
TO DISK = 'D:\Backups\MyDatabase_LOG.trn'
WITH INIT, NAME = 'Lokivarmistus';
Aikataulu: Joka 15. minuutti

SQL Server Agent Job: LogBackupJob

Hyviä käytäntöjä ajastukseen
📈 Valvo varmistustuloksia: Aseta sähköposti-ilmoitukset epäonnistumisista.

🗑️ Poista vanhat varmistukset automaattisesti (esim. yli 7 päivää vanhat tiedostot).

🔁 Testaa palautukset säännöllisesti (esim. kuukausittain).

🧠 Muista!
Varmistaminen on helppoa — palauttaminen on taidetta.
Harjoittele palautuksia kuin oikeassa katastrofitilanteessa.

👨‍💻
Haluatko vielä erikseen lyhyen esimerkin siitä, miten SQL Server Maintenance Plan Wizardissa nämä voisi luoda helposti klikkaamalla, ilman käsin tehtyjä jobeja?
(Siis graafinen tapa varmistusten ajastamiseen.) 🚀



 -->



## 🛠️ Maintenance Plan Wizard – Varmistusten ajastaminen ja muut toimenpiteet

### 📋 Mihin Maintenance Plan Wizardia käytetään?
- Varmistusten ajastus (täysi, ero, loki)
- Tietokannan optimointi (indeksien huolto, update stats)
- Lokitilojen siivous
- Vanhojen varmistusten automaattinen poisto
- Yleinen huolto (käyttäjäystävällinen rajapinta)

🧭 Vaiheittainen esimerkki: Täyden varmistuksen ajastus
1. Avaa SSMS ja yhdistä SQL Server -instanssiisi.
2. Navigoi Object Explorerista:<br>
Management → Maintenance Plans → oikea klikkaus → "Maintenance Plan Wizard..." <br>

3. Anna suunnitelmalle nimi
- Esim. "Daily Full Backup"
- tavittaessa kujoita kuvaus
- Valitse Single schedule for the entire plan.

4. Aseta ajastusaika
- Schedule name: DailyBackupSchedule
- Occurs: Daily, Occurs every 1 day
- Start time: esim. 02:00

✅ Tämä tekee joka yö klo 02:00 ajettavan varmistuksen.

5. Valitse toimenpiteet
- Valitse Back Up Database (Full).

Kun teet erikseen ero- ja lokivarmistuksia, valitset vastaavasti "Back Up Database (Differential)" ja "Back Up Database (Transaction Log)".

6. Määritä varmistuksen asetukset
- Select databases: Valitse tietokannat (tai kaikki, pl. system-databases jos haluat).
- Varmistustiedostojen sijainti: esim. D:\Backups\
- Backup file extension: .bak
- Create a sub-directory for each database (suositeltava)

✅ Tämä tekee järjestelmälliset varmistukset automaattisesti oikeisiin kansioihin.

7. Aseta lisäasetukset
- verify backup integrity: ✔️ (suositeltavaa)
- Compress backup (jos käytössä SQL Server versiossa) ✔️

8. Viimeistele
- Wzard näyttää yhteenvedon.
- Klikkaa Finish.

👉 Nyt sinulla on automaattinen täysvarmistussuunnitelma, joka pyörii joka yö klo 02:00!

### 🎯 Maintenance Plan Wizard - hyödyt
-Ei tarvitse käsin kirjoittaa BACKUP-komentoja.
- Voi hallita monimutkaisempia aikatauluja helposti.
- Selkeät logit: näet SSMS:n puolelta heti, onnistuivatko varmistukset.
- Mahdollisuus laajentaa myöhemmin (esim. lisää ero- ja lokivarmistukset samaan suunnitelmaan).




### 🖥️ Ajastettu SQL-varmistus Windows Task Schedulerilla:
- Tehdään T-SQL-skripti (.sql-tiedosto), joka sisältää varmistuskomennon.
- Ajetaan tämä skripti komentoriviltä käyttäen sqlcmd-työkalua.
- Windows Task Scheduler käynnistää sqlcmd-komennon ajastettuna aikana.

📜 Esimerkki: Käytännön vaiheittain
1. Luo T-SQL-skripti
Tee uusi tiedosto, esim. C:\BackupScripts\FullBackup.sql, ja kirjoita sinne:
```sql
BACKUP DATABASE MyDatabase
TO DISK = 'D:\Backups\MyDatabase_FULL.bak'
WITH INIT, FORMAT, NAME = 'Daily Full Backup';
```

2. Luo ajettava komentorivi (.bat tiedosto tai suora komento)
Voit tehdä erillisen .bat-tiedoston (esim. RunBackup.bat), jossa on:
```sql
sqlcmd -S localhost -d master -E -i "C:\BackupScripts\FullBackup.sql"
```
Selitykset:
- -S localhost → palvelimen nimi (tai instanssin nimi, esim. localhost\SQLExpress)
- -d master → aloitetaan master-tietokannasta
- -E → käytetään Windows Authentication (tai -U username -P password jos SQL-auth)
- -i → input-tiedosto (T-SQL-skripti)

✅ sqlcmd on osa SQL Serverin mukana tulevaa komentorivityökalua.

3. Luo Task Scheduler -ajastus
- Avaa Task Scheduler (Tehtävien ajoitusohjelma).
- Valitse Create Task (älä "Create Basic Task", saat enemmän hallintaa).

**Yleiset asetukset:**
- Name: Daily Full Backup
- Run with highest privileges: ✔️ (vaatii admin-oikeudet varmistuksiin)
- Configure for: Windows Server / Windows 10 tms.

**Trigger (Ajastus):**
- New Trigger → Daily → Start at 02:00

**Action (Toiminto):**
- New Action → Start a Program
- Program/script: sqlcmd
- Add arguments:

´´´sql
-S localhost -d master -E -i "C:\BackupScripts\FullBackup.sql"
```
Tai jos käytät .bat-tiedostoa:
```sql
Program/script: C:\BackupScripts\RunBackup.bat
```
✅ Näin Task Scheduler suorittaa varmistuksen automaattisesti oikeaan aikaan.

🚨 Tärkeitä huomioita:
- Käyttäjätilillä jolla Task ajetaan, pitää olla oikeus ajaa varmistuksia SQL Serverissä.
- Polut (esim. backup-hakemisto) pitää olla olemassa, muuten varmistus epäonnistuu.

🎯 Plussat ja miinukset
 + Ei vaadi SQL Server Agentia	
 + Hyvin kevyt ja joustava ratkaisu	
 + Helppo siirtää muihin järjestelmiin	
 - Virheiden hallinta heikompaa
- Ei graafista palautelokia
- Komennot pitää ylläpitää itse




----
# 📋 Master-tietokannan varmistus
1. Master-tietokannan erityispiirteet, sisältää koko palvelimen kokoonpanotiedot, kuten:
- tietokannat
- Serverin asetukset
- Linked serverit
- SQL Serverin metatiedot

Varmistamatta jättäminen voi estää palauttamista, jos SQL Serverin asennus menee rikki tai jos tapahtuu muita ongelmia.

2. Masterin varmistuksens tarpeellisuus
- Master-tietokannan varmistus on tärkeä, mutta sitä ei tarvitse varmistaa yhtä usein kuin käyttäjätietokantoja.
- Päivittäinen varmistus voi olla liiallista, mutta viikoittainen tai kuukausittainen varmistus voi riittää.
- Suositeltavaa on varmistaa master-tietokanta ainakin silloin, kun teet:
    - Suuria kokoonpanomuutoksia
    - SQL Serverin päivityksiä
    - Tietokannan luontia ja poistamista

3. Miten varmistaa master-tietokanta?
Master-tietokannan varmistus on suoraviivainen, ja voit käyttää samaa BACKUP DATABASE -komentoa kuin tavallisille tietokannoille. Mutta koska master-tietokanta on niin tärkeä, kannattaa se tehdä erityisellä huolella.

Esimerkki varmistuksesta:
```sql
BACKUP DATABASE master
TO DISK = 'D:\Backups\master_YYYYMMDD.bak'
WITH INIT, FORMAT, NAME = 'Master Database Backup';
```
Tärkeitä huomioita:
- Sijainti: Valitse varmistustiedostolle paikka, joka on suojattu ja käytettävissä palautuksen aikana.
- Nimeä tiedostot huolellisesti: Lisää mielellään päivämäärä (esim. master_20250428.bak) tiedostonimiin, jotta varmistusten erottaminen on helppoa.
- Käytä WITH INIT ja WITH FORMAT: Näin varmistus korvaa vanhan tiedoston eikä kasva rajattomasti.

4. Varmistuksen aikataulutus
Ajasta master-tietokannan varmistus säännöllisesti, mutta ei välttämättä yhtä usein kuin muiden tietokantojen varmistukset. Viikoittainen ajastus voi olla riittävä, jos et tee suuria muutoksia ympäristössä. Jos SQL Server -ympäristössäsi on paljon konfiguraatiomuutoksia, voi olla hyvä varmistaa master-tietokanta useammin.

5. Palauttaminen
- Jos palautat SQL Serverin master-tietokannan, sinun on käytettävä SQL Serverin vikasietotilaa (-m -parametri).
- Varmista, että sinulla on mahdollisuus palauttaa koko ympäristö, jos joudut palauttamaan master-tietokannan.

Esimerkiksi palautus:

```sql
RESTORE DATABASE master
FROM DISK = 'D:\Backups\master_20250428.bak'
WITH REPLACE;
```
6. Varmistusten hallinta ja säilytys
- Koska master-tietokannan varmistus voi olla isokokoinen, kannattaa myös miettiä, kuinka hallinnoit varmistusten säilytysaikaa.
- Varmistuskierto voi auttaa pitämään vain viimeisimmät varmistukset, jolloin vanhentuneet tiedostot poistetaan automaattisesti.

💡 Yhteenvetona:
- Varmista master-tietokanta säännöllisesti, mutta ei välttämättä joka päivä. Viikoittainen tai kuukausittainen varmistus voi riittää.
- Suunnittele varmistukset huolellisesti, jotta saat helposti palautettua SQL Serverin kokoonpanon tarvittaessa.
- Päivitä ja testaa varmistussuunnitelmat aina, kun teet suuria kokoonpanomuutoksia.
- Varmistusmasterin rooli on kriittinen ja sen varmistaminen voi pelastaa monta tilannetta.







