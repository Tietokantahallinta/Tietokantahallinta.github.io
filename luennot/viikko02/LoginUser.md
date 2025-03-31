# Login ja user

Tietokantapalvelimeen pitää kirjautua. Kirjautuminen (login) tehdään joko Windows-tunnuksella (myös Azure AD-tunnus) tai SQL Serverin omalla tunnuksella ja salasanalla.
Windows-kirjautumisessa SQL Serverille välittyy käyttäjän Access Token käyttöjärjestelmältä jossa on mukana tieto mihin AD-ryhmiin käyttäjä kuuluu. Ryhmiä voi käyttää oikeuksien jakamiseen.
Vaihtoehtoisesti voi käyttää SQL Serverin omaa käyttäjätunnusta (ja salasanaa), jolla ei ole mitään tekemistä minkään Windows-käyttäjän kanssa. Molemmissa tapauksissa varsinainen login-tieto (siis kuka saa kirjautua) on Master-tietokannassa. 
Login-tunnuksen jälkeen tarvitaan vielä tietokannan käyttäjätunnus, joka pitää erikseen tehdä tai tehdään login-tunnuksen luomisen yhteydessä. Loginiin sidottu käyttäjätunnus määrää minkä nimisenä käyttänä näkyy tietokannassa. Login-tunnuksen takana voi olla jokaisessa tietokannassa eri käyttäjä. Jokaisella tietokannan käyttäjätunnuksella (siis ei login vaan user) on oletusschema. 

```sql
-- Windows-login esimerkki
CREATE LOGIN [HAAGAHELIA\TeppoTesti]
FROM WINDOWS
WITH DEFAULT_DATABASE = Takkula

-- SQL Server -login esimerkki
CREATE LOGIN Nakke
WITH PASSWORD = ’P@ssw0rD?’,
DEFAULT_DATABASE = Takkula,
CHECK_EXPIRATION = ON, -- (oletus: off)
CHECK_POLICY = ON – (oletus: on)
```

Ensimmäisellä kerralla on helpointa tehdä logintunnus SSMS:n käyttöliittymän kautta. New Login -ikkunassa ensimäisellä välilehdellä on tunnukseen liittyvät perusmäärittelyt ja User Mappings -lälilehdellä on asetukset käyttäjänimeen (user) sekä oletus schemaan. **DEMO** Tietokannan käyttäjä voidaan tehdä siis käyttöliittymän kautta samalla kun tehdään login-tunnus.

TSQL-komento käyttäjän (user) tekemiseen on seuraava ja tunnus pitää liittää johonkin login-tunnukseen.

```sql
USE AdventureWorks

-- Roopen oletusschema on dbo
CREATE USER Teppo FOR LOGIN [HAAGAHELIA\TeppoTesti]

-- Matin oletusschema on DemoSchema (voi tehdä ennen scheman luontia)
-- schema käsitellään aivan tuossa tuokiossa...
CREATE USER Matti FOR LOGIN Matti 
    WITH DEFAULT_SCHEMA = Tuotanto
```

Muutama huomio
- login-tunnuksella pääsee tietokantaan (user) jos guest on enabloitu tai käyttäjänä dbo jos login on serveradmin (katso loginin luonti ja Server Roles -välilehti)
- kaikki tietokannan käyttäjät kuuluvat Public-rooliin ja Publicille määritellyt oikeudet pätevät kaikkiin käyttäjiin
- loginiin liittyy palvelintasoisia oikeuksia
- tietokannan sisällä oikeudet annetaan käyttäjille (user) ja rooleille (role)
- oikeuksia jaetaan tietokantaobjekteille, joita ovat taulut, näkymät, talletetut proseduurin, funktiot, triggerit, indeksi ja skemat

## Schema
Tietokannassa on objekteja ja objekti kuuluu aina johonkin skemaan (schema). Jos ei ole muuta määritelty, on oletuksena käytössä dbo-skema. Skema, mihin objekti kuuluu, näkyy SSMS:n Object Explorer-ikkunassa ja sen toki saa selville myös TSQL-komennoilla:

