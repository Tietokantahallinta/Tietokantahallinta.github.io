# Tilapäiset taulut

Data talletetaan tauluihin ja data säilyy kunnes se poistetaan DELETE-lauseella. Viime viikolla oli kuitenkin muuttujien yhteydessä esimerkkinä Table-tietotyyppi ja lisäksi funktio pystyy palauttamaan taulun, joka käyttäytyy kyselyissä ja muissa lauseissa kuten normaali taulu. Näissä tapauksissa taulua ja sen sisältämää dataa ei enää ole lauseen tai skriptin suorituksen jälkeen. 
Funktio ja Table-muuttuja ovat suhteellisen uusia ominaisuuksia SQL Serverissä eikä ne taivu ihan kaikkiin tilanteisiin. 
Toisinaan on tarvetta tauluille, jotka ovat olemassa pidempään kuin vain yhden skriptin suorituksen ajan, mutta ei kuitenkaan tarvita pysyvästi. Jos oikeudet riittää, voi aivan hyvin luoda uuden taulun, käyttää sitä apurakenteena ja sitten kun ei enää ole käyttöä, poistetaan taulu DROP-komennolla. 
Tämän hyvin perinteisen käyttötavan lisäksi SQL Serverissä voi luoda tilapäisiä tauluja (temp table), jotka poistuvat automaattisesti kun istunto (connection/session) SQL Serveriin päättyy. Lisäksi aputaulujen käyttöön on standardin mukainen CTE (Common Table Expression).

### Miksi tilapäisiä tauluja ylipäätään on olemassa ja miksi niitä käytetään? 

1. monimutkaisten kyselyiden toteuttaminen, temp-tauluihin voi tallentaa välituloksia ja näin yksinkertaistaa logiikkaa, voi parantaa skriptin luettavuutta ja ymmärrettävyyttä. temp-tauluun voi koota dataa monessa eri osassa käsittelyä varten.
2. data erottaminen, käyttäjäkohtainen temp-taulu voi helpottaa datan käsittelyä koska taulun sisällön näkee vain sen luonut käyttäjä
3. suorituskyky, temp-tauluihin voi luoda indeksejä, mikä parantaa suorituskykyä suurilla tietomäärillä – toisin kuin CTE:issä tai taulumuuttujissa
4. datan uudelleenkäyttö, taulu on olemassa koko istunnon ajan 

### Milloin temp-tauluja kannattaa käyttää?

| Tilanne                                      | Käytä temp-taulua?         |
|---------------------------------------------|-----------------------------|
| Monimutkaiset raportit                      | ✅ Kyllä                    |
| Useita vaiheita sisältävät laskennat        | ✅ Kyllä                    |
| Väliaikainen data useaan käyttökertaan      | ✅ Kyllä                    |
| Iso tulosjoukko ja tarve indeksoida         | ✅ Ehdottomasti             |
| Pieni määrä rivejä, käytetään vain kerran   | ❌ Ehkä parempi taulumuuttuja tai CTE |
| Tarvitset tiedon useille käyttäjille        | ❌ Käytä pysyvää taulua tai ✅ globaalia temp-taulua     |

