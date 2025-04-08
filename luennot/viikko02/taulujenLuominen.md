## Tietokantaobjektit

SQL Serverissä kaikki CREATE-komennolla luotavat asiat ovat objekteja yleisesti, ei kuitenkaan sotketa tähän olio-ohjelmoinnin objekti-käsitettä.

Tyypillisin tietokantaobjekti on taulu (table), siihen liittyviä toimintoja tutkitaan seuraavana.
Tietokantaobjektien käsittely liittyy SQL-kielen osaan DDL (Data Definition Language).

Kaikkia objekteja käsitellään komennoilla CREATE, ALTER ja DROP.

TSQL-komennon **CREATE TABLE** koko syntaksi löytyy [täältä](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-table-transact-sql?view=sql-server-ver16). Ihan kaikkia mahdollisia versioita komennosta ei käydä läpi. Taulun voi luoda myös graafisen käyttöliittymän kautta jos se tuntuu helpommalta, mutta sitten pitää muista ottaa luontiskripti talteen.

### Esimerkki
```SQL
 CREATE TABLE Luokittelu (
	LuokitteluID INT PRIMARY KEY,
	Tyyppi NVARCHAR(20) NOT NULL UNIQUE,
	Selite NVARCHAR(200) NULL
);

CREATE TABLE Tuote (
	TuoteID INT PRIMARY KEY,		
	Nimi NVARCHAR(30) NOT NULL,		
	Kuvaus nVARCHAR(500) NULL,
	Ohjehinta MONEY DEFAULT 0,
	Hintaryhmä int CHECK (Hintaryhmä BETWEEN 1 AND 5),
	LuokitteluID INT FOREIGN KEY REFERENCES Luokittelu(LuokitteluID)
);
```

### Avaimet
taulussa on oleva pääavain (primary key). Pääavain voi muodostua useammasta sarakkeesta ja sarakke(id)en tietotyyppi saa olla mitä tahansa. Nykyään yleensä käytetään avaimia, joilla ei ole muuta sisältöä kuin toimia yksilöllisenä arvona avaimena. Tyypillisin avaimen tietotyyppi on INT joka voidaan generoida automaattisesti kahdella, tai oikeastaan kolmella eri tavalla: IDENTITY, SEQUENCE ja Scalar Function.  

Jos avain muodostuu useammasta sarakkeesta, pitää PRIMARY KEY-määritys tehdä vasta sarakkeiden jälkeen.

```sql
CREATE TABLE tilausrivi(
	Tilausnro INT NOT NULL,
	Rivinro INT NOT NULL,
	...,
	PRIMARY KEY (Tilausnro, Rivinro) -- nämä sarakkeet muodostavat pääavaimen
);
```

Identity on ollut aina SQL Serverissä käytössä ja onkin helpoin tapa saada yksilöllisiä numeroita avaimeksi. Pelkkä IDENTITY aloittaa numeroinnin ykkösestä (1) ja kasvaa yhdellä. Parametrin avulla voi alkuarvon määrittää vapaasti, samoin kasvatuksen. 

```SQL
CREATE TABLE Demo(
    DemoID INT PRIMARY KEY IDENTITY(1000, 1),
    ...
)
```
Tämän jälkeen ei pääavaimeen pysty asettamaan itse arvoa ellei identity-asetusta käännetä pois päältä komennolla:
```SQL
SET IDENTITY_INSERT Demo ON;
```
Vastaavasti automaattiavainnus saadaan takaisin OFF-asetuksella. Joskus voi tulla tilanteita, missä halutaan skriptissä määritellä avaimen arvo myös IDENTITY-avaimiin ja silloin edellä mainittu tapa on toimiva keino ongelman ratkaisemiseen.

Sekvenssigeneraattori on objekti, joka ei liity yksittäiseen tauluun, vaan niiden avulla voi generoida mihin tahansa käyttöön kokonaislukuja.

