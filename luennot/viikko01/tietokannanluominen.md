## Tietokannan luominen - CREATE DATABASE;

UUsi tietokanta luodaan joko komennolla
```sql
CREATE DATABASE <nimi>; 
```
tai graafisen käyttöliittymän kautta.

Tietokannan luomisesta löytyy [lisää asiaa](https://learn.microsoft.com/en-us/sql/relational-databases/databases/create-a-database?view=sql-server-ver16) ja sen ohella Transact-SQL komennon kaikki optiot löytyvätä [täältä](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-database-transact-sql?view=sql-server-ver16&tabs=sqlpool).

Jos tietokantatiedosto(t) (ja mahdollinen lokitiedosto) on jo olemassa, voidaan tietokanta liittää suoraan käyttöön ATTACH-toiminnolla (sekä komento että graafinen käyttöliittymä).

Tietokannan luonnin yhteydessä voi säätää todella paljon erilaisia asetuksia. Minimissään riittää määrittää tietokannan nimi, mutta käytännössä muutama asetus kannattaa tehdä tai ainakin tarkistaa, pitääkö niitä muuttaa tai säätää.

Käyttöliittymän kautta uusi tietokanta tehdään Object Explorer-ikkunassa avaamalla context-valikko hiiren oikealla korvalla Databases-kansion päällä.

![Database context menu](..\kuvat\Createdatabase.jpg)

Eri asetukset on helpointa käydä läpi käyttöliittymän kautta, kaikki samat asetukset pystyy tekemään TSQL-komennolla ja jos tietokanta pitää pystyä tekemään uudelleen skriptinä, on luontikomento oltava jossain tiedostossa. Toki jälkikäteen luontiscriptin voi tehdä SSMS:llä Script-toiminnolla ja sen voi tallentaa tiedostoon.

## New Database
![New Database](..\kuvat\NewDBPages.jpg)

### General
Tässä määritellään tietokannan nimi. Nimi noudattaa SQL Server:in objektien nimisääntöjä, jolloin nimi voi olla melkein mitä tahansa.Kuitenkin kannattaa nimetä tietokanta konservativisesti, ei siis erikoismerkkenä yms kikkailua, siitä ei ole käytännössä hyötyä vaan pelkästään käytännön haittaa.

Tietokannan omistajaksi tulee oletuksena komennon suorittava käyttäjä (login), omistajan voi valita listalta olemassa olevista login-tunniksista. Login/User-käsitteestä tuonnempana lisää.

Tietokanta muodostuu vähintään kahdesta tiedostosta, varsinainen tietokantadata .MDF-päätteinen tiedosto (File Type: ROWS) ja lisäksi transaktiolokitiedosto LDF-päätteellä. Oletuksena tiedostot tulevat asennushakemiston alle tai hakemistoon, joka on tietokantapalvelimen asetuksissa määritelty. Paikallisesti asennettuna oletus on hyvä, mutta tuotantoympäristössä kannattaa tietokantatiedostot sijoittaa omalle levylle ja mahdollisesti jopa data ja loki eri levyille. Näin saa lisää suorituskykyä kun levy-IO jakaantuu eri levyille.   
Tietokannan koko voidaan asettaa, oletuksena 8Mt. Tietokannan koko voi kasvaa automaattisesti tai koko voidaan rajoittaa tiettyyn arvoon. Jos koko saa kasvaa automaattisesti ja levytila loppuu, loppuu myös tietokannan käyttö ja vaatii hallintatoimenpiteitä. Esimerikiksi virtuaalikoneeseen lisää levyä tai perinteiseen laitteistoon levyn siivous ja sitten siirto toiselle levylle tai uusien tietokantatiedostojen avulla jatketaan tallennnusta useammalle levylle.

### Options

Sivun alussa on neljä asetusta ja n+1 kappaletta vielä alla listassa.

**Collation** määrittää 'merkistön', jonka mukaan palvelin vertailee ja lajittelee tekstiä. Oletuksena käytetään palvelimen oletusta, muutoin valitaan tilanteeseen sopiva. Kollaatioiden nimissä näkyy usein CI/CS ja AI/AS, nämä tarkoittavat Case Insensitive, Case Sensitive, Accent Insensitive ja Accent Sensitive. Kannatta huomata, että löytyy Finnish_Swedish -kollaatio, joka lienee aika sopiva tähän ilmastoon.

**Recovery model**: Full, Bulk-logged ja Simple. Näistä simple sopii kehitys- ja testikantaan, tuotannossa taas käytössä Full. Lisää tietoa löytyy [täältä](https://learn.microsoft.com/en-us/sql/relational-databases/backup-restore/recovery-models-sql-server?view=sql-server-ver16). 

**Compatibility level**, uusin ellei ole tarve jostain syystä käyttäytyä kuin jokin vanhempi versio.  

**Containment type**, oletuksena ei mitään ja valinta Partial tuottaa eristetyn tietokannan. Siinä olevat käyttäjät eivät voi käsitellä muita tietokantoja.

Muita optioita voi asettaa, mutta sitä ennen selvitä mitä vaikutusta niillä on. Tunnilla selataan muutama asetus läpi, joilla on merkitystä muutamien toimintomallien kannalta.

### Filegroups
Tietokantatiedostot, loki ja indeksit voidaan sijoittaa eri levyille ja eri tiedostoihin. Jopa taulu voidaan asettaa tallentumaan haluttuun tiedostoon. Näitä hallinnoidaan filegroups-asetuksilla. 


