## Systeemitietokannat

Asennuksen jälkeen SQL Server sisältää jo valmiiksi joukon tietokantoja, jotka ovat ns. systeemitietokantoja ja niitä ei ole tarkoitus käyttää suoraan. Systeemitietokannoissa on tieto mm. login-tunnuksista, tietokannoista, ajastuksista jne. Käyttäjän tietokannat (User databases) sisältävät varsinaisen tuotannollisen datan.

Systeemitietokantoja ovat:

1. master
2. model
3. msdb
4. tempdb

### master
master-tietokanta sisältää kaikki järjestelmätasoiset tiedot SQL Serverin osalta. Esimerkiksi login-tiedot, asennetut tietokannat sekä konfigurointitiedot. Master-kanta pitää tuotantoympäristössä varmistaa kuten käyttäjän tietokannat. Muutoin katastrofitilanteessa voi käyttäjän tietokannan palauttaminen olla varsin työläs tehtävä pahimmassa tapauksessa.

### msdb 
msdb-tietokannassa on Job-objetit ja niiden ajastukset. Lisäksi tässä tietokannassa on uusien tietokantojen oletusasetukset, sekä tiedot kaikkien käyttäjän tietokantojen varmistuksista. Seurantaan liittyvät hälytykset ovat talletettu tähän tietokantaan. Pitää varmistaa ajoittain. 

### model
model-tietokanta on template luotaville tietokannoille. Kun tämän tietokannan asetuksia muuttaa, vaikuttaa se tämän jälkeen luotavien tietokantojen oletusasetuksiin. Muutosten jälkeen otettava varmistus.

### Resource
Sisältää objektit jotka näkyvät sys-skemassa jokaisessa tietokannassa. Tämä tietokanta ei näy SSMS:n Object Explorerissa eli on piilotettu. Ei sisällä dataa eikä voi varmistaa, ei myöskään ole tarvetta varmistusten ottamiselle. Resurssikannasta löytyy erilaisia asetuksia esimerkiksi:

```SQL
-- palvelimen versionumero
SELECT SERVERPROPERTY('ResourceVersion');
-- viimeinen palvelimen päivitys
SELECT SERVERPROPERTY('ResourceLastUpdateDateTime');
```

### tempdb
Tilapäisten objektien talletuspaikka ja on kaikkien käyttäjien ja tietokantojen käytössä. Esimerkiksi jos käyttäjä tekee taulun, jonka nimi alkaa #-merkillä, tallentuu taulu ja data tähän tietokantaan ja häviää automaattisesti kun käyttäjä kirjautuu ulos tietokannasta. Tietokantapalvelin käyttää tätä tietokantaa silloin, kun pitää tehdä tilapäisiä työtauluja komentojen prosessointiin esimerkiksi *GROUP BY* tai *ORDER BY* -kyselyissä. 
Ei tarvitse eikä voi varmistaa (backup).

Systeemitietokannoista kannattaa ja pitää varmistaa (backup) master, msdb ja model. Varmistuksista ja palautuksista (restore) lisää kurssin aikana. 
