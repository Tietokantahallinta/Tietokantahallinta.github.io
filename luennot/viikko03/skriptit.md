# Skriptit

Skripti on joukko komentoja Query-ikkunassa tai tiedostossa. Skripti voi sisältää TSQL-kielen komentoja, muuttujia, ohjelmarakenteita yms., SSMS:n kautta skriptiä voi suorittaa halutuissa osissa tai sitten koko skriptin kerrallaan. Skripti sisältää 1-n kpl batch:eja Batchit erotetaan toisistaan GO-komennolla. Batch:ssa oleva komennot suoritetaan kokonaisuutena, mutta pitää huomata, että Batch ei muodosta tapahtumaa (Transaction). Jotkut komennot vaativat että ne suoritetaan kokonaan omassa batch:ssa.

```sql
-- Skripti-tiedosto
select * from Tuote;
update Varaosa set hinta = hinta * 1.1 where VaraosaID = 4212;
GO -- ensimmäinen skriptin batch päättyy
begin tran
-- komentoja...
commit tran 
GO -- toinen päättyy ja erikseen pitää määrittää tapahtumat
select * from Asiakas where vip = 1;
select email from asiakas where vip = 1;
GO --viimeinen batch päättyy
```

Omassa Batch:ssa suoritettavia komentoja:
- CREATE PROCEDURE
- CREATE RULE, 
- CREATE DEFAULT
- CREATE TRIGGER 
- CREATE VIEW

```sql
select * from Kollaatio;
create view VipAsiakkaat as select * from asiakas where tilausSumma > 1000000;
```
Aiheuttaa virheen:
```sql
Msg 111, Level 15, State 1, Line 4
'CREATE VIEW' must be the first statement in a query batch.
```

Korjauksena on ympäröidä *CREATE VIEW* **GO** komennoilla.

Aina ei riitä pelkät komennot, vaan tarvitaan ehtoja, toistorakenteita, muuttujia, jne. TSQL-kielessä on melko monipuolisesti näitä tarjolla, mutta kieli on kömpelöä verrattuna varsinaisiin ohjelmointikieliin. SQL Serveriin voisi ohjelmoida myös käyttäen C#-kieltä, mutta sitä mahdollisuutta ei juurikaan käytetä, vaan mennään perinteisesti TSQL:llä.

Käytettäviä rakenteita ovat:
- Muuttujat
- Kommentit
- BEGIN END
- IF ELSE
- WHILE, BREAK, CONTINUE
- CASE
- GOTO, RETURN
- PRINT
- RAISERROR
- WAITFOR
- TRY/CATCH
- Kursorit

**Muuttujat** esitellään DECLARE-lauseella, muuttujanimet alkavat aina @-merkillä ja muuttuja tietotyyppi voi olla mikä tahansa SQL Serverin tunnistama tyyppi ja saraketyyppien lisäksi käytössä on Table eli muuttuja voi sisältää taulua vastaavan rakenteen. Muuttujalle asetetaan arvo SET-komennolla tai SELECT:ssä. 

Table-tyyppisen muuttujan sisältämä taulu on olemassa vain batch:in, proseduurin, triggerin tai funktion suorituksen ajan. Muuttujaa käytettäessä voidaan korvata tilapäinen taulu (temporary table, käsitellään myöhemmin materiaalissa).

```sql
-- kommentit loppurivikommenttina
/* tai toinen vaihtoehto:
kommentti joka alkaa ja päättyy alku- ja loppumerkeillä, 
voi olla rivin keskelläkin mutta ei voi olla sisäkkäisiä kommentteja */
DECLARE @nimi NVARCHAR(100) = 'Matti'; -- kommentti
SET @nimi = N'Teppo';
DECLARE @summa MONEY;
SELECT @summa = SUM(tilaussumma) FROM Tilaukset WHERE AsiakasID = 6564;
PRINT 'Summa: ' + CAST(@summa AS NVARCHAR); 
SELECT @summa * 1.255 AS TilaussummaALV;

-- Taulutyyppinen muuttuja:
DECLARE @t TABLE(
    ID INT NOT NULL PRIMARY KEY, 
    Nimi NVARCHAR(20));

INSERT @t VALUES(10, 'Hiiri');
INSERT @t VALUES(20, 'Matto');

SELECT * FROM @t;
SELECT * from @t t1 JOIN Tuote t2 ON t1.ID = t2.TuoteID; -- JOIN onnistuu joten @t toimii kuten taulu
```