```sql
select * from sys.objects;  -- objektit
select * from sys.schemas;  -- skemat
select * from INFORMATION_SCHEMA.TABLES; -- valmiiksi purettu auki
```

Käyttäjällä (login --> **user**) on oletusskema ja oikeuksia voi antaa yksittäisille objekteille tai koko skemaan, jolloin oikeudet tulevat kaikille skeman sisältäville tietokantaobjekteille.

Miten sitten kaikki liittyy esimerkiksi CREATE TABLE -komentoon?

```sql
CREATE SCHEMA Tuotanto;
CREATE TABLE Tuotanto.Varasto ( -- schema.object
	VarastoID INT PRIMARY KEY IDENTITY,
	Nimi NVARCHAR(40),
	Kapasiteetti FLOAT
);

-- Aku:lle oikeudet schemaan ja sen objekteihin
GRANT SELECT ON SCHEMA::Tuotanto TO Aku;

-- Aku:
select * from Tuotanto.Varasto;
-- Matti: (katso aikaisempi käyttäjän luontokomento)
select * from Varasto;
```

Ettei kokonaan unohdu, mainittakoon että objekteille voi määritellä synonyymejä. Synonyymi on eri asia kuin taulun aliasnimi kyselyissä.
Kun jollekin tietokantaobjektille määritellään synonyymi, voi objetiin viitata joko alkuperäisellä nimellä tai synonyymillä. Synonyymin avulla objekti voidaan siirtää vaikka skemasta toiseen jos käytetään kyselyissä synonyymiä.

```sql 
CREATE SCHEMA Production;
CREATE SYNONYM Production.Storage FOR Tuotanto.Varasto;

select * from Tuotanto.Varasto;
select * from Production.Storage;
```

## Käyttöoikeuksista

Käyttöoikeuksia jaetaan tietokannoissa käyttäjille ja rooleille. Rooli vastaa käyttäjäryhmää. SQL Serverissä voidaan käyttää myös AD-ryhmiä, tällä kurssilla asiaa käsitellään vähemmän, koska ei ole oikeaa aitoa AD tai AAD ympäristöä käytössä ja muutenkin Windows-käyttäjien ja ryhmien hallinta ei kuulu varsinaisesti juuri tälle kurssille.

SQL Serverissä on roolit jaetti tietokantarooleihin ja palvelinrooleihin (Server role). Palvelinroolit on tarkoitettu tietokantapalvelimen hallinnointiin ja tietokantaroolit objektion käyttöoikeuksien määrittelyyn.

Tietokantarooleja on jo valmiina ja näitä voi tehdä lisää. Rooli voi sisältää toisen roolin tai käyttäjiä.    

```sql
CREATE ROLE Laskutus;
GRANT SELECT TO Laskutus;
ALTER ROLE Laskutus ADD MEMBER Aku;
```

Valmiit tietokantaroolit selitykseneen löytyy [täältä](https://learn.microsoft.com/en-us/sql/relational-databases/security/authentication-access/database-level-roles?view=sql-server-ver16). Käyttäjät voidaan lisätä näihin rooleihin ALTER ROLE-komennolla edellisen esimerkin mukaan tai näin:

```sql
ALTER ROLE db_owner ADD MEMBER Matti;
```

Oikeudet annetaan GRANT-komennolla ja otetaan pois REVOKE:lla, nämä ovat SQL-standardin mukaisia toimintoja. Kannattaa huomata, että oikeuksia voi olla esimerkiksi eri ryhmien kautta. Riittää, että käyttäjällä on oikeudet mitä tahansa kautta. Jos käyttäjä kuuluu kahteen ryhmään ja molempien kautta on esimerkiksi UPDATE-oikeus johonkin tauluun ja jos REVOKE:lla otetaan oikeus pois toisesta ryhmästä, saa käyttäjä edelleen tehdä UPDATE:n. Tämän takia SQL Serverissä on lisäksi oma DENY-komento, jolla voidaan täysin ottaa joltain käyttäjältä tai ryhmältä oikeudet pois.