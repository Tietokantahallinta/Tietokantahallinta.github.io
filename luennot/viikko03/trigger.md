# Trigger

Relaatiotokantojen alkuvaiheessa ei standardia ollut olemassa. Relaatiomalli kuitenkin vaatii eheyksien säilymistä ja esimerkiksi viiteavaineheydestä pidettiin huolta huolellisuudella ja tarkalla ohjelmoinnilla. Mutta sehän ei käytännössä riitä, aina joku onnistuu rikkomaan jotain. Siksi ensimmäisiin tuotteisiin ohjelmoijat keksivät kätevän keinon ylläpitää eheyksiä ja samalla tehdä muitakin toimintoja liittyen tiedon päivityksiin (UPDATE, DELETE, INSERT). Tämä toimintomalli tunnetaan trigger-nimellä. 
**Trigger** on eräällä tavalla proseduurin erikoistapaus, joka käynnistyy jostain DML-komennosta, triggeriä ei voi käynnistää tai suorittaa kutsumalla sitä suoraan. Trigger liittyy siis vain ylläpitotoimintoihin, ei SELECT-lauseeseen. Alunperin trigger liittyy vain datan käsittelyyn, mutta nykyisin on myös triggereitä, jotka liittyvät DDL-komentoihin ja ne määritellään tietokantaan tai palvelimeen. Tässä keskitytään vain DML-triggereihin.

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
CREATE TRIGGER tr_UpdateDate ON TUotekuvaus -- voi käyttää etuliitettä, vrt. avaimet ja indeksit 
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
ALTER TRIGGER tr_UpdateDate ON TUotekuvaus
	FOR UPDATE
AS
	IF UPDATE(Kuvaus)
		UPDATE Tuotekuvaus SET PVM = GETDATE() 
	FROM inserted i WHERE i.TuotekuvausID = Tuotekuvaus.TuotekuvausID;
```