Koodilohko, siis enemmän kuin yksi lause, määritellään **BEGIN** ja **END** sanoilla.

Ehtolause ja toistorakenne:
```sql
DECLARE @pvm date
SELECT @pvm = KURSSI.alkupvm FROM Takkula..KURSSI WHERE kurssikerta = 1 AND ainenro = 'a480'; 
IF DATEPART(day	, @pvm) in (1, 7) 
BEGIN 
	print 'Kurssi ei voi alkaa viikonloppuna!'
END
ELSE BEGIN
	print 'OK';
END

-- toisto vain WHILE:llä 
DECLARE @lkm INT = 1
SET NOCOUNT ON;
WHILE @lkm < 20 
BEGIN
	DECLARE @hinta money;
	SET @hinta = RAND() * 100;
	INSERT INTO Tuote Values('Testituote' + CAST(@lkm AS VARCHAR), @hinta);
	INSERT INTO Tuote Values('Testituote' + CAST(@@IDENTITY AS VARCHAR), @hinta);
	SET @lkm = @lkm + 1;
END
SELECT * FROM Tuote;
```

Muista ohjelmointikielistä tutut **BREAK** ja **CONTINUE** ovat käytettävissä silmukoissa. BREAK lopettaa silmukan suorituksen ja CONTINUE siirtyy tarkistamaan ehdon eli aloittaa silmukan seuraavan kierroksen. 

**GOTO** on on käytettävissä, saattaa olla outo ja 'uusi' tapa nykyohjelmoijalle. Voi ja saa käyttää kun yksinkertaistaa koodia. On kuitenkin vältettävissä lähes aina.

```sql
-- tekninen esimerkki: hyppyosoitteen määritys ja siihen hyppy GOTO:lla
print 'Alkaa...'
GOTO OHI;
print 'meneekö ohi?'
OHI:    -- hyppyosoite (
print 'Ohi on'
```

