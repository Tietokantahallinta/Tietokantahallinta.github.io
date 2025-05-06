# Tehtävä 01:

Harjoitus: Optimoi kysely indeksoinnilla
🔹 1. Kysely ilman indeksiä
```sql
SELECT ProductID, Name, Color
FROM Production.Product
WHERE Color = 'Red';
```
Tämä haku käyttää saraketta Color, mutta siinä ei ole oletuksena indeksiä → SQL Server voi tehdä tauluskannauksen.

🔹 2. Tarkista, ehdottaako SQL Server uutta indeksiä
```sql
SELECT TOP 5 *
FROM sys.dm_db_missing_index_details AS mid
JOIN sys.dm_db_missing_index_groups AS mig
    ON mid.index_handle = mig.index_handle
JOIN sys.dm_db_missing_index_group_stats AS migs
    ON migs.group_handle = mig.index_group_handle
ORDER BY migs.avg_total_user_cost * migs.avg_user_impact DESC;
```
Tämä DMV kertoo, mille sarakkeille SQL Server suosittelisi indeksejä perustuen aiempiin kyselyihin.

🔹 3. Luo indeksi ehdotuksen perusteella
```sql
CREATE NONCLUSTERED INDEX IX_Product_Color
ON Production.Product (Color);
```
🔹 4. indeksi ja include (covering index) esimerkki
```sql
CREATE NONCLUSTERED INDEX IX_Product_Color_Covered
ON Production.Product (Color)
INCLUDE (ProductID, Name);
```
🔍 Tämä katettu indeksi voi palvella kyselyä ilman että tarvitsee hakea rivejä taulusta erikseen – nopeampi suoritus.

🔹 5. Testaa suoritussuunnitelmalla
```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT ProductID, Name, Color
FROM Production.Product
WHERE Color = 'Red';
```
Näet suoritussuunnitelmassa ja tilastoissa, miten indeksi vaikuttaa (hakustrategia muuttuu, I/O vähenee).

**Kysymys**:
Millainen suorituskykyero syntyy, kun käytät katettua indeksiä verrattuna siihen, että indeksiä ei ole? Käytä SET STATISTICS IO ON -asetusta ja vertaa lohkolukemia.

Palauta vastaus Moodleen.






<!-- - Tallennetut proseduurit. Microsoft Transact SQL, T-SQL
- Tietokannan varmistuksen automatisointi ja ajastus

- Perehdy SQL Server Agent:iin koulun SQL-EDU-02 SQL Server palvelimella.
- Miten sen avulla voi ajastaa esimerkiksi tietokannan varmistuksen?
- Kuinka usein tietokannan varmistuksen kannattaa tehdä?
- Miten se kannattaa tehdä? Kannattaako aina tehdä ns. full backup? Milloin kannatta ryhtyä tekemään ns. Incremental backup:ia.
- Miten teet näitä käyttäen ajastuksen varmistuksesta tietokannalle?

Palauta tämän jälkeen Moodleen, palautuslinkkiin  vastaus tehtävään. -->
