# Tehtävä 01:

- Tietokannan taulujen seuranta ja eheyttäminen sekä fragmentoitumisaste.

- Selvitä tietokannan taulujen fragmentoitumisaste. Esimerkiksi AdventureWorks2012_Data tietokannan Person.Contact taulun fragmentoitumisasteen saa selville SQL Server:ssä komennolla:<br>
<code>
dbcc showcontig(’Person.CountryRegion’);
</code>
<br>
- Millainen on kyseisen taulun fragmentoitumisaste?
- Selitä mitä fragmentoituminen tarkoittaa tietokanta taulujen kohdalla. Miksi fragmentoitumisen poistaminen on tärkeää? Mitkä voivat olla seuraukset, jos tietokannan taulujen fragmentoitumista ei poisteta?

- Tietokannan taulujen eheyden voi tarkistaa SQL Server:ssä komennolla:<br>

<code>
dbcc checkdb ('tietokannan_nimi');
</code>
<br>
- Käytä tätä komentoa AdventureWorks2012_Data tietokannan eheyden selvittämiseks.
- Millaisia tietoja saat selville.

- Joskin tietokannan taululuista on korruptoitunut, voi sen pyrkiä korjata repair optiolla dbcc checkdb komennossa. 
<br>
Esimerkiksi:
<br>
Siirry ensin Single User tilanna tietokannassa ensin:<br>
<program>
alter database Tietokannan_nimi;<br>
set single_user;<br>
go;<br>
</program>
<br>
Nopeita pieniä vikoja eheysehdoissa voi korjata komennolla:
<program>
dbcc checkdb (’Tietokannan_nimi’, repair_fast);<br>
go;<br>
</program>
<br><br>
Edellinen komento ei korjaa indeksejä tietokannassa. Ve voi korjata komennolla:
<program>
dbcc checkdb (’Tietokannan_nimi’, repair_rebuild);<br>
go;<br>
</program>
<br><br>
Jos tilanne eheysehtojen korjaamisessa tietokannassa on niin huono, että kumpikaan yllä olevista komennoista ei niitä korjaa, voi yrittää seuraavaa dramaattisempaa komentoa:

<program>
dbcc checkdb (’Tietokannan_nimi’, repair_allow_data_loss);<br>
go;<br>
</program>

- Kokeile komentoa AdvetureWorks tietokantaan.

- Tietokannan taulun eheyden voi tarkastaa komennolla:
<code>
dbcc checktable('Person.Contact');<br>
</code>

Palauta tämän jälkeen Moodleen, palautuslinkkiin  vastaus tehtävään.