**CASE** on hyvä muistaa, koska sen avulla saadaan ehdollista toimintaa SELECT-lauseen sisälle. Samoin käytettävissä mm. komennoissa UPDATE, DELETE ja SET.
SQL Server toteuttaa kaksi eri [CASE-muotoa](https://learn.microsoft.com/en-us/sql/t-sql/language-elements/case-transact-sql?view=sql-server-ver16): simple ja search.

```sql
-- Simple yksinkertainen, vain yhtäsuuruusvertailut:
SELECT TuoteID,
CASE Hinta0ALV
     WHEN 0 THEN 'PUUTTUU'
	 WHEN NULL THEN 'VIRHE'
     ELSE CAST(Hinta0ALV as NVARCHAR)
END	 AS Hinta
FROM Tuote;

-- Searched
SELECT TuoteID, Hinta0ALV,
CASE
     WHEN Hinta0ALV IS NULL THEN 'Virhe'
     WHEN Hinta0ALV = 0 THEN 'Puuttuu'
     WHEN Hinta0ALV < 40 THEN 'Edullinen'
     WHEN Hinta0ALV < 70 THEN 'Keskihintainen'
     ELSE 'Kallis'
END AS Hinta
FROM Tuote;
```

**PRINT** -komennolla lähetetään viestejä client-sovellukselle. SSMS näyttää PRINT-tulostukset Messages-välilehdellä. Sama paikka mihin tulee virheilmoituksetkin. Varsinaista dataa eli vastausjoukkoa ei voi PRINT:llä välittää palvelimelta.

**RAISE ERROR**, tällä aiheutetaan virhetilanne. Vastaa esimerkiksi Javan *throw new Exception()* toimintoa.

**TRY/CATCH** lauseella saadaan virhekäsittelyä selkeämmäksi verrattuna @@ERROR-muuttujan käyttöön. Virheen saa toki selville @@ERROR-muuttujalla, 0 == ei virhettä ja muuten sisältää virhekoodin. Muuttujassa ei säily virhe vaan seuran lauseen suoritus resetoi muuttujan uuteen arvoon. Perinteinen tapa oli tarkistaa skripteissä @@ERROR-muuttujalla onnistuminen/epäonnistuminen. Vaihtoehtona TRY/CATCH on kätevä.

```sql
BEGIN TRY 
	select top 1 * from tuote;
	raiserror (20001, 16,1);
	print 'ei pitäisi tulostua'
END TRY
BEGIN CATCH
DECLARE @virhe int = @@error 
print ERROR_NUMBER()
print ERROR_SEVERITY() 
print ERROR_STATE()  
print ERROR_MESSAGE()
print ERROR_LINE() 

	print 'virhekoodi: ' 
	print @virhe;
	if @virhe = 20001 
		print 'Virhe käsitelty'
	else
		print 'tunnistamaton tilanne';
END CATCH
```

**Dynaaminen SQL** mahdollistaa SQL-lauseen luomisen merkkijonona ja sen suorituksen sp_executesql -proseduurilla tai EXECUTE-komennolla )sp_executesqp parempi). Toisinaan ei tarvittava lause ole selvillä etukäteen vaan vasta suorituksen yhteydessä. Esimerkiksi triggereissä ja proseduureissa voi tulla näitä tilanteita vastaan. Tästä myöhemmin materiaalissa esimerkki triggereiden yhteydessä.   

```sql

DECLARE @sql NVARCHAR(500);
SET @sql = N'SELECT Nimi, Hinta0ALV from Tuote';
EXEC sp_executesql @sql;

-- voidaan myös parametroida:
DECLARE @ID INT
DECLARE @parametrinTiedot NVARCHAR(50)
SET @parametrinTiedot = N'@tid INT'
SET @sql = N'SELECT Nimi, Hinta0ALV from Tuote WHERE TuoteID = @tid';
SET @ID = 42;
EXEC sp_executesql @sql, @parametrinTiedot, @tid = @ID 
SET @ID = 123;
EXEC sp_executesql @sql, @parametrinTiedot, @tid = @ID
-- osaa käyttää toisen lasuseen suorituksessa ensimmäisen Execution Plan:ia 
```

**Kursorit**
Dataa tietokannan sisällä käsitellään yleensä komennoilla, jotka kohdistuva 0-n riviin. Komennon suorituksesta vastaa tietokantapelvelin eikä komennon suoritukseen pääse mitenkään kiinni (korkeintaan Execution Plan). Toisinaan on kuitenkin tarve skripteissä tai proseduureissa käsitellä vastausjoukkoa rivi kerrallaan ja tämä rivi kerrallaan käsittely perustuu kursorikäsitteeseen. Useimpien ohjelmointikielten tietokantakäsittely on myös kursorityyppistä ja jos joku on kuullut termin *upotettu SQL ja COBOL*, niin totta on että tämän kaltainen tietokantadatan käsittely on keksitty ja toteutettu jo 70-luvulla. Jos saman asian voi tehdä sekä SQL-komennoilla että kursoreilla, pitää komentoja käyttää koska suorituskyky on selvästi parempi kuin kursoreiden avulla saman toiminnon toteuttaminen. TSQL-kielessä kursoria siis käytetään vain kun muita vaihtoehtoja ei ole.

Kursori on käytännössä osoitin johonkin vastausjoukon riviin. Ensin määritellään SELECT-lause ja liitetään siihen kursori, sitten kursori avataan (lauseen suoritus) ja vastausjoukon rivejä voi sen jälkeen käsitellä yksi kerrallaan. Lopuksi kursiri pitää sulkea.

