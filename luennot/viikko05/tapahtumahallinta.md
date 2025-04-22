# Tapahtumahallinta

Tietokantatapahtuma eli transaction. Tietokantaa käyttää samanaikaisesti monta käyttäjää (tai sovellusta) ja siksi tietokantapalvelimen pitää huolehtia samanaikaisista päivityksistä ja hakutoiminnoista. Yleensä kyselyt eivät aiheuta ongelmia samaan aikaan suoritettuna, mutta jos on datan muutoksia myös mukana, pitää tietää miten tietokantapalvelin käyttäytyy ja miten samanaikaisuutta voi hallita.
Lukuoperaatioita voi olla samanaikaisesti monta hakemassa samaa dataa (taulun rivejä). Muutosoperaatiot (INSERT, UPDATE ja DELETE) tietokantapalvelin serialisoi eli laittaa komennot jonoon ja suorittaan niitä peräkkäin. Yhdellä ajanhetkellä vain yksi käyttäjä (yhden käyttäjän skripti) voi olla päivittämässä taulun sisältöä. Tämän toteutetaan lukkojen avulla ja päivityksissä käytetään rivilukkoja. Lukoista lisää hieman tuonnempana. Toisaalta tämä päivitys aiheutata seuraavan 'ongelman' eli mitä hakuoperaatio palauttaa jos haku kohdistuu päivitettävään riviin? Palauttaako haku sillä hetkellä olevan datan, jääko hakuoperaatio odottamaan päivityksen päättymistä, mistä se voi tietää milloin päivitys on valmis, jne... siis paljon kysymyksiä.

Samanaikainen käsittely siis vaatii sääntöjä, muutoin kukaan ei tiedä missä tilanteessa data on. Tapahtumahallinta (transactions) tietokantapalvelimessa huolehtii datan pysymisestä eheänä. Kaikki toiminnot tehdään tapahtuman sisällä (transaction). Tapahtuma on atomaarinen kokonaisuus, joka suoritetaan kokonaan (COMMIT) tai ei ollenkaan (ROLLBACK). Mikään välitila ei ole mahdollinen, joka tarkoittaa että tapahtuma joko perutaan ja palataan edelliseen tilaan tai vahvistetaan ja tietokanta siirtyy seuraavaan eheään tilaan (consistent state).

SQL Server:ssä on oletuksena AUTOCOMMIT, joka tarkoittaa sitä, että automaattisesti jokainen komento vahvistetaan tai perutaan sen mukaan, tuleeko komennon suorituksessa virhe. Tästä syystä SQL Serveriä käytettäessä on normaalia aloittaa tapahtuma explisiittisesti BEGIN TRAN[SACTION]; -komennolla. 

Tämän asetuksen voi vaihtaa SSMS:n kautta optioista tai TSQL-komennolla:
```sql
SET IMPLICIT_TRANSACTIONS { ON | OFF }  
```
Kun implisiittiset tapahtumat on käytössä:
- Tapahtuma aloitetaan automaattisesti tietyillä komennoilla (insert, update, delete jne.)
- Sisäkkäisiä tapahtumia ei sallita
- Tapahtuma pitää päättää COMMIT tai ROLLBACK TRANSACTION komentoon
- Ei siis ole oletusarvoisesti päällä
- Yleensä sessiokohtainen asetus (SET IMPLICIT_TRANSACTIONS ON)
- Voidaan asettaa myös instanssiin päälle eli tietokantapalvelintasolle ==> Palvelimen tasolla voidaan User Options –konfigurointiparametrille asettaa IMPLICIT_TRANSACTIONS-optio päälle, jolloin se koskee kaikkia käyttäjäyhteyksiä.
- useimmissa muissa tietokantapalveimissa tämä on oletustila tapahtumilla

Tapahtuma aloitetaan BEGIN TRAN[SACTION]-komennolla ja päätetään COMMIT- tai ROLLBACK-komennolla.

