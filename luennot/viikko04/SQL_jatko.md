# Lisää hyödyllisiä SQL-komentoja

## CUBE ja ROLLUP

Tietokannasta voidaan laskea aggregaattifunktiolla erilaisia arvoja, nämä funktiot palauttavat yhden arvon. Ryhmittelyn (GROUP BY) avulla saadaan laskenta tehtyä haluttujen kriteerien perusteella. Tälloin jää kuitenkin kokonaistulokset saamatta eli esimerkiksi jos ryhmitellää tuotteet tuotetyypin perusteella montako tuotetta on mitäkin tuotetyyppiä, saadaan toki tyyppeittäin lukumäärät mutta ei kokonaismäärää. Tähän ratkaisuna voi käyttää lisämääreitä ROLLUP ja CUBE, jotka osaavat laskea välituloksia ja lopullisia summia. Esimerkki ehkä kertoo paremmin mistä on kysymys:

```sql
-- perinteinen tuttu ja turvallinen ryhmittely
SELECT postitmp, count(*)  FROM oppilas
GROUP BY postitmp;

-- kokonaissumma mukana, NULL kertoo tässä tapauksessa paljon!
SELECT postitmp, count(*)  FROM oppilas
GROUP BY CUBE(postitmp);

-- hieman tuloksen hienosäätöä
SELECT COALESCE(postitmp, 'Yhteensä'), count(*)  FROM oppilas
GROUP BY CUBE(postitmp);

-- ei juurikaan eroa CUDE:sta
SELECT postitmp, count(*)  FROM oppilas
GROUP BY ROLLUP(postitmp);

SELECT postitmp, sukupuoli, count(*)  FROM oppilas
GROUP BY CUBE (postitmp, sukupuoli);

-- mutta nyt saadaan jo toimintalogiikkaero edelliseen nähden
SELECT postitmp, sukupuoli, count(*) AS Lkm  FROM oppilas
GROUP BY ROLLUP (postitmp, sukupuoli);
```

## INSERT + UPDATE == MERGE

Sovelluslogiikassa aika usein joudutaan tilanteeseen, jossa tietokantaan pitää lisätä rivi tai jos jo kyseinen rivi (PK, tai muu tunnistetieto) on taulussa, pitää sen arvoja päivittää. Koodaajat käyttävät tästä termiä UPSERT (UPdate + inSERT), tämä ei ole mikään virallinen termi.
SQL-kielellä tämä logiikka piti alunpitäen tehtä ohjelmallisikka rakenteilla ja tyypillisesti vieläpä kursoria käyttäen. Onneksi on käytössä MERGE-toiminto, joka helpottaa loogisen UPSERT-toiminnon toteuttamista.