1. määrittele kursori ja lause (DECLARE CURSOT FOR)
2. avaa kursori (OPEN)
3. hae rivi käsiteltäväksi (FECTH)
4. käsittely
5. toista kunnes kaikki käsitelty
6. sulje kursori (CLOSE, DEALLOCATE)

Tekninen esimerkki:
```sql
DECLARE @nimi VARCHAR(20); 
DECLARE @nimilista VARCHAR(8000) = ''; 
DECLARE @lkm INT = 0;
-- kursorilla oikeastaan kannattaisi olla kuvaavampi nimi kuin 'kursori'
DECLARE kursori CURSOR FOR SELECT DISTINCT nimi FROM Tuote;

OPEN kursori

FETCH NEXT FROM kursori INTO @nimi -- haetaan ensimmäinen rivi

WHILE (@@FETCH_STATUS = 0) -- status 0 ==> ei enää rivejä käsiteltävänä
BEGIN 
	SET @lkm = @lkm + 1;
	SET @nimilista = @nimilista + @nimi + ', ';
	FETCH NEXT FROM kursori INTO @nimi; -- haetaan seuraava rivi
END

-- suljetaan ja vapautetaan resurssit
CLOSE kursori;
DEALLOCATE kursori;

print 'Tuotenimien lkm: ' + CAST(@lkm as VARCHAR);
print 'Tuotteiden nimet listana: ' + @nimilista
```

Toinen esimerkki:
```sql
DECLARE @taulu nvarchar(128)
DECLARE @sql nvarchar(500)
DECLARE c CURSOR
	FOR SELECT name FROM sys.tables
		WHERE ledger_type_desc like 'NON%' and schema_id = 1
		ORDER BY 1
OPEN c
FETCH NEXT FROM c INTO @taulu
WHILE (@@FETCH_STATUS = 0) BEGIN '' status -1 ei enää rivejä
		SET @sql = 'select ''' + @taulu + ''' AS Taulu, count(*) AS RiviLkm from ' + @taulu;
	    exec sp_executesql @sql
	    FETCH NEXT FROM c INTO @taulu
END
CLOSE c
DEALLOCATE c

-- kannattaa kokeilla esimerkkiä myös niin, että dynaamisen SQL:n tilalla on:
-- EXEC sp_spaceused @taulu
```

FETCH-komento hakee seuraavan rivin käsiteltäväksi vastausjoukosta. Yleisimmin käsitellään yksi kerrallaan ja käytetään lisämääreenä NEXT:iä, joka on oletus jos ei kirjoiteta näkyviin. Muut kuin NEXT vaativat SCROLL-tyyppisen kursorin (katso hieman eteenpäin syntaksia). Muita vaihtoehtoja ovat:
```sql
FETCH [ NEXT | PRIOR | FIRST | LAST | ABSOLUTE {n | @nvar} | RELATIVE {n | @nvar} ]
```

Tarkennuksena tässä vaiheessa, että kursoreita voi määritellä ANSI tai TSQL -syntaksilla. ANSI-syntaksi noudattaa standardia ja avainsanat ovat ennen CURSOR -sanaa. TSQL:n DECLARE on laajempi kuin standardin mukainen eikä niitä voi käyttää ristiin. Jos tarkoitus ei ole siirtää skriptiä eri palvelimien välillä, kannattaa käyttää TSQL:n mukaista versiota.

```sql
-- ANSI
DECLARE cursor_name [INSENSITIVE] [SCROLL] CURSOR 
    FOR select_statement [FOR {READ ONLY | UPDATE [OF column_list]}]

-- TSQL
DECLARE cursor_name CURSOR 
    [LOCAL | GLOBAL] 
    [FORWARD_ONLY | SCROLL]
    [STATIC | KEYSET | DYNAMIC | FAST_FORWARD]
    [READ_ONLY | SCROLL_LOCKS | OPTIMISTIC]
    [TYPE_WARNING]
FOR select_statement
    [FOR UPDATE [OF column_name [,...n]]]
```

<!-- Kursorin avulla voi taulun sisältöä myös päivittää (UPDATE ja DELETE).

```sql
``` -->






