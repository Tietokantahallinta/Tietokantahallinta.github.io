# Trigger

Relaatiotietokantojen alkuvaiheessa ei standardia ollut olemassa. Relaatiomalli kuitenkin vaatii eheyksien säilymistä ja esimerkiksi viiteavaineheydestä pidettiin huolta huolellisuudella ja tarkalla ohjelmoinnilla. Mutta sehän ei käytännössä riitä, aina joku onnistuu rikkomaan jotain. Siksi ensimmäisiin tuotteisiin ohjelmoijat keksivät kätevän keinon ylläpitää eheyksiä ja samalla tehdä muitakin toimintoja liittyen tiedon päivityksiin (UPDATE, DELETE, INSERT). Tämä toimintomalli tunnetaan trigger-nimellä. 
**Trigger** on eräällä tavalla proseduurin erikoistapaus, joka käynnistyy jostain DML-komennosta. Triggeriä ei voi käynnistää tai suorittaa kutsumalla sitä suoraan. Trigger liittyy vain ylläpitotoimintoihin, ei SELECT-lauseeseen. Alunperin trigger liittyy vain datan käsittelyyn, mutta nykyisin on myös triggereitä, jotka liittyvät DDL-komentoihin ja ne määritellään tietokantaan tai palvelimeen. Tässä keskitytään vain DML-triggereihin.

Trigger liitetään aina johonkin tauluun ja proseduureista se eroaa muun muassa siten, että triggeriä ei voi parametroida. Triggerin toiminta perustuu aina muutoksen kohteena olevan rivin dataan. Trigger voi aiheuttaa muutoksen, joka käynnistää toisen triggerin.

Triggerin käsittely kuten muutenkin tietokantaobjeteilla CREATE, ALTER ja DROP -komennoilla. Lisäksi on olemassa ENABLE ja DISABLE-komennot, joilla voi deaktivoida triggerin ja taas palauttaa sen toimintaan.

```sql
-- esimerkki
DISABLE TRIGGER tr_updateCounters ON StoreStatistics;
ENABLE TRIGGER tr_updateCounters ON StoreStatistics;
```

