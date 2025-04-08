# Funktiot 

SQL Serverissä on kolme funktiotyyppiä:
1. skalaari, palauttaa yhden arvon 
2. table, palauttaa taulun
3. aggregaatti, palauttaa yhden arvon, näitä ei käsitellä koska vaatii .NET/C#-osaamista

Skalaarifunktioista voisi käyttää esimerkkinä vaikka GETDATE() tai SUBSTRING()-funktioita. Omia funktioita käytetään samoin kuin systeemin omia funktioita ja ne voi tietysti parametroida. Esimerkki skalaarifunktiosta: 

```sql
create table Asiakas(
	AsiakasID INT PRIMARY KEY IDENTITY, 
	Etunimi nvarchar(20),
	Sukunimi nvarchar(30),
	Email nvarchar(40)
);

insert into Asiakas values('jaakko', 'kulta', 'jaakko.kulta@hotmail.com');
insert into Asiakas values('jukka', 'PALMU', 'jukkap@hotmail.com');
insert into Asiakas values(' Heli', 'Kopteri', 'heli@iki.fi');
select * from Asiakas;

GO
CREATE FUNCTION Nimi(@id int) 
	RETURNS NVARCHAR(50)
AS BEGIN
	DECLARE @enimi AS NVARCHAR(20);
	DECLARE @snimi AS NVARCHAR(30);
	SELECT @enimi = TRIM(Etunimi), @snimi = TRIM(Sukunimi) from Asiakas WHERE AsiakasID = @id;
	RETURN UPPER(SUBSTRING(TRIM(@enimi), 1, 1)) + LOWER(SUBSTRING(@enimi, 2, 20))
		+ ' ' + UPPER(SUBSTRING(TRIM(@snimi), 1, 1)) + LOWER(SUBSTRING(@snimi, 2, 30));
END
GO

select dbo.Nimi(1);
select asiakasID, dbo.Nimi(AsiakasID) AS Nimi from Asiakas;
```

Funktio voi palauttaa taulun (INLINE):
```sql
CREATE FUNCTION TuotteenKommentit(@tuoteid int)
    RETURNS TABLE AS
	    RETURN (SELECT * FROM TuoteKommentti WHERE TuoteID = @tuoteid);
GO

--Kutsu, ei tarvitse schemaa (dbo) alkuun
SELECT * FROM TuotteenKommentit(12);
```

Voi olla monimutkaisempikin:
```sql
GO
CREATE FUNCTION Kommentit(@tuoteid int) 
RETURNS NVARCHAR(4000)
AS BEGIN
	DECLARE @data AS NVARCHAR(4000);
	select @data = STRING_AGG(SUBSTRING(Kuvaus, 1, 50), ', ') from TuoteKommentti where TuoteID = @tuoteid;
	RETURN COALESCE(@data, '');
END

	insert into TuoteKommentti values(2, 'Loistava', getdate());

	select * from TuoteKommentti;
	select * from Tuote;


--Monilauseinen Table-funktio:
GO
CREATE FUNCTION Tuotenimet(@muoto nvarchar(5))
RETURNS 
	@t table
   (TuoteId 	int PRIMARY KEY NOT NULL,
   Nimi  nvarchar(200) NULL)
AS
BEGIN
   IF @muoto = 'Lyhyt'
      INSERT @t SELECT Tuoteid, nimi FROM Tuote
   ELSE IF @muoto = 'Pitkä'
      INSERT @t SELECT Tuoteid,	nimi + ': ' + dbo.Kommentit(tuoteid) FROM Tuote;
RETURN
END 
go

SELECT * FROM Tuotenimet('Lyhyt');
SELECT * FROM Tuotenimet('Pitkä');
```