**COMMIT**
- Jos palvelin on kyennyt suorittamaan annetun komennon virheettömästi, se on valmis vahvistamaan (commit) muutetun tilan.
- Oletuksena skriptissä palvelin tekee COMMIT:in itse, jos tapahtuma on aloitettu, pitää COMMIT olla eksplisiittisesti skriptissä mukana.
- ANSI SQL-92: COMMIT;
- TSQL: COMMIT TRAN[SACTION]; tai nykyään toimii myös standardin mukainen COMMMIT;

**ROLLBACK**
- Jos palvelin ei kykene suorittamaan komentoa loppuun, se palaa komennon alkuhetken tilaan (automatic rollback)
- Vahvistamaton transaktio eli tapahtuma voidaan peruuttaa myös manuaalisesti ROLLBACK-komennolla skriptissä
- peruutus päättää transaktion
- palvelin säilyttää peruutukseen tarvittavaa tilainformaatiota tapahtuman loppuun asti tapahtumalogissa 
- ROLLBACK TRAN[SACTION]; tai pelkkä ROLLBACK; riittää

**SAVEPOINT**
Tapahtuman sisällä voi merkitä palautuspisteitä (välitila), johon saakka pystyy peruttamaan. TSQL:ssä se tehdään SAVE-komennolla. 
Peruutus ROLLBACK-komennolla voidaan tällöin tehdä tapahtuman alkuun tai tiettyyn välitilaan. Käytä savepoint:ia harkiten jos silloinkaan.
```sql
BEGIN TRAN;
-- toimintoja 1
SAVE TRANSACTION peruutuspiste;
-- toimintoja 2
ROLLBACK TRANSACTION peruutuspiste; -- kaikki *toimintoja 2* komennot peruutetaan
```

## Eristystasot (Isolation levels)
Tapahtumien eristystaso (= transaktioiden isolaatiotaso) määrittelee, miten samanaikaisten käyttäjät vaikuttavat toistensa näkemään dataan. 
SQL-99 -standardi määrittelee neljä eristystasoa ja viides löytyy vielä SQL Serverin toteutuksena:
- READ UNCOMMITTED
- READ COMMITTED
- REPEATABLE READ
- SERIALIZABLE
- SNAPSHOT (SQL Server)


### eristystason asetus
```sql
SET TRANSACTION ISOLATION LEVEL
    { READ UNCOMMITTED
    | READ COMMITTED
    | REPEATABLE READ
    | SNAPSHOT
    | SERIALIZABLE
    }
```

### READ UNCOMMITED
- Alin eristystaso (isolation level), varmistaa ainoastaan sen, että kysely ei palauta korruptoitunutta dataa. 
- Ohittaa päivityslukot, jolloin käyttäjä voi lukea muiden käyttäjien päivittämää vahvistamatonta dataa (dirty read). 
- Luettu vahvistamaton data saattaa muuttua seuraavalla lukukerralla transaktion päättyessä ROLLBACK-komentoon.


### READ COMMITTED
- Yleensä sessioiden oletusisolaatiotaso, lukuoperaatioiden tuloksena näytetään vain ja ainoastaan vahvistettua (committed) dataa. 
- Jos koetetaan lukea sellaista dataa, jota ei ole vielä vahvistettu COMMIT-komennolla, lukuoperaatio jää odottamaan päivitystapahtuman päättymistä (COMMIT tai ROLLBACK). 
- Aiheuttaa helposti odotuksia ja siksi kannattaa huomioida myös snapshot isolation tai *query hint* WITH NOLOCK.


### REPEATABLE READ
- Harvemmin käytetty isolaatiotaso, kyselyt eivät voi palauttaa vahvistamatonta päivitettyä dataa
- Päivitysoperaatiot eivät voi kohdistua transaktion lukemaan dataan ennen transaktion päättymistä koska peräkkäiset lukuoperaatiot samassa sessiossa palauttavat (pitää palauttaa!) saman tuloksen joka on mahdollista vain jos haettuja rivejä ei voi muuttaa.
- Muut transaktiot voivat lisätä hakuehdot täyttäviä uusia rivejä tauluihin joka voi johtaa haamuriveihin (phantom reads).

