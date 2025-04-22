# Rakenteiden muutokset

Tietokannan rakennetta (eli skeemaa) joudutaan usein muuttamaan tietokannan elinkaaren aikana. Nämä muutokset voivat olla yksinkertaisia tai hyvinkin monimutkaisia, ja joskus SQL Server Management Studion (SSMS) graafinen suunnittelutyökalu ei riitä, vaan tarvitaan tarkkaan suunniteltuja ja testattuja skriptejä.

### Yleisiä tilanteita, joissa rakennetta muutetaan:
- Uusien liiketoimintavaatimusten täyttäminen, esimerkiksi sovellukseen lisätään uusia ominaisuuksia, jolloin tarvitaan uusia tauluja, sarakkeita, relaatiota jne.
- Tietomallin optimointi
- Normalisointi tai denormalisointi tietokannan suorituskyvyn tai ylläpidettävyyden parantamiseksi tai käytön helpottamiseksi.
- Suorituskykyongelmien korjaaminen
- Indeksien lisääminen tai muuttaminen.
- Partitiointi.
- Tietotyyppien muuttaminen tehokkaammiksi.
- Virheiden korjaaminen tietomallissa, esimerkiksi väärä tietotyyppi, puuttuva rajoite (foreign key, unique jne.).
- Integraatio muiden järjestelmien kanssa, esim. sovelluksen täytyy lähettää tai vastaanottaa dataa ulkoisista lähteistä, mikä vaatii lisäkenttiä tai konversiota.

Indeksit ja niiden muokkaaminen jätetään toistaiseksi käsittelemättä, palataan niihin hieman tuonnempana.

SSMS osaa tehdä (jos se on optioista sallittu) aika paljon erilaisia muutoksia graafisen käyttöliittymän kautta, mutta kaikki ei onnistu.
Hankalia tai monimutkaisia tilanteita, joissa graafinen työkalu ei riitä:
- Sarakkeen tyypin muuttaminen, kun taulussa on dataa, esim. VARCHAR(10) → INT: vaatii datan muuntamista ja validointia ennen muutosta, jos koko data on sisältää vain kokonaislukuja merkkijonona, onnistuu muutos ilman ongelmia.
- Sarakkeen nimen muuttaminen, kun se on käytössä riippuvuuksissa. Esim. näkymät, proseduurit, funktiot, triggerit, kaikki nämä voivat viitata kyseiseen sarakkeeseen. SSMS ei osaa automaattisesti päivittää niitä kaikkia.
- Taulujen uudelleenrakentaminen, esimerkiksi jos halutaan muuttaa PRIMARY KEY -rakennetta tai yhdistää useampi taulu yhteen: vaatii usein datan migraatiota ja useiden objektien (indeksit, constraintit, triggerit) uudelleenluontia.
- Tietojen konvertointi skeemamuutoksen yhteydessä
- Jos sarakkeen tyyppi muuttuu tai sarakkeita yhdistetään/jaetaan, pitää kirjoittaa skripti, joka päivittää olemassa olevat tiedot.
- Rakennemuutokset tuotantoympäristössä
- Tarvitaan tarkkaan suunniteltuja skriptejä, jotka:
    - Eivät riko objekteja, jotka viittaavat muutettaviin tauluihin ja sarakkeisiin
    - Säilyttävät datan
    - Ovat suoritettavissa "hot" tilassa (ilman käyttökatkoa)
    - Indeksien tai constraintien hallinta, esim. UNIQUE constraintin lisääminen tauluun, jossa on duplikaatteja → pitää ensin löytää ja käsitellä duplikaatit.
- Partitioinnin lisääminen olemassa olevaan tauluun
- Refaktorointi, jossa pitää säilyttää taaksepäin yhteensopivuus, esim. uuden sarakkeen käyttöönotto siten, että vanhat proseduurit ja näkymät edelleen toimivat.

