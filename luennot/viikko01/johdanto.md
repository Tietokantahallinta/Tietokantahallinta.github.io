## Johdanto

SQL Server on pitkään käytössä ollut tietokantapalvelin. Ensimmäinen versio julkaistiin 1989 OS/2 käyttöjärjestelmään. Sen jälkeen on tullut uusia versioita muutaman vuoden välein. Jokaisessa uudessa versiossa on tullut lisää uusia ominaisuuksia sekä tietysti parantunut suoritukyky. Versiohistoriasta kiinnostuneiden kannattaa [lukea](https://sqlserverbuilds.blogspot.com/#google_vignette) versioista, tosin tämä melko täydellinen tietopaketti päättyy versioon 6, aikaisemmista 1.0 (OS/2) ja 4.2 (NT 3.1) versioista ei mainita. 

SQL-kieli on melko vakio, toki murteita on edelleen paljon. Tällä kurssin käytetään Transact SQL-kieltä, tunnetaan myös lyhyemmällä nimellä TSQL. Tietokantojen hallintaan liittyvät toiminnot eivät ole minkään standardin mukaisia, ellei puhuta käyttöoikeuksista ja käyttäjien luomisesta. Hallintaan liittyy paljon välinekohtaisia asioita. Tämän kurssin tiedoilla ymmärrät mitä toimintoja ja toimenpiteitä tehdään tietokannoissa, mutta et osaa tehdä ajastattuja varmistuksia Oraclessa ennen kuin opettelet nippelit Oraclen dokumentaatiosta. Yleisellä tasolla toiminnot on samanlaista, mutta tekninen toteutus taustalla ja komennoissa on aina hieman erilaista eri palvelimilla.

DBA tulee lyhenteenä sanoista Database Administrator. Se on henkilö tai rooli, joka vastaa tietokannan (myös tietokantapalvelimen) hallinnoinnista tietokannan elinkaaren aikana, työnkuvan on siis Database Administration. Tällä kurssilla tutustutaan tyypillisimpiin DBA:n tehtäviin.

#### Tietokannan elikaari
Tietokanta luodaan jonkin tarpeen mukaan datan talletuksen ja käsittelyyn. Tällä kurssilla keskitytään vain OLTP-tietokantoihin ei OLAP-kantoihin jotka ovat enemmän raportointia varten.

Elinkaaseen liittyviä vaiheita ja asioita:

1. tietokannan luonti
2. rakenteiden luonti (taulut, indeksit, näkymät, triggerit, SP:t) 
3. login/user sekä käyttöoikeuksien määritykset
4. varmistuksien suunnittelu ja toteutus (sekä palautukset, pitää kokeilla että onnistuu!)
5. rakenteiden muutokset, lisätaulut, sarakkeiden lisäykset ja muokkaukset
6. mahdolliset import/export -toiminnot
7. tietokannan seuranta ja optimointi
8. uusien versioiden asennus 


### Konesali tai pilvi

Tällä kurssilla käytetään palvelimelle asennettua tietokantapalvelinta ja palvelimia. Siihen liittyy myös laitteiden hallinnointi, käytetäänkö fyysistä konetta vai virtuaalipalvelinta, paljonko levyjä ja minkälaisia on käytettävissä, vikasietoisuus (esim. RAID5), verkko ja sen suojausasetukset, jne. Näitä verkkoon ja laitteistoon liittyviä hallintatoimintoja ei käydä läpi tällä kurssilla.

Pilvi on entistä useammin tietokannan sijoituspaikkana. SQL Serverin voi ottaa käyttöön Azuresta SAAS palveluna tai sen voi asentaa pilveen virtuaalikoneeseen. Pilvessä osa hallintatoimista muuttuu tai ei voi edes tehdä, esimerkiksi fyysisten levyjen sijasta maksetaan vain tilankäytöstä ja toisaalta taas on helppo lisätä koneen tehoja ottamalla käyttöön 'nappia painamalla' lisää ytimiä ja keskusmuistia. Ja kaikki maksaa eli pilvessä  tulee mukaan kustannuslaskelmat ihan eri tavalla kuin perinteisessä konesaliasennuksessa. 