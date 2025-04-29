# Tehtävä 02:

Valitse joku tietokanta tai tee uusi. Lisää taulu:

```sql
CREATE TABLE Tilaus (
    TilausID INT PRIMARY KEY,
    AsiakasID INT NOT NULL, -- ei tehdä viiteavainta mihinkään toiseen tauluun
    TilausPvm DATETIME NOT NULL -- oletusarvona voi olla lisäyshetki
);
```

1. Tee ensi skripti, joka lisää 10 sekunnin välein Tuote-tauluun vaikka 10 riviä, AsiakasID on satunnainen luku välillä [1-10000]. Sopivan viiveen saat komennolle WAITFOR DELAY ja toiston voit tehdä WHILE-lauseella.

2. Ota tietokannasta varmistus

3. Aja edellinen skripti uudelleen mutta lisää 50 riviä.

3. Ota varmistus niin, että voi tarpeen mukaan palauttaa tilanteen haluttuun ajanhetkeen.

4. Toista kohdat 3 ja 4 muutaman kerran.

5. Palauta tietokanta valitsemaasi ajanhetkeen ja tarkista että se onnistui. Aineisto ainakin pitäisi olla sellainen, että palautuspisteen tarkistaminen onnistuu.


Palauta Moodleen testiaineiston tekevä skripti ja komennot, joilla otit varmistukset ja palautukset.





<!-- 
- Tutustu Windows Performance Monitor:iin eli suomeksi Suorituskyvyn valvonta.

- Windows 10:ssa esimerkiksi, löydät Performance Monitor:in valitsemalla:
- Hiiren oikealla Computer Management eli Tietokoneen hallinta
- Avaa Performance eli Suorituskyky
- Ja valitse Performance Monitor eli Suorituskyvyn valvonta
- Tutustu millaisia kaikenlaisia laskureita löytyy SQL Server:ille. Niitä pääsee tarkastelemaan klikkaamalla + painonappulaa, alla olevan kuvan mukaisesesti:<br>

![](Kuva_T02_01.PNG)<br>
Kuva 1. Windows 10 Performance Monitor Counters.<br>

- Löytyykö seuraavanlaiset laskurit?
- Suositeltavat laskurit, joita kannattaa seurata ylläpidon säännöllisesti ovat:
    - SQL Server Databases: Transactions/sec
- Millaisia tuloksia saat?
- [Tutustu sitä esittelevään sivuun Microsoft:illa](https://learn.microsoft.com/en-us/sql/relational-databases/performance-monitor/sql-server-databases-object?view=sql-server-ver16)
- Tutustu myös 
    - Sql Server Buffer Manager -> Buffer Cache Hit Ratio:oon
- Millaisia tuloksia saat koneellasi?
- [Millaisia ohjeita Microsoft antaa tästä laskurista?](https://learn.microsoft.com/en-us/sql/relational-databases/performance-monitor/sql-server-buffer-manager-object?view=sql-server-ver16) -->