## Huomioitava seikka
Tietokannan muutoksissa selvitä onnistuuko muutos 'lennossa' eli samaan aikaan kun tietokanta on normaalissa käytössä. Tai riittääkö että on joku rauhallinen hetki, esimerkiksi illalla klo 20 jolloin käyttäjiä on vähän. 
Tarvittaessa tietokannan voi asettaa single-user -moodiin. Tällöin tietokannassa voi tehdä rauhassa huoltotoimenpiteitä, mutta se ei ole silloin normaalissa käytössä. Asetus tapahtuu SSMS:n avulla tietokanta-aseuksista (Options), viimeinen valinta (State) Restrict Access ja asetuksena SINGLE_USER. Tämän asetuksen jälkeen katkeaa kaikki muut yhteydet (istunnot) välittömästi ilman mitään varoitusta.
TSQL-komennoilla voi tehdä tietysti saman:

```sql
USE master;
GO
ALTER DATABASE AdventureWorks2022
    SET SINGLE_USER
    WITH ROLLBACK IMMEDIATE;
GO
-- takaisin normaaliin tilaan:
ALTER DATABASE AdventureWorks2022
    SET MULTI_USER;
GO```

On myös mahdollista käynnistää tietokantapalvelin rajoitetussa tilassa, esimerkiksi seuraava komento sallii vain SSMS:n Query-ikkunan kautta kytkeytymisen ja siirtyy samalla single-user moodiin (on ensin stop-komennolla pysäytettävä):
```cmd
net start "SQL Server (MSSQLSERVER)" /m"Microsoft SQL Server Management Studio - Query"
```

### 🛠️ Milloin skripti on parempi kuin graafinen työkalu
- Kun muutoksessa tarvitaan loogisia tarkistuksia (esim. "jos data on tätä muotoa, tee näin").
- Kun halutaan versiohallittavia muutoksia (esim. osana CI/CD-putkea).
- Kun muutoksen vaikutukset ulottuvat moniin objekteihin.
- Kun tietomäärä on suuri ja pitää hallita muutoksen suoritusnopeutta tai lukituksia.
- Kun muutoksia täytyy tehdä automaattisesti useaan ympäristöön (esim. dev, test, prod).
- Esimerkkinä on vaikkapa yksi yleinen ja hankala tilanne – eli sarakkeen tietotyypin muuttaminen, kun taulussa on jo dataa ja sarake voi olla käytössä indekseissä tai viittauksissa.

🎯 **Tilanne:**
Taulussa Asiakkaat on sarake PuhelinNumero tyyppiä VARCHAR(10), mutta se halutaan muuttaa tyyppiin VARCHAR(20), koska ulkomaiset numerot eivät mahdu nykyiseen kenttään.

Lisähaasteet:
- Taulussa on jo tuhansia rivejä dataa.
- Sarake on osa UNIQUE-indeksiä.
- Halutaan tehdä muutos turvallisesti tuotantotietokannassa ilman käyttökatkoa.

✅ Tavoite:
Muuttaa PuhelinNumero-sarakkeen tietotyyppi menettämättä dataa, rikkomatta riippuvuuksia, ja pitää indeksi ennallaan.

🧠 Vaiheittainen skripti:
```sql
-- 1. Tarkistetaan nykyinen rakenne ja riippuvuudet
EXEC sp_help 'dbo.Asiakkaat';

-- 2. Luodaan väliaikainen sarake uudella tietotyypillä
ALTER TABLE dbo.Asiakkaat
    ADD PuhelinNumero_tmp VARCHAR(20);

-- 3. Kopioidaan data vanhasta sarakkeesta uuteen
UPDATE dbo.Asiakkaat
    SET PuhelinNumero_tmp = PuhelinNumero;

-- 4. Poistetaan riippuvaisuudet (indeksit, constraintit)
-- Huom: tämä riippuu rakenteesta – tässä esimerkkinä UNIQUE-indeksin poisto
DROP INDEX IX_Asiakkaat_PuhelinNumero ON dbo.Asiakkaat;

-- 5. Poistetaan vanha sarake
ALTER TABLE dbo.Asiakkaat
DROP COLUMN PuhelinNumero;

-- 6. Uudelleennimetään uusi sarake vanhaksi
EXEC sp_rename 'dbo.Asiakkaat.PuhelinNumero_tmp', 'PuhelinNumero', 'COLUMN';

-- 7. Luodaan indeksi uudelleen
CREATE UNIQUE NONCLUSTERED INDEX IX_Asiakkaat_PuhelinNumero
ON dbo.Asiakkaat(PuhelinNumero);

-- 8. (Valinnainen) Päivitä proseduurit/näkymät jos ne viittasivat vanhaan sarakkeen rakenteeseen
```

