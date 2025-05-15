# Tehtävä 02:

# Harjoitus: Päivitykset, fillfactor ja indeksin ylläpito

Tässä harjoituksessa huomaat, miten indeksin fillfactor vaikuttaa päivitysten jälkeen syntyvään fragmentaatioon ja kuinka SQL Server tarjoaa kaksi vaihtoehtoa indeksin ylläpitoon: **reorganize** ja **rebuild**.


1. Luo testitaulu AdventureWorksin yhteyteen

```sql
USE AdventureWorks;
GO

CREATE TABLE dbo.CustomerTest (
    CustomerID INT PRIMARY KEY,
    Name NVARCHAR(100),
    ModifiedDate DATETIME
);
GO

-- Lisää testidataa
DECLARE @i INT = 1;
WHILE @i <= 10000
BEGIN
    INSERT INTO dbo.CustomerTest VALUES (
        @i,
        CONCAT('Customer ', @i),
        GETDATE()
    );
    SET @i += 1;
END;

2. Luo ei-klusteroitu indeksi fillfactorilla
```sql
CREATE NONCLUSTERED INDEX IX_CustomerTest_Name
ON dbo.CustomerTest (Name)
WITH (FILLFACTOR = 90);
```
🔍 Fillfactor 90 % tarkoittaa, että sivuille jätetään 10 % tilaa tulevia muutoksia varten.

3. Päivitä dataa niin, että sivut hajoavat (page splits):

```sql
UPDATE dbo.CustomerTest
SET Name = Name + ' updated'
WHERE CustomerID % 10 = 0;
```

🔄 Tässä päivitetään joka kymmenes rivi – monissa tapauksissa tiedon pidentyminen aiheuttaa sivujen jakautumista.

4. Tarkista indeksin pirstoutuminen (fragmentaatio)

```sql
SELECT 
    ips.index_id,
    i.name AS index_name,
    ips.avg_fragmentation_in_percent,
    ips.page_count
FROM sys.dm_db_index_physical_stats (
    DB_ID('AdventureWorks'),
    OBJECT_ID('dbo.CustomerTest'),
    NULL,
    NULL,
    'LIMITED'
) AS ips
JOIN sys.indexes AS i
    ON ips.object_id = i.object_id AND ips.index_id = i.index_id
WHERE ips.page_count > 100;
```

📉 Jos avg_fragmentation_in_percent on yli 10–15 %, indeksi kannattaa reorganisoida. Jos se on yli 30 %, kannattaa uudelleenrakentaa.

5. Korjaa pirstoutunut indeksi
- 🛠 A. Reorganize (kevyt huolto)
```sql
ALTER INDEX IX_CustomerTest_Name
ON dbo.CustomerTest
REORGANIZE;
```

- 🏗 B. Rebuild (rakentaa koko indeksin uudelleen)
```sql
ALTER INDEX IX_CustomerTest_Name
ON dbo.CustomerTest
REBUILD WITH (FILLFACTOR = 90);
```
📝 Rebuild on raskas, mutta tehokkaampi, ja se myös päivittää tilastot.

**Kysymykset:**
- Mikä vaikutus fillfactorilla oli päivitysten jälkeen?
- Milloin kannattaa käyttää REORGANIZE ja milloin REBUILD?
- Mikä on fragmentaation ja sivujakautumisen (page split) suhde?
- Miten voisit estää sivujakautumia tuotantoympäristössä?



Palauta vastaukset Moodleen
