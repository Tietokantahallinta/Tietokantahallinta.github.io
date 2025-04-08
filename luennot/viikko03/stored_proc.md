# Talletut proseduurit, stored procs

Stored Procedure on nimensä mukaisesti aliohjelma, joka on talletettu tietokantaan, se vastaa varsinaisten ohjelmointikielten funktiota (metodi). SQL Server sisältää paljon valmiita proseduureja (sp_attachdb, sp_help, ...) ja niitä voidaan tarpeen mukaan tehdä lisää CREATE PROC -komennolla. Muutos ALTER PROC ja poisto DROP PROC, nämä kaikki komennot pitää olla omassa batch:ssa. Proseduurille voidaan välittää parametreja (maksimi 2100 parametria) ja se voi palauttaa vastausjoukon tai yksittäisen paluuarvon kuten muutkin ohjelmointikielet sekä dataa voi palauttaa OUTPUT-tyyppisessä parametrissa. Proseduurin koodilogiikan toteuttaminen muuttujien, ehtojen, toistojen ja tietysti TSQL:n avulla.

Syitä miksi proseduureja käytetään:

Miksi proseduuri:
- Sovelluslogiikan sijoitus tietokantapalvelimelle, kaikki sovelluksen käyttävät samaa logiikkaa riippumatta kielestä ja tietokantakirjastosta
- Modulaarisuus, voidaan paketoida toimintoja proseduurien sisään 
- Tietokannan monimutkaisuuden piilotus, välitetään data parametrina ja käsittelylogiikka voi olla monimutkainen ilman että siihen tarvitsee kiinnittää enempää huomiota enää käyttövaiheessa
- Suojaukset, voidaan päivittää proseduurien kautta 
- Suorituskyky, toteutussuunnitelma jää muistiin
- Verkkoliikenteen vähentäminen

Miksi ei:
- hankala ohjelmointikieli ja ympäristö
- debuggaaminen ja testaaminen hankalaa
- sovelluksen siirrettävyys toiseen tietokantaympäristöön on todella työlästä (complete re-write)
- palvelimen prosessoinnin lisääntyminen

Olemassa olevien proseduurien koodin saa selville sp_help -proseduurilla tai SSMS:n Object Explorerissa Script-toiminnolla.
Proseduurin suorittaminen EXEC(UTE)-komennolla:
```sql
EXECUTE sp_help cdemo;
EXEC sp_help cdemo;
dbo.sp_help cdemo; 
```
Pari esimerkkiä proseduurin luomisesta ja käytöstä:
```sql
--EXECUTE sp_help cdemo;
--EXEC sp_help cdemo;
--dbo.sp_help cdemo;
GO
CREATE PROC demo1proc 
AS
	SELECT Nimi from tuote where Hinta0ALV < 10 ORDER BY Nimi;
GO

--DROP PROC tuotteetHintaNoin

CREATE PROC tuotteetHintaNoin
	@hinta MONEY
AS
	SELECT Nimi from tuote where Hinta0ALV between @hinta - 5 AND @hinta + 5 ORDER BY Nimi;

-- käyttö:
EXEC tuotteetHintaNoin 15;

GO
CREATE PROC tuotteetHintaValilla -- parametrien käyttö
	@alaraja MONEY, 
	@ylaraja MONEY 
AS
	SELECT Nimi from tuote where Hinta0ALV between @alaraja  AND @ylaraja ORDER BY Nimi DESC;

-- käyttö:
EXEC tuotteetHintaValilla 20, 30;

GO
ALTER PROC tuotteetHintaValilla -- muutos ==> parametrien oletusarvot
	@alaraja MONEY = NULL, 
	@ylaraja MONEY = NULL 
AS
	IF @alaraja IS NULL SET @alaraja = 0;
	IF @ylaraja IS NULL select @alaraja = MAX(hinta0ALV) from Tuote;
	SELECT Nimi from tuote where Hinta0ALV between @alaraja AND @ylaraja ORDER BY Nimi DESC;

-- käyttö:
EXEC tuotteetHintaValilla null, 20; -- positionaaliset parametrit
EXEC tuotteetHintaValilla 38, 42;
EXEC tuotteetHintaValilla @ylaraja = 5; -- nimetyt parametrit
EXEC tuotteetHintaValilla @ylaraja = 5, @alaraja = 1;
```

CREATE PROC-komennon suorituksessa palvelin tarkistaa syntaksin ja tallettaa koodin systeemitauluihin. Vasta ensimmäisellä suorituskerralla tulee ensimmäisen kerran tarkistus, että koodissa olevat tietokantaobjektit ovat olemassa. Jos kaikki vaikuttaa olevan kunnossa, tulee suorituksen optimointi ja tämä suoritussuunnitelma (execution plan) jää talteen seuraavia suorituskertoja varten. Tämä on yksi seikka, joka parantaa suorituskykyä proseduureja käytettäessä. 

```sql
CREATE PROC demo2proc 
AS
    -- virheellinen taulunimi, proseduuri tallettuu kuitenkin
	SELECT Nimi from tuoteEIOO where Hinta0ALV < 10 ORDER BY Nimi;

demo2proc; -- suoritus epäonnistuu ==> korjataan ALTER PROC komennolla
```
Esimerkki OUTPUT-parametrin käytöstä:
```sql
CREATE PROCEDURE summa
	@luku1 INT,
	@luku2 INT,
	@tulos INT OUTPUT
AS
    SELECT @tulos = @luku1 + @luku2;
GO

DECLARE @vastaus int;
EXECUTE summa 42, 24, @vastaus OUTPUT;
SELECT 'Vastaus on:' , @vastaus;
```

Ja sama paluuarvon avulla:
```sql
ALTER PROCEDURE summa
	@luku1 INT,
	@luku2 INT
AS
	DECLARE @tulos INT;
	SET @tulos = @luku1 + @luku2;
	RETURN @tulos;
GO

-- kutsu
DECLARE @paluuarvo INT
EXEC @paluuarvo = summa 12, 34
SELECT @paluuarvo
```

Proseduurissa voi kuten skripteissäkin, tarkistaa edellisen lauseen onnistumisen @@ERROR muuttujalla. Nolla (0) tarkoittaa ettei virhettä ole aiheutunut, nollasta poikkeava numero on virhekoodi. Huomaa, että @@ERROR ei talleta viimeisintä virhekoodia vaan sisältää viimeisimmän lauseen suorituksen onnistumistiedon.

Normaalisti tietokantapalvelin palauttaa tiedon, moneenko riviin muutos on kohdistunut. Se on useimmissa tapauksissa turhaa tietoa ja tämän voi ottaa pois päältä komennolla SET NOCOUNT ON. Takaisin saa takaisin päälle OFF. Proseduureissa yleensä käytetään NOCOUNT ON -asetusta. Muuttuja @@ROWCOUNT sisältää aina rivien lukumäärän, NOCOUNT ei vaikuta siihen. 