### tyypit
Tilapäisiä tauluja on neljä tyyppiä:
1. käyttäjäkohtainen (Local, #-etuliite nimessä)
2. globaali (Global, näkyy kaikille käyttäjille, ##-etuliite nimessä)
3. table-muuttuja (näkyy vain ko. skriptissä, @-etuliite muuttujassa)
4. CTE (näkyy vain yhden lauseen suorituksen yhteydessä, ei etuliitettä, SQL standardin mukainen toiminto)

Näistä kolme ensin mainittua voidaan tehdä CREATE TABLE-komennolla, tosin Table-muuttujan määrityksessä ei tarvita CREATE-osaa. 
```sql
CREATE TABLE #apu (
    ID INT PRIMARY KEY,
    Data varchar(100),
    Pvm DATETIME
);
INSERT INTO #apu values('tämä', getdate());
INSERT INTO #apu values('TOIMII!', '2025-05-01');
```

Toinen vaihtoehto on käyttää INSERT-komentoa:

```sql
select name, ProductNumber into #osat from Production.Product where color = 'Black';

-- rakenteen selvitys:
exec tempdb.sys.sp_help #osat;
```

Lokaali temp-taulu poistuu automaattisesti istunnon (logout) päättyessä, taulun saa myös poistaa DROP TABLE-komennolla. Tilapäiset taulut tallentuvat tempdb-tietokantaan ja ne näkyvät myös SSMS:n Object Explorerissa.
Globaali temp-taulu, joka tunnistetaan etuliitteestä ##, näkyy kaikille käyttäjille ja poistuu automaattisesti kun taulun luonut käyttäjä on kirjautunut ulos ja viimeinenkin taulua käyttävä skripti on suoritettu loppuun. Myös globaalit taulut tallentuvat tempdb-tietokantaan.

## CTE
Standardin mukainen tapa aputaulurakenteeseen. Syntaksi:

```sql
[ WITH <common_table_expression> [ ,...n ] ]

<common_table_expression>::=
    expression_name [ ( column_name [ ,...n ] ) ]
    AS
    ( CTE_query_definition )
```

Common Table Expression:lla pystyy tekemään taulua vastaavan rakenteen, joka on olemassa lauseen suorituksen ajan. Table-tyyppinen muuttuja on olemassa koko skriptin ajan. CTE:n avulla voidaan vastaavasti pilkkoa monimutkaisia kyselyitä hieman yksinkertaisempaan muotoon ja yksi ominaisuus erottaa CTE:n muista tavoista: sen avulla voi tehdä rekursiivisen kyselyn.

Yksinkertainen esimerkki:
```sql
WITH Pisteet AS -- CTE-taulun nimi on Pisteet
	(SELECT oppilasnro, SUM(suorituspisteet) as Pisteet
	 FROM SUORITUS s JOIN AINE a ON s.ainenro = a.ainenro
	GROUP BY oppilasnro)
SELECT o.sukunimi + ' ' + o.etunimi AS Nimi, p.Pisteet 
FROM OPPILAS o JOIN Pisteet p ON o.oppilasnro = p.oppilasnro; 
;
-- Pisteet taulu käyttäytyy kuten mikä tahansa taulu tai näkymä WITH-lauseen suorituksen ajan
```

### Esimerkki Temp-taululla

```sql
-- Luo temp-taulu
SELECT asiakas_id, SUM(ostot) AS Yhteensa
    INTO #OstosYhteenveto
    FROM Ostot
    GROUP BY asiakas_id;

-- Käytä temp-taulua
SELECT o.asiakas_id, o.Yhteensa, a.nimi
FROM #OstosYhteenveto o
JOIN Asiakkaat a ON o.asiakas_id = a.id;

-- Siivous
DROP TABLE #OstosYhteenveto;

### sama CTE:llä 
```sql
WITH OstosYhteenveto AS (
    SELECT asiakas_id, SUM(ostot) AS Yhteensa
    FROM Ostot
    GROUP BY asiakas_id
)
SELECT o.asiakas_id, o.Yhteensa, a.nimi
    FROM OstosYhteenveto o
    JOIN Asiakkaat a ON o.asiakas_id = a.id;
```

Rekursiivinen rakenne on hieman hankalampi, koetataan esimerkin avulla selventää toimintoa.
Ensin taulu:
```sql
CREATE TABLE Tyontekijat (
    ID INT PRIMARY KEY,
    Nimi NVARCHAR(100),
    EsimiesID INT NULL REFERENCES Tyontekijat(ID)
);

-- Esimerkkidata
INSERT INTO Tyontekijat (ID, Nimi, EsimiesID) VALUES
(1, 'Maija', NULL),       -- Ylin johto
(2, 'Antti', 1),
(3, 'Laura', 1),
(4, 'Pekka', 2),
(5, 'Tiina', 2),
(6, 'Ville', 3),
(7, 'Salla', 4);
```

Sitten tulostetaan organisaation hierarkia:
```sql
WITH AlaisetCTE AS (
    -- aloitetaan esimiehestä
    SELECT
        ID,
        Nimi,
        EsimiesID,
        0 AS Tasotaso
    FROM Tyontekijat
    WHERE EsimiesID is null 

    UNION ALL

    -- Rekursiivinen osa: etsitään alaiset
    SELECT
        t.ID,
        t.Nimi,
        t.EsimiesID,
        c.Tasotaso + 1
    FROM Tyontekijat t
    INNER JOIN AlaisetCTE c ON t.EsimiesID = c.ID
)

SELECT * FROM AlaisetCTE
ORDER BY Tasotaso, Nimi;
```

Haku toiseen suuntaan eli alhaalta ylöspäin:
```sql

WITH Esimiesketju AS (
    -- Aloitetaan työntekijästä
    SELECT
        ID,
        Nimi,
        EsimiesID,
        0 AS Tasotaso
    FROM Tyontekijat
    WHERE Nimi = 'Salla'  -- Aloitustyöntekijä

    UNION ALL

    -- Rekursiivinen osa: haetaan hänen esimiehensä
    SELECT
        t.ID,
        t.Nimi,
        t.EsimiesID,
        e.Tasotaso + 1
    FROM Tyontekijat t
    INNER JOIN Esimiesketju e ON t.ID = e.EsimiesID
)

SELECT * FROM Esimiesketju
ORDER BY Tasotaso;
```



