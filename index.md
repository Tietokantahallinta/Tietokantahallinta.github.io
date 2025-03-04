# Tietokantahallinta (dba)

[ Tervetuloa ](./index.md) &nbsp;&nbsp; [Viikko 01](./luennot/viikko01/index.md) &nbsp;&nbsp; [Viikko 02](./luennot/viikko02/index.md) &nbsp;&nbsp; [Viikko 03](./luennot/viikko03/index.md) &nbsp;&nbsp; [Viikko 04](./luennot/viikko04/index.md) &nbsp;&nbsp; [Viikko 05](./luennot/viikko05/index.md) &nbsp;&nbsp; [Viikko 06](./luennot/viikko06/index.md) &nbsp;&nbsp; [Viikko 07](./luennot/viikko07/index.md) &nbsp;&nbsp; [Viikko 08](./luennot/viikko08/index.md) 

Tervetuloa kurssille.

Sisältö:  

- Tietokantojen elikaari
- Tietokantapalvelimen asennus, rakenne, toiminta ja sen tarjoamat palvelut
- Systeemitietokannat: master, tempdb, msdb ja model
- Tietokantapalvelimen asennus ja konfigurointi, käynnistykseen liittyvät tiedot
- Tietokannan luonti ja konfigurointi
- Taulujen luonti, pääavaimet, ulkoiset viite-eheysavaimet sekä ulkoinen indeksien luonti hakujen nopeuttamiseksi ja eheytys
- Käyttäjätunnukset, oikeudet, käyttäjäryhmät (roolit)
- Roolien oikeudet tietokantoihin ja tauluihin ja sql-komentoihin
- Tietoturva, tietokantojen suojaus
- Transaktiot ja niihin liittyvät ongelmatilanteet ja selviäminen
- Varmistustenteko ja niiden palauttaminen (backup, restore)
- Disaster Recovery: 
- taulun eheyttäminen ja seuranta 
- indeksien eheyttäminen ja seuranta
- SQL Query Optimization
- Tietokantapalvelimen ylläpitäjän tehtävät ja automatisointi
- Tallennetut proseduurit automatisoinnissa ja laajemmin.

``` sql
SELECT * 
    FROM Asiakas
    WHERE id > 10;
```
Siinäpä yksi esimerkki

1. Tietokantapalvelimen asennus, systeemitietokannat
2. Konfigurointi, verkkoasetukset
3. Tietokannan luonti, kryptaukset
4. Taulujen luonti (ja muut objektit, näkymät ohjelmarakenteet)
5. Käyttäjät (login/user)
6. Käyttöoikeudet
7. Varmistukset
8. Käyttöönotto
9. Ylläpito, uudet taulut, taulujen päivitykset
10. Mahdolliset import/export -toiminnot
11. Suorituskyvyn optimointi (mm. indeksit)
12. Tietokannan siirto

Muita asioita näiden lisäksi:
- ohjelmarakenteet (trigger, stored proc, function)
- vaativat SQL-komennot
- temp-taulut
- rakenteiden muutokset
- lokitus

