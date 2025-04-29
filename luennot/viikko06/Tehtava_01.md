# Tehtävä 01:

Tehtävässä käytettävä tietokanta löytyy [osoitteesta](https://drive.google.com/file/d/1MYXUdgR0vz_YPBeHOA-oS0Uo-gPAFZe_/view?usp=drive_link). 
Kyseessä on erän SQL Serverin virallisista demotietokannointa.

1. Lataa tiedosto, kopioi se sopivaan paikkaan ja ota tietokanta käyttöön. Tiedostopäätteen perusteella pystyt päättelemään miten saat sen tehtyä (restore tai attach). Toiminnon voi tehdä joko SSMS:n käyttöliittymän kautta tai TSQL-komennolla.

2. Selvitä tietokannan taulujen fragmentoitumisaste. Esimerkiksi AdventureWorks2012_Data tietokannan Person.Contact taulun fragmentoitumisasteen saa selville SQL Server:ssä komennolla:<br>
```sql
dbcc showcontig(’Purchasing.PurchaseOrderHeader’);
```

- Millainen on kyseisen taulun fragmentoitumisaste?
- Kannattaako fragmentoitumiselle tehdä mitään ja ota selville miten mahdollinen fragmentoituminen korjataan

3. Tietokannan taulujen eheyden voi tarkistaa SQL Server:ssä komennolla:
```sql
dbcc checkdb ('tietokannan_nimi');
```

- Käytä tätä komentoa AdventureWorks2012_Data tietokannan eheyden selvittämiseks.
- Millaisia tietoja saat selville.
- Jos tietokannan taulu on korruptoitunut, voi sen koettaa korjata **repair optiolla** *dbcc checkdb* komennossa. 
<br>
Esimerkiksi:
```sql
--Siirry ensin Single User tilanna tietokannassa ensin:<br>
alter database Tietokannan_nimi;
set single_user;
go;
```
Nopeita pieniä vikoja eheysehdoissa voi korjata komennolla:
```sql
dbcc checkdb ('Tietokannan_nimi', repair_fast);
go;
```
Edellinen komento ei korjaa indeksejä tietokannassa. Ve voi korjata komennolla:
```sql
dbcc checkdb ('Tietokannan_nimi', repair_rebuild);<br>
go;
```
Jos tilanne eheysehtojen korjaamisessa tietokannassa on niin huono, että kumpikaan yllä olevista komennoista ei niitä korjaa, voi yrittää seuraavaa dramaattisempaa komentoa:

```sql
dbcc checkdb ('Tietokannan_nimi', repair_allow_data_loss);
go;
```

- Kokeile komentoa AdvetureWorks tietokantaan.

- Tietokannan taulun eheyden voi tarkastaa komennolla:
```sql
dbcc checktable('Purchasing.PurchaseOrderHeader');
```

Palauta tämän jälkeen Moodleen lyhyt kommentti mitä sait selville tai opit.