🛡️ **Huomioitavaa:**
- Jos sarake on foreign key-suhteessa toiseen tauluun, se pitää ensin poistaa ja lisätä uudelleen.
- Jos sarake on pääavain tai osa computed columnia, tarvitaan enemmän vaiheita.
- Tuotantoympäristössä kannattaa aina tehdä backup ja testata skripti staging- tai test-ympäristössä ensin.

Esimerkki vielä vaikeammasta tilanteesta, kuten sarakkeen jakamisesta kahdeksi (esim. Nimi → Etunimi, Sukunimi):

🎯 **Tilanne:**
Taulussa Henkilot on sarake Nimi (esim. "Matti Meikäläinen") tyyppiä VARCHAR(100). Haluamme jakaa tämän kahdeksi sarakkeeksi:
- Etunimi
- Sukunimi
Lisähaasteet:
- Taulussa on jo paljon dataa.
- Sarake Nimi on käytössä useissa näkymissä ja raporteissa.
- Kaikissa nimissä ei ole täsmälleen kaksi osaa (esim. "Anna-Maria Virtanen", "Jari").

✅ Tavoite:
Jakaa Nimi-sarake turvallisesti kahtia, säilyttää alkuperäinen data ja minimoida häiriö vaikutuksille.

🧠 Vaiheittainen ratkaisu:
```sql
-- 1. Lisätään uudet sarakkeet
ALTER TABLE Henkilot
ADD Etunimi VARCHAR(20), 
    Sukunimi VARCHAR(30);

-- 2. Päivitetään uudet sarakkeet datalla
-- Tässä oletetaan, että etunimi on ensimmäinen sana, sukunimi loput
UPDATE Henkilot
SET Etunimi = LTRIM(RTRIM(LEFT(Nimi, CHARINDEX(' ', Nimi + ' ') - 1))),
    Sukunimi = LTRIM(RTRIM(SUBSTRING(Nimi, CHARINDEX(' ', Nimi + ' ') + 1, LEN(Nimi))));

-- 3. Tarkistetaan jako (esim. NULL-arvot, virheet)
SELECT Nimi, Etunimi, Sukunimi
FROM Henkilot
WHERE Sukunimi IS NULL OR Etunimi IS NULL;

-- 4. Päätetään, mitä tehdään alkuperäiselle sarakkeelle
-- a) jos halutaan pitää historiaa: jätetään sarake
-- b) jos halutaan poistaa:
-- ALTER TABLE dbo.Henkilot DROP COLUMN Nimi;

-- 5. Päivitetään näkymät, proseduurit, raportit jne.
-- Etsi kaikki kohdat, joissa käytetään "Nimi"-saraketta:
-- (Tämä löytää riippuvuuksia)
SELECT OBJECT_NAME(object_id), definition 
FROM sys.sql_modules 
WHERE definition LIKE '%Nimi%';

-- 6. (Valinnainen) Luodaan computed column alkuperäisellä rakenteella
-- Jos vanha sarake halutaan emuloida:
ALTER TABLE dbo.Henkilot
    ADD Nimi AS (Etunimi + ' ' + Sukunimi);
```