```SQL
CREATE SEQUENCE DemoGeneraattori START WITH 1000 INCREMENT BY 1;
SELECT NEXT VALUE FOR DemoGeneraattori; -- Tällä saa seuraavan numeron 

create table Testi (
      ID INT PRIMARY KEY DEFAULT(NEXT VALUE FOR DemoGeneraattori),
      Nimi nvarchar(100)
);

INSERT INTO Testi(Nimi) values('Aku Ankka');
INSERT INTO Testi(Nimi) values('Jaska Jokunen');

-- oletuksen ohitus, voi määrittää avaimen arvon helposti INSERTissä
INSERT INTO Testi(ID, Nimi) values(999, 'Mustanaamio');

select * from Testi;
```

Scalar Function:lla voisi myös generoida avaimen, mutta ei ole yleisesti käytössä oleva tapa. Funktioille löytyy paljon muita parempia käyttökohteita. 


### Tietotyypit
- sarakkeiden tietotyypit
Taulun sarakkeille määritellään tietotyypit. SQL standardi määrittää tyypit, mutta käytännössä aika käytetään palvelimen omia tietotyyppejä. Luettelo SQL Serverin [ tietotyypeistä ](https://learn.microsoft.com/en-us/sql/t-sql/data-types/data-types-transact-sql?view=sql-server-ver16) on aika kattava.
Karkea jako menee näin:
- Exact numerics
- Approximate numerics
- Date and time
- Character strings
- Unicode character strings
- Binary strings
- Other data types

Muutama huomio näistä: 
- numeerisista tyypeistä löytyy tarkat ja likimääräiset tyypit
- merkkijonot talletetaan yhdellä ('esimerkki') tai kahdella tavulla (N'esimerkki', unicode) ja tuki UTF-8 merkistölle löytyy myös
- sarake voi olla Computed-tyyppinen jolloin sarakkeen tyyppi perustuu laskentakaavaan
- collate, tekstisarakkeiden merkistö/lajittelujärjestyksen määrittely sekä hakutoiminto, onko eroa isoilla ja pienillä kirjaimilla

**Laskennallinen sarake**
Sarakkeen arvo voi perustua rivin muihin sarakkeisiin eli olla laskennallinen (Computed column). Tämä johtaa tarkasti ottaen normalisoimattomaan tauluun, mutta ei ole ongelma, vaan joissain tilanteissa oikeasti helpottava ja järkevä ominaisuus.

```SQL
CREATE TABLE Tuote(
	TuoteID int PRIMARY KEY IDENTITY,
	Nimi NVARCHAR(40),
	Hinta0ALV MONEY DEFAULT 0,
	VerollinenHinta AS Hinta0ALV * 1.225,
	[VerollinenHinta€] AS CAST(Hinta0ALV * 1.225 AS MONEY)
);

INSERT INTO Tuote values('Testipalikka', 100);
SELECT * FROM Tuote;
UPDATE Tuote set Hinta0ALV = 42 where TuoteID = 1;
SELECT * FROM Tuote;
```
Esimerkissä verolliseksi hinnaksi tulee float-tyyppinen arvo laskentakaavan perusteella ja toinen vastaava sarake, jossa tyyppi pakotetaan kaavassa tyyppimuunnoksella kahteen desimaaliin (Money). Lisäksi esimerkissä on sarakenimessä euro-merkki, joka on aivan mahdollinen SQL Serverissä jos objektin nimessä käytetään []-määrettä. Tällöin objektin nimi voi sisältää välilyöntejä ja erikoismerkkejä. Normaalisti ei kannata käyttää, hankaloittaa ohjelmallista käyttöä. Kaikkia ominaisuuksia ei tarvitse käyttää, mutta tämä mahdollistaa joitakin erikoistilanteita.

### Collate 
Collation määrittää miten sarakkeessa olevaa dataa käsitellään haku- ja lajittelu-toiminnoissa. Vaikuttaa sarakkeisiin, joiden tietotyyppi on CHAR, NCHAR, VARCHAR tai NVARCHAR. Käytettäkööt tässä väkisin väännettyä suomankielistä sanaa kollaatio. Kollaatio määritetään taulun luonnin yhteydessä jokaiselle sarakkeelle erikseen. Oletuksena käytetään kollaatiota, joka periytyy joko tietokannan asetuksista tai palvelimen asetuksista. Tämän lisäksi jokaiseen SELECT-lauseeseen voi erikseen määritellä mitä kollaatiota käytetään juuri sen lauseen suorituksessa. 

Kollaatioita on paljon ja oleellisin asia on ymmärtää mitä nimiin koodatut asiat tarkoittavat. Esimerkiksi kollaatio **Finnish_Swedish_CI_AS**, alkuosa lienee selvä ja lopussa olevat CI ja AS tarkoittavat Case-Insensitive ja Accent-Sensitive. CS ja AI ovatkin jo arvattavissa. 
Mihin tämä sitten vaikuttaa? Jos kollaatio sarakkeella on CS, pitää hakutoiminnossa WHERE-ehto kirjoittaa täsmälleen samalla tavalla kuin tietokantaan talletettu data on kirjoitettu, CI vastaavasti ei välitä hakutoiminnossa kirjainten koosta. AI/AS taas erottaa tai ei erota toistaan a ja ä kirjainta ORDER BY-lauseessa. Siksipä AS-tyyppiset kollaatiot on yleensä suomessa käytössä.   

```sql 
CREATE TABLE Kollaatio (
	id int IDENTITY(1,1) NOT NULL,
	nimi1 nvarchar(50) COLLATE Finnish_Swedish_CI_AS,
	nimi2 nvarchar(50) COLLATE Finnish_Swedish_CS_AS,
	nimi3 nvarchar(50) COLLATE Finnish_Swedish_CI_AI
);

-- kokeile myös:
SELECT * FROM sys.fn_helpcollations();
SELECT * FROM sys.fn_helpcollations() WHERE Name like 'Finnish%';

-- ehkä helpoin tapa selvittää tauluun liittyviä tietoja, esim kollaatio
sp_help <taulu>;
```sql 

### Rajoitteet ja muut määreet

```sql 
CREATE TABLE Rajoitteita (
	ID int PRIMARY KEY IDENTITY,
	Tuotekoodi CHAR(10) UNIQUE NOT NULL,
	Nimi VARCHAR(30) DEFAULT 'puuttuu',
	Kuvaus VARCHAR(1000) NULL,
	Luokitus INT CHECK (Luokitus between 1 AND 5)
);
```

- default: 	sarakkeen oletusarvo jos ei aseteta INSERT-lauseessa
- unique: 	sarakkeesta tulee sisällön osalta yksilöllinen, kahta samaa arvoa ei voi olla (vrt. pääavain) ja vain yksi NULL
- null:		sarakkeen sisältö voi olla NULL
- not null: sarake on pakollinen, NULL ei sallittu
- check: 	sarakkeen täytyy täyttää CHECK-ehto


### Foreign key
Viiteavaimet määritellään taulun luonnin yhdeydessä normaalisti. Joissakin tapauksissa kun tietokantarakenteet muuttuvat jolloin olemassa olevaan tauluun voidaan lisätä sarakkeita ja määritellä ne viiteavaimiksi. Viiteavaineheyttä ei voi rikkoa määrityksen jälkeen. Esimerkiksi jos tietokannassa on Tuote ja Tuotekommentti taulut, jossa Tuotekommentissa on tuotteeseen liittyvä asiakaspalaute, ei tuotetta voi poistaa jos siihen liittyy tuotekommentteja. Tätä sääntöä voidaan ohjata lisäämällä UPDATE ja DELETE-säännöt:

- RESTRICT (oletus): estetään operaatio, viite-eheyttä ei voi rikkoa mitenkään
- CASCADE: vyörytetään muutos viittaavaan sarakkeeseen, pääavaimen päivitys muuttaa viittaavassa taulussa viiteavainsaraketta
- SET NULL: asetetaan viittaavaan sarakkeeseen NULL
- SET DEFAULT: asetetaan viittaavaan sarakkeeseen oletusarvo

INSERT-komentoon ei voi liittää muutossääntöjä, se epäonnistuu aina jos viite-eheys ei toteudu

```sql
-- sarakkeen yhteydessä
CREATE TABLE Tuotekuvaus (
	TuotekuvausID int primary key identity(1,1),
	TuoteID int FOREIGN KEY REFERENCES Tuote(TuoteID),
	Kuvaus nvarchar(20),
	Pvm datetime DEFAULT getdate()
);

-- Rajoitteena lopuksi
CREATE TABLE TuoteKommentti (
	TuotekuvausID int primary key identity(1,1),
	TuoteID int,
	Kuvaus nvarchar(2000),
	Pvm datetime DEFAULT getdate(),
	CONSTRAINT FK_Tuotekommentti_Tuote FOREIGN KEY (TuoteID) REFERENCES Tuote(TuoteID)
);

-- Voidaan myös lisätä ALTER TABLE-komennolla 
ALTER TABLE Kuvaus ADD TuoteID INT;
ALTER TABLE Kuvaus
ADD CONSTRAINT FK_Kuvaus_Tuote FOREIGN KEY (TuoteId) REFERENCES Tuote(TuoteId) 
	ON DELETE CASCADE 
	ON UPDATE CASCADE; -- nämä voi olla myös CREATE TABLE –komennossa mukana
```sql

Jos viiteavainmääritys lisätään taulun luonnin jälkeen, pitää olemassa olevan data toteuttaa viite-eheys, tai muuten viiteavainmäärittely epäonnistuu.

### ALTER TABLE
Tyypillisiä muutoksia taulun rakenteeseet ovat:
- sarakkeiden lisäys
- sarakkeiden poisto (ei välttämättä tehdä vaikka poisto loogisesti olisi järkevää)
- sarakkeen tietotyyppin muutos

```sql
-- lisäys
ALTER TABLE Tuotekuvaus ADD Varastotuote BIT NULL;

-- poisto
ALTER TABLE Tuotekuvaus DROP COLUMN Varastotuote;

-- tyypin muutos
ALTER TABLE Tuotekuvaus ALTER COLUMN Kuvaus NVARCHAR(1000);
```sql

Tietotyypin muunnoksessa on huomioitava olemassa oleva data. Tyyppi voi vaihtua, jos konversio on mahdollista. Tyypillisesti kuitenkin muutetaan numeerinen tyyppi toiseen tai lisätään tekstisarakkeen pituutta (harvoin lyhennetään).

```sql
CREATE TABLE t2(
	nimi varchar(10)
);
INSERT INTO t2 VALUES('100'); 
INSERT INTO t2 VALUES('POKS');
SELECT * FROM t2;
ALTER TABLE t2 ALTER COLUMN Nimi INT; -- onnistuuko vai ei?
SELECT * FROM t2;
```

### Clustered Index ja primary key
Taulun luonnin yhteydessä muodostuu automaattisesti klusteroitu indeksi (Clustered index). Indeksi on mahdollista poistaa ja tehdä uudelleen vaikka jonkin muun sarakkeen perustella, jos hakuja tehdään tauluun paljon jonkin muun kuin avainsarakkeen perusteella. Useimmiten oletusindeksointi on kuitenkin hyvä ja toimiva. Indekseistä lisää myöhemmin kurssin aikana.


<!-- ## Muut taulutyypit
-- - **Filetable**, taulua voidaan käsitellä sekä tietokantapalvelimen kautta että suoraan ikään kuin se olisi tiedosto tiedostojärjestelmässä. 
-- - Graph table
-- - Ledger
-- - jne
-->