Trigger luodaan [komennolla](https://learn.microsoft.com/en-us/sql/t-sql/statements/create-trigger-transact-sql?view=sql-server-ver16):
```sql
-- HUOM, tässä hieman siivottu versio, katso dokumenteista koko syntaksi
CREATE [ OR ALTER ] TRIGGER [ schema_name.]trigger_name   
    ON { table | view }   
    [ WITH <dml_trigger_option> [ ,...n ] ]  
    { FOR | AFTER | INSTEAD OF }   
    { [ INSERT ] [ , ] [ UPDATE ] [ , ] [ DELETE ] }   
AS { sql_statement  [ ; ] [ ,...n ] | EXTERNAL NAME <method specifier [ ; ] > }  
```

Triggerin toiminta, trigger käynnistyy aina muutoksen jälkeen (AFTER-trigger, on oletus). CHECK-konstraintilla pystyy tekemään samoja asioita kuin triggereillä, mutta CHECK suoritetaan aina ennen päivitystä. INSTEAD OF -tyyppinen trigger korvaa päivityslauseen, yleensä tätä käytetään näkymien yhteydessä ja on käytännössä harvinaisempi. Trigger sisältää TSQL-komentoja, mutta ei kaikkia. Esimerkiksi komentoja; CREATE DATABASE, CREATE PROCEDURE, CREATE TABLE, ALTER TABLE, DROP TABLE, jne ei voi käyttää. Triggerin talletuksessa tulee virheilmoitus jos koetat käyttää jotain kiellettyä komentoa, mutta hyvin harvoin sellainen tulee edes käytännössä vastaan.

Triggereiden avulla ei enää kannata huolehtia viiteavaineheydestä, FOREIGN KEY -määritys on parempi. Edelleen sopivia käyttökohteita ovat suojaukset, lokitietojen kirjaus ja tiedon automaattinen laskenta esimerkkeinä mainittuna.

Esimerkki triggeristä, joka päivittää viimeisen muutoshetken automaattisesti:
```sql
GO
CREATE TRIGGER tr_UpdateDate ON Tuotekuvaus -- voi käyttää etuliitettä, vrt. avaimet (PK, FK) ja indeksit (IDX)
	FOR UPDATE
AS
	UPDATE Tuotekuvaus SET PVM = GETDATE() 
	FROM inserted i WHERE i.TuotekuvausID = Tuotekuvaus.TuotekuvausID;

GO
-- aiheutetaan päivitys ja selvitetään tuloksen perusteella toimiiko trigger
UPDATE Tuotekuvaus SET Kuvaus = 'Todella toimii' where TuotekuvausID = 1;
SELECT * FROM Tuotekuvaus;
```
Esimerkki ei ole ihan täydellinen, korjataan sitä hetken kuluttua. Trigger sidotaan INSERT, UPDATE tai DELETE, mikä tahansa yhdistelmäkin kelpaa. 

Triggerin toimintalogiikka on siis se, että trigger käynnistyy halutuista komennoista. Mutta mistä sitten tietää mikä komento on aiheuttanut triggerin käynnistämisen. Sen voi päätellä kahden aputaulun avulla jotka ovat inserted ja deleted. Nämä taulut ovat olemassa vain triggerin suorituksen aikana. Inserted-taulussa ovat kaikki lisätyt rivit INSERT-komennossa ja UPDATE:ssa taulusta löytyy uudet päivitetyt saraketiedot. Deleted-taulussa on poistetun rivin tiedot DELETE-komennon jälkeen ja UPDATE:ssa sieltä löytyy päivitettävien rivien alkuperäiset sarakkeiden arvot. Näiden aputaulujen perusteella voi päätellä, miksi trigger on käynnistynut ja kaikki muutokseen liittyvä data löytyy myös aputauluista.
Aputaulujen lisäksi voi erikseen kysyä onko joku tietty sarake päivittynyt. Edellisessä esimerkissä kannattaisi muuttaa triggeriä niin, että vain kuvaus-sarakkeen muutos päivittää päivityshetken nykyhetkeen.

```sql
ALTER TRIGGER tr_UpdateDate ON Tuotekuvaus
	FOR UPDATE
AS
	IF UPDATE(Kuvaus)
		UPDATE Tuotekuvaus SET PVM = GETDATE() 
	FROM inserted i WHERE i.TuotekuvausID = Tuotekuvaus.TuotekuvausID;
```

Milloin trigger käynnistyy? SQL standardi määrittelee BEFORE ja AFTER -tyyppiset triggerit, SQL Serverissä on AFTER ja INSTEAD OF triggerit. BEFORE-triggeriä ei tarvita, koska päivitystapahtuma voidaaan peruuttaa triggeerin sisällä ja näin ollen ei tarvitse olla erikseen BEFORE-triggeriä.
INSTEAD OF -trigger korvaa kokonaan päivityslauseen ja on käytännössä harvinaisempi.

### Esimerkit triggereistä ###

Ensin AFTER-trigger

```sql
-- Luodaan taulut ja lokituksen toteuttava trigger 
CREATE TABLE Staff
(
    StaffID int PRIMARY KEY IDENTITY,
    Name varchar(50),
    Salary money
);

CREATE TABLE SalaryLog
(
    LogID int PRIMARY KEY IDENTITY,
    StaffID int,
    OldSalary money,
    NewSalary money,
    ChangeDate datetime
);

-- trigger
CREATE TRIGGER trg_Staff_AfterUpdate
ON Staff
AFTER UPDATE
AS
BEGIN
    INSERT INTO SalaryLog
    (
        StaffID,
        OldSalary,
        NewSalary,
        ChangeDate
    )
    SELECT
        d.StaffID,
        d.Salary,
        i.Salary,
        GETDATE()
    FROM deleted d
        JOIN inserted i
            ON d.StaffID = i.StaffID
    WHERE d.Salary <> i.Salary;
END;
GO

-- Testataan toimintoa
INSERT INTO Staff VALUES('Outi', 2500);
UPDATE Staff SET Salary = 3000 WHERE StaffID = 1;
SELECT * FROM Staff;
SELECT * FROM SalaryLog;
```

Triggerin toiminta:
1. Staff-taulun rivi/rivejä päivitetään
2. Päivitys onnistuu
3. AFTER-trigger käynnistyy
4. Vanha arvo löytyy deleted-taulusta
5. Uusi arvo löytyy inserted-taulusta
6. Muutos tallennetaan SalaryLog-tauluun

Seuraavana esimerkki INSTEAD OF -triggeristä, joka siis korvaa alkuperäisen komennon. 

```sql
CREATE TRIGGER trg_Staff_InsteadOfInsert
ON Staff
INSTEAD OF INSERT
AS
BEGIN

    IF EXISTS
    (
        SELECT *
        FROM inserted
        WHERE Salary > 5000
    )
    BEGIN
        RAISERROR('Palkka ei saa ylittää 5000 euroa',16,1);
        RETURN;
    END

    INSERT INTO Staff(Name, Salary)
    SELECT Name, Salary
    FROM inserted;

END;
GO

-- testi
INSERT INTO Staff(Name, Salary) VALUES('Teppo', 4000); -- onnistuu
INSERT INTO Staff(Name, Salary) VALUES('Jaakko', 7000); -- EI onnistu
```

Triggerin toiminta:
1. Käyttäjä suorittaa INSERTin
2. SQL Server ei lisää riviä Staff-tauluun
3. INSTEAD OF -trigger käynnistyy
4. Triggeri tarkistaa palkan
5. Jos sääntö täyttyy, trigger tekee INSERTin itse
6. Muussa tapauksessa operaatio hylätään

Esimerkissä palkan yläraja on kovakoodattu, sen voisi aivan hyvin hakea jostain parametritaulusta.

```sql
CREATE TABLE Parameters
(
    ParameterName varchar(50) PRIMARY KEY,
    ParameterValue decimal(10,2)
);
GO
INSERT INTO Parameters VALUES ('MaxSalary', 5000);
GO

ALTER TRIGGER trg_Staff_InsteadOfInsert
ON Staff
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaxSalary decimal(10,2);

    SELECT @MaxSalary = ParameterValue
    FROM Parameters
    WHERE ParameterName = 'MaxSalary';

	-- tarkistetaan että oikea parametri löytyi:
	IF @MaxSalary IS NULL THROW 50001, 'MaxSalary-parametria ei löydy.', 1;

    IF EXISTS (
        SELECT *
        FROM inserted
        WHERE Salary > @MaxSalary
    )
    BEGIN
        RAISERROR ('Palkka ylittää sallitun enimmäispalkan.', 16, 1);

        RETURN;
    END;

    INSERT INTO Staff (Name, Salary)
    	SELECT Name, Salary FROM inserted;

END;
GO
```


INSTEAD OF -triggeriä voi käyttää näkymien yhteydessä.

```sql
CREATE VIEW vStaff
AS
SELECT StaffID, Name, Salary
FROM Staff;
GO
--
CREATE TRIGGER trg_vStaff_Insert
ON vStaff
INSTEAD OF INSERT
AS
BEGIN

    INSERT INTO Staff(Name, Salary)
    SELECT Name, Salary
    FROM inserted;

END;
GO
-- Lisätään näkymään
INSERT INTO vStaff(Name, Salary) VALUES('Liisa', 3500); -- lisää Staff-tauluun rivin
```