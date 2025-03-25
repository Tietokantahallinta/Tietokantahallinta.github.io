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
SELECT NEXT VALUE FOR DemoGeraattori; -- Tällä saa seuraavan numeron 

create table Testi (
      ID INT PRIMARY KEY DEFAULT(NEXT VALUE FOR DemoGeneraattori),
      Nimi nvarchar(100)
);

INSERT INTO Testi(Nimi) values('Aku Ankka');

-- oletuksen ohitus, voi määrittää avaimen arvon helposti
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
- sarake voi olla Computed-tyyppinen jolloin sarakkeen tyyppi perustuus laskentakaavaan
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

### Rajoitteet ja muut määreet
- default
- unique
- null/not null
- check

### Foreign key
- luonti ja toiminta
- cascade, default, delete, set null

### ALTER TABLE
- foreign key
- tietotyyppien muutokset
- sarakkeiden lisäys
- sarakkeiden poisto

### Filegroup

### Oletuksena Clustered Index primary keylle

## DDL update, delete, insert?

## Muut taulutyypit
- Filetable
- Graph table
- Ledger
- jne