### SERIALIZABLE
- Raskain isolaatiotaso, kyselyt eivät voi palauttaa vahvistamatonta päivitettyä dataa.
- Päivitysoperaatiot eivät voi kohdistua transaktion lukemaan dataan ennen transaktion päättymistä.
- Muut transaktiot eivät voi lisätä hakuehdot täyttäviä rivejä ennen kyselyt tehneen transaktion päättymistä. Lukuoperaatiot jättävät luetut rivit lukituiksi transaktion loppuun asti

### SNAPSHOT
- Tarkoittaa datan versiointia eli kysely näkee kommitoidun datan eikä odota päivittävän tapahtuman päättymistä
- Versiointi koskee aina koko kantaa
- Kaikista muutoksista talletetaan vanha versio Tempdb-kantaan (riippumatta siitä onko muita tapahtumia käynnissä vai ei)
- Kaksi kantakohtaista asetusta
- Versiointi voi tapahtua komento- tai tapahtumatasolla
    - Read_committed_snapshot tarkoittaa tarkoittaa oletuslukitustasolla (ei tarvita sovellusmuutoksia) vanhan kommitoidun datan lukua
    - Allow_Snapshot_isolation vaatii Snapshot-lukitustason käyttöä ja kaikki data nähdään tapahtuman alkuhetken mukaisessa ehyessä tilassa

ALTER DATABASE AdventureWorks SET ALLOW_SNAPSHOT_ISOLATION ON;
-- tai
ALTER DATABASE AdventureWorks SET READ_COMMITTED_SNAPSHOT ON;


----
## DEMO: tapahtumat ja lukitukset ja käytössä on oletustaso
simuloitaan tilannetta, missä kaksi tai useampi rinnakkainen skripti käsittelee samaa riviä tietokannassa. Ensimmäinen lukitseen rivin tapahtumassa jolloin toinen skripti joutuu odottamaan kunnes lukot on vapautettu.

### Alkutoimet
```sql
-- Luo testiympäristö
CREATE TABLE dbo.Testitaulu (
    ID INT PRIMARY KEY,
    Nimi NVARCHAR(100)
);

-- Lisää esimerkkidata
INSERT INTO dbo.Testitaulu (ID, Nimi)
VALUES (1, 'Alkuarvo');
```

### Istunto 1, rivin lukitus päivityksellä
```sql
-- Skripti 1
BEGIN TRAN;

UPDATE dbo.Testitaulu
SET Nimi = 'Muokattu arvo 1'
WHERE ID = 1;

-- EI COMMIT-komentoa vielä – lukko pysyy päällä
-- Jätä tämä istunto auki
-- Testaa vaikka: SELECT * FROM dbo.Testitaulu;
```

### Istunto 2, odotus
```sql
-- Skripti 2 (toinen SQL Server -istunto tai query tab)
BEGIN TRAN;

UPDATE dbo.Testitaulu
    SET Nimi = 'Muutettu arvo 42'
    WHERE ID = 1;

COMMIT;
```

### 🔎 aktiiviset lukot
```sql
-- Kolmas istunto: lukot
SELECT 
    request_session_id AS SessionID,
    resource_type,
    resource_description,
    request_mode,
    request_status
FROM sys.dm_tran_locks
WHERE resource_database_id = DB_ID();
```