**Huomioitavaa:**
- Tämä jako toimii vain yksinkertaisissa nimissä. Jos haluat käsitellä moniosaisia nimiä (esim. "Jean von Hellens", "Teppo Matti Tuppurainen"), kannattaa käyttää kehittyneempää parsintaa tai jopa erillistä ETL-prosessia. ETL (Extract, Transform, Load) prosessissa siirretään ensin data johonkin toiseen järjestelmään tai tietokantaan, tehdään tarvittavat muunnokset/korjaukset ja sitten ladataan päivitetty data takaisin alkuperäiseen tietokantaan. Tämän voi tehdä monella erilaisella tavalla, ja hyvin luultavasti vaatii ohjelmointia.
- Jos Nimi on käytössä indeksoituna sarakkeena, muutos voi vaikuttaa suorituskykyyn.
- Jos järjestelmässä on audit-trail tai integraatioita muihin järjestelmiin, niiden yhteensopivuus pitää varmistaa.


**Esimerkki taulun jakamisesta kahteen:**
🎯 Tilanne: taulussa *Henkilot* on henkilöiden perustiedot sekä yhteystiedot yhdessä taulussa:

```sql
CREATE TABLE Henkilot (
    HenkiloID INT PRIMARY KEY,
    Nimi VARCHAR(100),
    Email VARCHAR(50),
    Puhelin VARCHAR(20),
    Osoite VARCHAR(200)
);
```

Halutaan erottaa yhteystiedot omaksi taulukseen, esim. seuraavista syistä:
- Yhteystietoja käytetään eri järjestelmässä.
- Yhteystiedot voivat muuttua useammin kuin perustiedot.
- Halutaan normalisoida tietokantarakenne.

✅ Tavoite
Jaetaan taulu kahdeksi:
- Henkilot: sisältää HenkiloID ja Nimi
- Yhteystiedot: sisältää HenkiloID, Email, Puhelin, Osoite
- Ja pidetään HenkiloID-viiteavaimena näiden välillä.

🧠 Ratkaisu vaiheittain
```sql
-- 1. Luodaan uusi taulu Yhteystiedot
CREATE TABLE Yhteystiedot (
    HenkiloID INT PRIMARY KEY,
    Email VARCHAR(100),
    Puhelin VARCHAR(20),
    Osoite VARCHAR(200),
    CONSTRAINT FK_Yhteystiedot_Henkilot FOREIGN KEY (HenkiloID)
        REFERENCES Henkilot(HenkiloID)
);

-- 2. Siirretään tiedot uuteen tauluun
INSERT INTO Yhteystiedot (HenkiloID, Email, Puhelin, Osoite)
SELECT HenkiloID, Email, Puhelin, Osoite
FROM Henkilot;

-- 3. Poistetaan yhteystiedot alkuperäisestä taulusta
ALTER TABLE Henkilot
DROP COLUMN Email;

ALTER TABLE Henkilot
DROP COLUMN Puhelin;

ALTER TABLE Henkilot
DROP COLUMN Osoite;
```

🔗 Lopputulos:
Nyt Henkilot ja Yhteystiedot ovat kahdessa eri taulussa, mutta yhdistettävissä yhdellä liittymällä (JOIN) HenkiloID:n kautta.

Esim. kysely kaikkien tietojen saamiseksi:
```sql
SELECT h.HenkiloID, h.Nimi, y.Email, y.Puhelin, y.Osoite
FROM Henkilot h
JOIN Yhteystiedot y ON h.HenkiloID = y.HenkiloID;
```

🔒 Hyviä käytäntöjä:
- Lisää FOREIGN KEY-viite estämään orpoja rivejä (kuten yllä on tehty).
- Voit käyttää ON DELETE CASCADE, jos haluat, että Yhteystiedot poistuvat automaattisesti henkilön poiston yhteydessä.
- Jos käytetään sovelluksia, muista päivittää kaikki paikat, joissa vanha rakenne oli käytössä.

## Synonyymit

