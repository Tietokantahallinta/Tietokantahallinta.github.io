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

Scalar Function:in käytöstä voisi olla yksinkertainen tekninen esimerkki käytöstä avaimien generoinnissa. Ei ole ensisikainen käyttökohde, vaan ihan muita käyttöjä löytyy funktioille. 


### Tietotyypit
- sarakkeiden tietotyypit
- collate, määrityksissä ja kyselyissä

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