### 🛑 Lukon vapautus
````ql
-- Istunto 1: vapauta lukko
COMMIT;
```

Lukon odottamiseen voi määritellä keston:
```sql
SET LOCK_TIMEOUT 5000;  -- odottaa max 5 sekuntia, aikayksikkö on millisekunteja
```

## Snapshot (demo)
### Toimintatapa
1. Row Versioning:
- Kun snapshot isolation on käytössä, SQL Server tallentaa vanhat versiot tietueista tempdb-tietokantaan.
- Jokaisella transaktiolla on oma näkymä tietokannasta, joka perustuu siihen, miltä tiedot näyttivät transaktion alkaessa.

2. Ei lukkoja lukemisessa:
- Snapshotissa lukevat transaktiot eivät ota lukkoja riviin → ei odottelua muiden transaktioiden vuoksi.
- Lukevat versioidun näkymän – ei uusimpia, vaan konsistentin näkymän transaktion alusta.

3. Kirjoitukset yhä lukitsevat:
- Jos kaksi transaktiota yrittävät muuttaa samaa riviä, toinen saa virheen (UPDATE conflict), koska snapshot ei käytä lukkoja yhteentörmäysten ehkäisyyn, vaan ne havaitaan vasta commit-vaiheessa.

**Käyttäminen**

1. Otetaan versionointi käyttöön tietokannassa:
```sql
ALTER DATABASE [TietokannanNimi]
SET ALLOW_SNAPSHOT_ISOLATION ON;
```

2. Transaktiotaso valitaan eksplisiittisesti:
```sql
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRANSACTION;
-- Kyselyt ja päivitykset tähän
COMMIT;
```
Snapshot ei ole oletustaso, vaan se pitää valita erikseen transaktiossa. Tai voi ottaa käyttöön Read Committed Snapshot Isolation-toimintomallin. 

### Snapshot vs. Read Committed Snapshot Isolation (RCSI)
Snapshot pitää määrittää jokaisessa tapahtumassa erikseen, RCSI taas on automaattisesti käytössä READ COMMITTED-tasolla jos RCSI on aktivoitu. RCSI on sopiva kun tehdään paljon pieniä kyselyitä.

```sql
ALTER DATABASE [TietokannanNimi] SET READ_COMMITTED_SNAPSHOT ON;
```

## SQL Serverin eristystasot: Snapshot vs. RCSI

| Ominaisuus / Taso                     | Read Committed (oletus) | Snapshot Isolation           | Read Committed Snapshot (RCSI) |
|--------------------------------------|--------------------------|------------------------------|----------------------------------|
| **Näkeekö versioidun datan?**        | ❌ Ei                   | ✅ Kyllä                     | ✅ Kyllä                         |
| **Tarvitsee erillisen asetuksen?**   | ❌ Ei                   | ✅ `SET TRANSACTION ISOLATION LEVEL SNAPSHOT` | ❌ Ei (automaattinen)           |
| **Tarvitsee tietokanta-asetuksen?**  | ❌ Ei                   | ✅ `ALLOW_SNAPSHOT_ISOLATION ON` | ✅ `READ_COMMITTED_SNAPSHOT ON` |
| **Lukee ilman lukkoja?**             | ❌ Ei                   | ✅ Kyllä                     | ✅ Kyllä                         |
| **Kirjoitukset lukitsevat rivit?**   | ✅ Kyllä                | ✅ Kyllä                     | ✅ Kyllä                         |
| **Kirjoituskonfliktit mahdollisia?** | ❌ Ei                   | ✅ Kyllä (commit-vaiheessa) | ✅ Kyllä (commit-vaiheessa)     |
| **Vaikuttaa tempdb-kuormaan?**       | ❌ Ei                   | ✅ Kyllä (row versioning)    | ✅ Kyllä (row versioning)        |
| **Hyöty lukuvaltaisuudessa?**        | ❌ Ei                   | ✅ Suuri                     | ✅ Suuri                         |


## Snapshot konfliktiesimerkki

1. alustetaan taulu ja luodaan hieman aineistoa.

```sql
-- taitaa olla jo tuttu taulu aikaisemmista esimerkeistä...
CREATE TABLE Tuotteet (
    TuoteID INT PRIMARY KEY,
    Nimi NVARCHAR(100),
    Hinta DECIMAL(10,2)
);

INSERT INTO Tuotteet (TuoteID, Nimi, Hinta)
VALUES (1, 'Kahvipaketti', 5.99);
```

2. Otetaan snapshot-eristystaso käyttöön:
```sql
ALTER DATABASE [TestiTietokanta] SET ALLOW_SNAPSHOT_ISOLATION ON;
```
**Huom:** Tämä ei vielä muuta oletuseristystasoa. Snapshot pitää erikseen ottaa käyttöön transaktiossa.

3. Simuloidaan kahta rinnakkaista transaktiota
Avaa kaksi eri sessiota / välilehteä SSMS:ssä (tai muussa työkalussa).

🔁 Sessio A:
```sql
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRANSACTION;