[Synonyymit](https://learn.microsoft.com/en-us/sql/relational-databases/synonyms/synonyms-database-engine?view=sql-server-ver16) ovat huonommin tunnettu piirre. Synonyymeistä voi kuitenkin olla paljon apua tietokannan muutostenhallinnassa. Synonyymi on alias jollekin SQL-objektille (esim. taulu, näkymä, proseduuri), jonka avulla voit viitata siihen toisella nimellä.

```sql
CREATE SYNONYM AliasNimi FOR [Tietokanta].[Skeema].[Objekti];
```

✳️ Esimerkki: Taulun siirto toiseen skeemaan tai tietokantaan
🧱 Lähtötilanne:
Sinulla on sovellus, joka käyttää taulua:
```sql
SELECT * FROM dbo.Asiakkaat
```

🛠️ Haluat siirtää taulun toiseen skeemaan:
esim. asiakasdata.Asiakkaat, mutta et voi heti päivittää kaikkia sovelluksen SQL-kutsuja.
✅ Ratkaisu: Käytä synonyymiä

```sql
--1. Siirrä taulu uuteen skeemaan:
ALTER SCHEMA asiakasdata TRANSFER dbo.Asiakkaat;

--2. Luo synonyymi vanhan nimen tilalle:
CREATE SYNONYM dbo.Asiakkaat FOR asiakasdata.Asiakkaat;
```

🧩 Nyt vanhat kyselyt, jotka käyttävät dbo.Asiakkaat, toimivat edelleen, vaikka taulu on siirretty uuteen skeemaan


🔁 Muita käytännön käyttötapoja
1. Väliaikainen ohjaus toiseen tauluun
    - Voit kehityksen tai testauksen ajaksi ohjata kyselyt toiseen tauluun ilman, että muutat sovelluksen koodia.
2. Tietokantojen väliset viittaukset
    - Jos käytät dataa toisesta tietokannasta:

```sql
CREATE SYNONYM Asiakkaat FOR UlkoinenDB.dbo.Asiakkaat;
```

3. Nimien vakiointi
Sovellus voi käyttää synonyymejä yhtenäisillä nimillä, vaikka fyysiset nimet vaihtelevat ympäristöittäin (esim. DEV, TEST, PROD).

🧨 Varoituksia:
- Synonyymit eivät näy helposti graafisissa työkaluissa (SSMS:n Object Explorerissa voi mennä ohi).
- Jos kohdeobjekti muuttuu tai katoaa, synonyymi ei anna virheilmoitusta ennen kuin sitä käytetään.
- Et voi luoda synonyymejä temp-tauluihin (#- tai ##-alkuisiin tauluihin).

🧪 Demo: Taulun siirto toiseen tietokantaan synonyymillä
🔹 Lähtötilanne
Taulu Asiakkaat on tietokannassa VanhaDB ja haluat siirtää sen UusiDB-tietokantaan.

Sovelluskoodi käyttää edelleen:
```sql
SELECT * FROM dbo.Asiakkaat;
```

✅ Vaiheittainen demo
1. Siirrä taulu uuteen tietokantaan
```sql

-- Luo uusi tietokanta (jos ei ole)
CREATE DATABASE UusiDB;
GO

-- Oletetaan, että VanhaDB:ssa on taulu dbo.Asiakkaat
-- Siirretään tiedot uuteen tietokantaan (manuaalisesti tai skriptillä)

-- Luo taulu UusiDB:hen
USE UusiDB;
GO
CREATE TABLE dbo.Asiakkaat (
    AsiakasID INT PRIMARY KEY,
    Nimi VARCHAR(100)
);

-- Lisää testidata
INSERT INTO dbo.Asiakkaat (AsiakasID, Nimi)
VALUES (1, 'Maija Mallikas'), (2, 'Kalle Käyttäjä');
```
2. Vanha tietokanta: luo synonyymi
```sql
-- Palaa VanhaDB:hen
USE VanhaDB;
GO

-- Poista mahdollinen vanha taulu (jos oli)
DROP TABLE IF EXISTS dbo.Asiakkaat;

-- Luo synonyymi
CREATE SYNONYM dbo.Asiakkaat FOR UusiDB.dbo.Asiakkaat;
3. Testaa kysely
-- Tämä toimii edelleen kuten ennen, mutta data tulee toisesta tietokannasta
SELECT * FROM dbo.Asiakkaat;
```
🔍 Sovelluksen tai raportin ei tarvitse tietää, että taulu on siirretty toiseen tietokantaan!

Synonyymi on kätevä keino, kun halutaan pitää yhteensopivuus rakenteita muutettaessa. Se toimii ikään kuin välityspisteenä, jolla voidaan välttää koodin rikkominen kesken muutoksen.
Synonyymit ovat loistava tapa:
- Abstrahoida fyysinen rakenne (taulut voivat sijaita missä tahansa).
- Mahdollistaa taulurakenteiden muutokset ilman heti rikkomatta sovelluksia.
- Helpottaa siirtymiä, integraatioita ja ympäristönvaihtoja.


## Partitiointi

[Partitionti](https://learn.microsoft.com/en-us/sql/relational-databases/partitions/partitioned-tables-and-indexes?view=sql-server-ver16) tarkoittaa sitä, että suuri taulu jaetaan loogisesti pienempiin osiin eli partitioihin, vaikka se näyttää edelleen yhdeltä taululta käyttäjälle.

✅ Miksi partitioida taulu?
- Parantaa suorituskykyä, kyselyt voivat kohdistua vain yhteen tai muutamaan partioon, jolloin luetaan vähemmän dataa.
- Helpottaa ylläpitoa, vanhimpien tietojen poistaminen tai arkistointi onnistuu helposti partitioiden vaihdolla (partition switch).
- Mahdollistaa tehokkaammat indeksit, indeksit voivat olla partitiokohtaisia.
- Parempi hallinta isoille tietomäärille, esim. miljoonia rivejä sisältävä taulu on paljon helpompi hallita, kun se on loogisesti jaettu.

🔧 Miten se toimii teknisesti?
🔹 1. Partition Function
Määrittää, miten arvojen perusteella data jaetaan partitioihin. Esim.:

```sql
CREATE PARTITION FUNCTION pf_Vuosi(int)
    AS RANGE LEFT FOR VALUES (2022, 2023);
```

Tämä luo 3 partiota:
- Partitio 1: kaikki ≤ 2022
- Partitio 2: kaikki = 2023
- Partitio 3: kaikki > 2023

🔹 2. Partition Scheme
Määrittää, mihin fyysisiin tiedostoryhmiin partitiot sijoitetaan (tai kaikki samaan, jos ei tarvita erillistä levyjakoa).
```sql
CREATE PARTITION SCHEME ps_Vuosi
    AS PARTITION pf_Vuosi
    ALL TO ([PRIMARY]);
```

🔹 3. Taulun luominen käyttäen partition schemaa
```sql
CREATE TABLE MyData (
    Vuosi INT,
    Arvo VARCHAR(100)
)
ON ps_Vuosi(Vuosi);  -- Taulu jaetaan Vuosi-sarakkeen mukaan
```

📉 Esimerkki käytöstä:
Jos sinulla on lokitaulu Tapahtumat, jossa on miljoonia rivejä, voit jakaa sen partitoimalla sarakkeen *TapahtumaPvm* mukaan kuukausittain.
Tällöin kysely:
```sql
SELECT * 
FROM Tapahtumat
WHERE TapahtumaPvm >= '2025-04-01' AND TapahtumaPvm < '2025-05-01'
```
lukee vain yhden partition, ei koko taulua → on siis nopeampi verrattuna partitioimattomaan tauluun.

**Milloin kannattaa harkita partitiointia?**
- Taulun rivimäärä on huomattava
- Kyselyt kohdistuvat usein aikaväleihin (esim. yksi kuukausi)
- Tarve poistaa vanhoja tietoja säännöllisesti
- Halutaan vähentää tietokannan huoltoaikaa (esim. arkistoinnissa)

Partitioinnin lisääminen olemassa olevaan tauluun ei onnistu, joten pitää tehdä seuraavasti:
- Luo partition function ja partition scheme
- Luo uusi partitioitu taulu, jossa sama rakenne
- Siirrä data vanhasta taulusta uuteen (INSERT INTO … SELECT …)
- Poista vanha taulu ja nimeä uusi alkuperäisen nimiseksi tai käytä synonyymiä

