# Tehtävä 01:

Takkulan tietokannassa pääavaimet ovat merkkijonoja. Käytännössä tämä alkaa aiheuttaa pientä kiusaa koodaajille ja he päättävät muuttaa kaikki avaimet INT-tyyppisiksi ja lisäksi IDENTITY -määreellä automaatisesti generoituviksi. 
- Tehtävänä on miettiä ja toteuttaa muutos yhden skriptitiedoston avulla peräkkäisillä komennoilla. 
- Tarvittaessa voit tehdä uuden tietokannan TakkulaV2, johon ensin siirrät/kopioit/luot Takkulan tietokannan sisältöineen ja sitten teet tarvittavat muutokset.
- Miten muutos kannattaa tehdä?
- Pystyykö sen tekemään?
- Mikä on hankalin asia toteuttaa muutoksessa?
- Joudut ehkä käyttämään aputauluja tai tilapäisiä tauluja.

Palauta Moodleen muutosskripti tai selitys miksi konversiota ei voi tehdä.

<!-- 
- Lataa koneellesi kurssin Materiaalit kappaleesta löytyvä AdventureWorks2012_Data.mdf tietokanta tiedosto. Siirrä se SQL Server:isi Data -kansioon, eli
C:\Program Files\Microsoft SQL Server\MSSQL16.SQLEXPRESS\MSSQL\DATA
tai jokin vastaava SQL Server versiosta riippuen. Tarvitset Administrator tunnukset - jotka sinulla on omalla koneellasi olevaan SQL Server:iin.<br>

![](Kuva_T01_01.PNG)<br>
Kuva 1. AdventureWorks2012_Data.mdf tietokanta.<br>

- Attach:aa eli liitä se ajettavaksi tietokannaksi SQL Server palvelimeesi Microsoft SQL Server Management Studiolla (SSMS). Klikkaa hiiresi oikealla korvalla Databases objektia SSMS:n Object Explorer:issa. 
- Klikkaa sen jälkeen Add -painonappulaa.
- Ja valitse AdventureWorks2012_Data.mdf alla olevan kuvan mukaisesti: <br>

![](Kuva_T01_02.PNG)<br>
Kuva 2. AdventureWorks2012_Data.mdf liittäminen tietokantapalvelimeen.<br>

- Remove:a tietokannalle ehdotettu transaktioloki tiedosto pois. Sitä ei ole toimitettu. Tietokanta saadaan liitettyä ilman sitä. <br>

![](Kuva_T01_03.PNG)<br>
Kuva 3. AdventureWorks2012_Data.mdf lokitiedostoehdotuksen poisto.<br>

- Nyt tietokanta on tietokantapalvelimessasi.

<br>

![](Kuva_T01_04.PNG)<br>
Kuva 4. AdventureWorks2012_Data.mdf tietokantapalvelimellasi.<br>

- Tämän tietokannan taulun eheyden tarkistamisen voi tehdä Microsoft SQL Server:issä komennolla:
<br>
<code>
dbcc showcontig('TAULUNIMI');
</code>
<br>

![](Kuva_T01_05.PNG)<br>
Kuva 5. AdventureWorks2012_Data.mdf tietokannan erään taulun statistiikka tiedot.<br>

Palauta tämän jälkeen Moodleen, palautuslinkkiin  T-SQL kielinen scripti (Transact-SQL), jolla saat selville jonkin AdventureWorks2012_Data tietokannan taulun statistiikka tiedot ja T-SQL komento, jota käytit. -->