-- Luetaan nykyinen hinta
SELECT * FROM Tuotteet WHERE TuoteID = 1;

-- Muokataan hintaa
UPDATE Tuotteet SET Hinta = 6.49 WHERE TuoteID = 1;

-- Odotetaan ennen committia
-- (älä suorita COMMIT-komentoa vielä)
```

🔁 Sessio B (samaan aikaan):
```sql
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRANSACTION;

-- Luetaan nykyinen hinta (näkee alkuperäisen 5.99, koska snapshot)
SELECT * FROM Tuotteet WHERE TuoteID = 1;

-- Yritetään muuttaa hinta 7.49:ään
UPDATE Tuotteet SET Hinta = 7.49 WHERE TuoteID = 1;

-- Tämä onnistuu *vain jos Sessio A ei ole vielä muuttanut sitä*
-- Commit:
COMMIT;
```

❌ Jos Sessio A ehtii commitoida ennen Sessio B:tä...
Sessio B saa virheen:

```sql
Msg 3960, Level 16, State 1, Line 8
Snapshot isolation transaction aborted due to update conflict. You cannot use snapshot isolation to access table 'Tuotteet' directly or indirectly in database 'TestiTietokanta' to update, delete, or insert the row that has been modified or deleted by another transaction since the start of this transaction.
```

Versiointi tapahtuu automaattisesti, mutta voit tarkkailla tilannetta näin:

```sql
SELECT * FROM sys.dm_tran_version_store_space_usage;

 --Tai esimerkiksi aktiiviset snapshot-transaktiot:
SELECT * FROM sys.dm_tran_active_snapshot_database_transactions;
```

### Sitten vielä RCSI-esimerkki:
RCSI: Snapshot ilman että sitä tarvitsee erikseen pyytää

🔧 1. Otetaan RCSI käyttöön tietokannassa:
```sql
ALTER DATABASE [TestiTietokanta] SET READ_COMMITTED_SNAPSHOT ON;
```
Tämä vaatii, että ei ole aktiivisia yhteyksiä tietokantaan. Jos tulee virhe, sulje yhteydet ja yritä uudelleen.

Nyt kaikki transaktiot, jotka käyttävät READ COMMITTED -tasoa (oletus), lukevat snapshotin, eivät lukitsevia rivejä.

🧪 RCSI-esimerkki
1. Sessio A (hidas päivitys):

```sql
BEGIN TRANSACTION;

-- Päivitetään rivi, mutta EI vielä commitoida
UPDATE Tuotteet SET Hinta = 8.99 WHERE TuoteID = 1;

-- Odotetaan manuaalisesti (esim. älä paina vielä COMMIT)
```
2. Sessio B (normaali SELECT):
```sql
-- Ei tarvitse määritellä eristystasoa: käytetään oletusta (READ COMMITTED)