Merge-komennon [syntaksi](https://learn.microsoft.com/en-us/sql/t-sql/statements/merge-transact-sql?view=sql-server-ver16) ei ole lyhyt, joten ehkä esimerkin avulla on helpompi selittää ja esittää miten MERGE toimii.

🎯 Tavoite
Päivitetään Asiakkaat-taulua uusien tietojen mukaan, joita tulee UudetAsiakkaat-taulusta:
- Jos asiakkaan ID löytyy jo, päivitä nimi ja sähköposti
- Jos ei löydy, lisää uutena
- (Valinnainen: Poista asiakkaat, joita ei ole enää UudetAsiakkaat-taulussa)

Ensin demotaulut:
```sql
CREATE TABLE Asiakkaat (
    AsiakasID INT PRIMARY KEY,
    Nimi NVARCHAR(100),
    Sähköposti NVARCHAR(100)
);

CREATE TABLE UudetAsiakkaat (
    AsiakasID INT,
    Nimi NVARCHAR(100),
    Sähköposti NVARCHAR(100)
);

-- Alkuperäisiä asiakkaita
INSERT INTO Asiakkaat VALUES
(1, 'Matti Meikäläinen', 'matti@example.com'),
(2, 'Liisa Virtanen', 'liisa@example.com');

-- Uusia tietoja
INSERT INTO UudetAsiakkaat VALUES
(1, 'Matti Meikäläinen', 'matti@uusi.fi'),  -- Sähköposti muuttunut
(3, 'Kalle Jokinen', 'kalle@example.com');  -- Uusi asiakas
```

Ja sitten esimerkki MERGE-komennosta: 
```sql
MERGE INTO Asiakkaat AS Kohde
USING UudetAsiakkaat AS Lahde
ON Kohde.AsiakasID = Lahde.AsiakasID

WHEN MATCHED THEN
    UPDATE SET
        Kohde.Nimi = Lahde.Nimi,
        Kohde.Sähköposti = Lahde.Sähköposti

WHEN NOT MATCHED BY TARGET THEN
    INSERT (AsiakasID, Nimi, Sähköposti)
    VALUES (Lahde.AsiakasID, Lahde.Nimi, Lahde.Sähköposti);

 -- myös poisto olisi mahdollista, ei tehdä tässä
 --WHEN NOT MATCHED BY SOURCE THEN
 --    DELETE;


-- tarkistetaan tilanne päivityksen jälkeen
select * from Asiakkaat;
select * from UudetAsiakkaat;
delete from uudetasiakkaat;  -- näitä turkin tarvitsee enää
```
### 🧾 Lopputulos
Taulussa Asiakkaat tapahtuu:
- Matti saa uuden sähköpostin
- Kalle lisätään uutena
- Liisa jää ennalleen (jos DELETE-ehtoa ei ole)


## STRING_AGG ja COALESCE

Joskus on tarve muuttaa data rivin sarakkeista yhdeksi ainoaksi arvoksi. Siihen voi käyttää STRING_AGG tai COALESCE -funktioita. STRING_AGG on SQL Serverin oma erikoisfunktio (versiosta 2017 lähtien) ja COALESCE on SQL-stadardissa ja sen avulla voidaan korvata null-arvoja. 
Esimerkki:

```sql
SELECT nimi, sukunimi + ' ' + etunimi AS Vastuuopettaja,
	(SELECT STRING_AGG(Sukunimi +' '+ etunimi, ', ') from opettaja po where po.opettajanro 
		in (select opettajanro from KURSSI k where k.ainenro = a.ainenro ))
FROM AINE a JOIN OPETTAJA o ON a.vastuuopettaja = o.opettajanro;
```

Ja sama COALESCE:n avulla:
```sql
SELECT 
    nimi, 
    sukunimi + ' ' + etunimi AS Vastuuopettaja,
    (
        SELECT 
            COALESCE(
                STUFF((
                    SELECT ', ' + po.Sukunimi + ' ' + po.Etunimi
                    FROM OPETTAJA po
                    WHERE po.opettajanro IN (
                        SELECT opettajanro FROM KURSSI k WHERE k.ainenro = a.ainenro
                    )
                    FOR XML PATH(''), TYPE
                ).value('.', 'NVARCHAR(MAX)'), 1, 2, ''), '')
    ) AS KaikkiOpettajat
FROM AINE a 
JOIN OPETTAJA o ON a.vastuuopettaja = o.opettajanro;
```

Ehkä yksinkertaisempi esimerkki selventää asiaa ja näiden kahden komennon välistä eroa:
```sq

SELECT STRING_AGG(nimi, ' ') from AINE; 

-- sama coalescellä:
DECLARE @aineet NVARCHAR(MAX) = '';
SELECT @aineet = COALESCE(@aineet + ' ', '') + nimi FROM AINE;
SELECT @aineet AS KaikkiNimet;
```


## 🔧 Hyödyllisiä ja edistyneitä T-SQL-komentoja SQL Serverissä

Tässä kokoelma tehokkaita ja hyödyllisiä T-SQL-ominaisuuksia, jotka täydentävät `MERGE`, `CTE` ja `STRING_AGG` -osaamista.

## 🚀 Keskitason ja edistyneen tason T-SQL-komentoja ja -ominaisuuksia

| Komento / Ominaisuus     | Kuvaus |
|--------------------------|--------|
| **`WINDOW FUNCTIONS`** (OVER, ROW_NUMBER, RANK, etc.) | Suorita laskentoja riveittäin ilman ryhmittelyä – erittäin hyödyllisiä esimerkiksi top-listoihin, järjestyksiin, vertailuihin. |
| **`PIVOT` ja `UNPIVOT`** | Taulun rivien ja sarakkeiden välinen muuntaminen – hyvä raportoinnissa. |
| **`APPLY` (CROSS APPLY, OUTER APPLY)** | Käytetään liittymään taulufunktioihin tai aliin (subqueryihin) – ikään kuin liittymä alitauluun rivikohtaisesti. |
| **`TRY_CAST`, `TRY_CONVERT`** | Turvallinen tapa muuntaa tietotyyppejä ilman virheilmoituksia – antaa `NULL` epäonnistumisessa. |
| **`IIF`** | Lyhytmuotoinen `CASE`-lause – esim. `IIF(arvo > 100, 'Korkea', 'Matala')`. |
| **`FORMAT`** | Ihmislukijalle suunnattu päivämäärien ja numeroiden muotoilu, esim. eurot, päivämäärät. |
| **`EXCEPT` ja `INTERSECT`** | Sarjojen välinen vertailu: `EXCEPT` palauttaa A:n miinus B:n, `INTERSECT` yhteiset. |
| **`SEQUENCE`** | Kehittyneempi tapa generoida numeroita kuin `IDENTITY` – joustavampi ja hallittavampi. |
| **`JSON`-toiminnot (`OPENJSON`, `FOR JSON`)** | T-SQL tukee JSON-tietojen purkua ja muotoilua, erittäin hyödyllistä kun sarake sisältää dataa JSON-muodossa. |
| **`TRY...CATCH`** | Virheenkäsittely, edellisellä viikolla käsitelty aihe. |
| **`WAITFOR`** | Voit viivyttää komennon suorittamista sekunneilla tai kellonajalla – esim. testaukseen tai ajastamiseen. |
| **`CURSOR`** | Rivi riviltä tapahtuva käsittely – hitaampi ja usein vältettävä, mutta joskus tarpeellinen. |
| **`WITH (NOLOCK)`** | Luku ilman lukituksia – tuo suorituskykyä, mutta voi aiheuttaa likaisia lukuja (DIRTY READ, käsitellään tapahtumahallinnan yhdeydessä). Käytä harkiten! |

---

## Esimerkkejä

###  ROW_NUMBER() – Esimerkiksi top 3 per ryhmä:

```sql
WITH Järjestys AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY Ainenro ORDER BY Arvosana DESC) AS Rivi
    FROM Suoritus
)
SELECT * FROM Järjestys WHERE Rivi <= 3;
```

---

### PIVOT

```sql
use AdventureWorks2012;

SELECT * FROM (
    SELECT month(startdate) as KK, productid, orderqty FROM Production.WorkOrder
) AS wo
PIVOT (
    SUM(orderqty) FOR KK IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
) AS pivottaulu;
```

### CROSS APPLY
Kaksi parasta arvosanaa jokaiselle opiskelijalle:
```sql
SELECT o.sukunimi, (select nimi from aine where aine.ainenro = a.ainenro) as kurssi , a.arvosana
FROM OPPILAS o
CROSS APPLY (
    SELECT TOP 2 ainenro, arvosana
    FROM SUORITUS s
    WHERE s.oppilasnro = o.oppilasnro
    ORDER BY arvosana DESC
) a;

-- kokeile OUTER APPLY ==> myös ne oppilaat joilla ei ole suoritusta. Vrt OUTER/INNER JOIN
```

### IIF
```sql
SELECT oppilasnro, ainenro, arvosana,
       IIF(arvosana >= 5, 'Erinomainen',
       IIF(arvosana >= 3, 'Hyvä',
       IIF(arvosana >= 1, 'Läpi',
       'Hylätty'))) AS arvio
FROM SUORITUS;```

### FORMAT
```sql
'' päivämäärä
SELECT 
    FORMAT(GETDATE(), 'dd.MM.yyyy') AS Paivays,
    FORMAT(GETDATE(), 'dddd', 'fi-FI') AS Viikonpaiva;

-- luku ==> valuutta
SELECT FORMAT(12345.67, 'C', 'fi-FI') AS Eurot;

-- luku selkokielisenä
SELECT FORMAT(12345.6789, 'N2') AS Muotoiltu;
SELECT FORMAT(12345.6789, 'N2', 'FI') AS Muotoiltu;
```

**FORMAT** ja käyttötarkoitukset

| Käyttötilanne        | Miksi hyvä?                                |
|----------------------|---------------------------------------------|
| Raportointi          | Päivämäärät ja summat selkokielelle        |
| Kieliversiointi      | Sama data eri kulttuurimuodoilla            |
| Näyttömuotoilu       | Vältetään sovelluspuolen käsittely          |
| Datan esikatselu     | SQL-tulokset valmiiksi ihmisen luettavaksi |

---
