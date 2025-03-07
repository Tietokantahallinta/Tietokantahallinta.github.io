## Systeemitietokannat

Asennuksen jälkeen SQL Server sisältää jo valmiiksi joukon tietokantoja, jotka ovat ns. systeemitietokantoja ja niitä ei ole tarkoitus käyttää suoraan. Systeemitietokannoissa on tieto mm. login-tunnuksista, tietokannoista, ajastuksista jne. 
Systeemitietokantoja ovat:

1. master
2. model
3. msdb
4. tempdb

### master
master-tietokanta sisältää kaikki järjestelmätasoiset tiedot SQL Serverin osalta. Esimerkiksi login-tiedot, mitä tietokantoja on olemassa, mikä versio ja yhteensopivuustaso joitakin mainittuna.

### msdb 
msdb-tietokannassa on Job-objetit ja niiden ajastukset. Lisäksi tässä tietokannassa on uusien tietokantojen oletusasetukset. 

### model
model-tietokanta on template luotaville tietokannoille. Kun tämän tietokannan asetuksia muuttaa, vaikuttaa se tämän jälkeen luotavien tietokantojen oletusasetuksiin.

### Resource
Sisältää objektit jotka näkyvät sys-skemassa jokaisessa tietokannassa. Tämä tietokanta ei näy SSMS:n Object Explorerissa

### tempdb
Tilapäisten objektien talletuspaikka. Esimerkiksi jos käyttäjä tekee taulun, jonka nimi alkaa #-merkillä, tallentuu taulu ja data tähän tietokantaan ja häviää automaattisesti kun käyttäjä kirjautuu ulos tietokannasta.

Systeemitietokannoista kannattaa ja pitää varmistaa (backup) master, msdb ja model. Varmistuksista ja palautuksista (restore) lisää kurssin aikana. 