SELECT * FROM Tuotteet WHERE TuoteID = 1;
```

🔍 Mitä tapahtuu?

- Ilman RCSI:tä sessio B odottaa, että sessio A vapauttaa lukon.
- RCSI:n kanssa: sessio B lukee alkuperäisen version rivistä (ennen päivitystä), ilman lukkoja ja odotusta!


🧠 Käytännön hyödyt RCSI:stä
- ✅ Parantaa suorituskykyä, kun paljon lukijoita (raportointi, dashboardit).
- ✅ Ei enää turhia luku-lukkoja tai lukupatoutumia.
- ⚠️ Kirjoituskonfliktit ovat edelleen mahdollisia (kuten snapshotissa yleensäkin).


|Eristystaso	| Lukee version?	| Tarvitsee määritellä?	 | Estääkö lukot?|
|---------------|-------------------|------------------------|---------------|
|Read Committed (oletus) |	❌ Ei |	❌ Ei |	✅ Kyllä |
|Snapshot Isolation |	✅ Kyllä |	✅ Kyllä |	❌ Ei |
|Read Committed Snapshot (RCSI) |	✅ Kyllä |	❌ Ei (automaattinen) |	❌ Ei |


## SQL Serverin eristystasot: Snapshot vs. RCSI

| Ominaisuus / Taso                    | Read Committed (oletus) | Snapshot Isolation           | Read Committed Snapshot (RCSI) |
|--------------------------------------|-------------------------|------------------------------|--------------------------------|
| **Näkeekö versioidun datan?**        | ❌ Ei                   | ✅ Kyllä                     | ✅ Kyllä                         |
| **Tarvitsee erillisen asetuksen?**   | ❌ Ei                   | ✅ `SET TRANSACTION ISOLATION LEVEL SNAPSHOT` | ❌ Ei (automaattinen)           |
| **Tarvitsee tietokanta-asetuksen?**  | ❌ Ei                   | ✅ `ALLOW_SNAPSHOT_ISOLATION ON` | ✅ `READ_COMMITTED_SNAPSHOT ON` |
| **Lukee ilman lukkoja?**             | ❌ Ei                   | ✅ Kyllä                     | ✅ Kyllä                         |
| **Kirjoitukset lukitsevat rivit?**   | ✅ Kyllä                | ✅ Kyllä                     | ✅ Kyllä                         |
| **Kirjoituskonfliktit mahdollisia?** | ❌ Ei                   | ✅ Kyllä (commit-vaiheessa) | ✅ Kyllä (commit-vaiheessa)     |
| **Vaikuttaa tempdb-kuormaan?**       | ❌ Ei                   | ✅ Kyllä (row versioning)    | ✅ Kyllä (row versioning)        |
| **Hyöty lukuvaltaisuudessa?**        | ❌ Ei                   | ✅ Suuri                     | ✅ Suuri                         |
📌 Vinkki: Jos dokumentoit järjestelmäsi toimintaa tai kehitysohjeita, kannattaa liittää kaavion alle vielä huomautus esim.:


**Huom:** RCSI toimii vain, jos tietokannassa on `READ_COMMITTED_SNAPSHOT` käytössä. Snapshot-isolation puolestaan vaatii eksplisiittisen käyttöönoton joka transaktiossa.

### NOLOCK vs SNAPSHOT
NOLOCK ja SNAPSHOT ISOLATION saattavat vaikuttaa samanlaisilta, koska molemmat antavat  lukea tietoa ilman odottelua, mutta niillä on isoja eroja erityisesti datan oikeellisuuden ja turvallisuuden kannalta.

**NOLOCK vs. SNAPSHOT – keskeiset erot**

| Ominaisuus                            | `NOLOCK`                                      | `SNAPSHOT ISOLATION`                       |
|---------------------------------------|-----------------------------------------------|--------------------------------------------|
| **Lukee ilman lukkoja?**              | ✅ Kyllä                                      | ✅ Kyllä                                   |
| **Versioitu data (row versioning)?**  | ❌ Ei                                         | ✅ Kyllä                                   |
| **Näkeekö commitoimattomia muutoksia?**| ✅ Kyllä (dirty reads)                        | ❌ Ei                                      |
| **Data konsistenttia koko transaktiossa?** | ❌ Ei (voi muuttua kesken transaktion)   | ✅ Kyllä (snapshot transaktion alusta)    |
| **Rivien duplikaatit tai torn reads?**| ✅ Mahdollisia                                | ❌ Ei                                      |
| **Vaatii tietokanta-asetuksia?**      | ❌ Ei                                         | ✅ `ALLOW_SNAPSHOT_ISOLATION ON`          |
| **Vaikuttaa tempdb-kuormaan?**        | ❌ Ei                                         | ✅ Kyllä (version store)                  |
| **Soveltuu tuotantoon / raportointiin?**| 🚫 Ei suositeltu (vain erityistapauksissa) | ✅ Kyllä                                   |
| **Turvallisuus ja luotettavuus?**     | ❌ Heikko                                     | ✅ Hyvä                                    |


**Esimerkki:** miten ne käyttäytyvät eri tilanteissa
Tilanne:
- Transaktio A muuttaa asiakastietoa mutta ei ole vielä commitoitu.
- Transaktio B lukee samaa asiakastietoa.

🔴 NOLOCK:
Transaktio B saattaa nähdä muutoksia, joita ei ole vielä hyväksytty (dirty reads). Pahimmillaan dataa, jota ei koskaan oikeasti tallennettu.
```sql
SELECT * FROM Asiakkaat WITH (NOLOCK)
```
Tulos voi sisältää:
- Epäyhtenäisiä tietoja (osa uusista, osa vanhoista riveistä)
- Poistettuja rivejä
- Rivien duplikaatteja
- Torn reads: sama rivi osittain vanhaa, osittain uutta

✅ SNAPSHOT ISOLATION:
Transaktio B näkee konsistentin näkymän tiedoista, sellaisina kuin ne olivat ennen Transaktio A:n alkamista.
```sql
SET TRANSACTION ISOLATION LEVEL SNAPSHOT;
BEGIN TRANSACTION;
SELECT * FROM Asiakkaat;
COMMIT;
→ Ei odota lukkoja, mutta ei näe Transaktio A:n tekemättömiä muutoksia.
```

NOLOCK on sopiva kun tarvitaan mahdollisimman nopea luku ja ei ole katastrofi jos data on osin virheellistä. SNAPSHOT tai RCSI silloin datan pitää olla luotettavaa ja luku ei saa lukita mitään.

Tilanne	Suositus
Tarvitset suorituskykyä ja ei haittaa, jos data on väliaikaisesti virheellistä	NOLOCK (vain harkiten, esim. logeihin)
Tarvitset luotettavaa mutta ei lukitsevaa lukua (esim. raportit)	SNAPSHOT ISOLATION tai RCSI
Tarvitset 100 % oikeellista dataa ja vältät likaisia lukuja	✅ Käytä snapshotia, älä NOLOCKia


---
# Lukot

Palvelin kontrolloi samanaikaisten transaktioiden dataan kohdistamia operaatioita lukkojen (locks) avulla
Lukot ovat bittilippuja, joita voi olla erityppisiä 
- päivityslukko (X-lukko, exclusive)
- lukulukko (S-lukko, shared)

ja eritasoisia
- rivitason lukko (row lock)
- datasivutason lukko (page lock)
- taululukko (table lock)


Lukkoja ja lukitustilanteita voi tutkia näkymien avulla:
- Sys.dm_exec_sessions
- Sys.dm_exec_requests
- Sys.dm_tran_locks

Tai komennoilla: 
- sp_lock [prosessin id], [prosessin id] - Tulostaa kaikki / yhden prosessin käyttämät lukot, ks. esimerkki alla
- sp_who, sp_who2 - Näyttää infon prosesseista sekä myös blokkaustiedon


```sql
begin tran
select * from asiakas(holdlock)
exec sp_lock 16  -- prosessi id
```

## Tapahtumien koodaus ja käyttö
- Mahdollisimman lyhyet tapahtumat ajallisesti
- Ei käyttäjän väliin tuloa (viittaa sovelluslogiikan toteuttamiseen)
- Pitkien tapahtumien välttäminen
    - Tapahtuman pilkkominen osiin
    - Tapahtuman hoitaminen tila-muuttujan (sarakkeen) avulla

Sisäkkäiset tapahtumat
- Ei suositella käyttöön
- @@trancount-funktio kertoo tason
- vasta uloin Commit-komento päättää tapahtuman
- Rollback peruuttaa aina ennen viimeistä commitia annettuna

Pari käsitettä lisää:

**Blocking**
- Prosessi joutuu odottamaan toisen prosessin varaamia resursseja

**Deadlock**
- Prosessit varaavat toistensa varaamat resurssit ristiin, eikä eteenpäin pääsyä ole
- SQL Server purkaa automaattisesti




