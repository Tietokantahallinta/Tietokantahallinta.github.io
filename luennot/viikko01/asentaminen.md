# Asentaminen

SQL Serveistä on olemassa monta erilaista versiota, tällä kurssilla käytetään Developer Edition:ia, se on oikea tietokantapalvelin ja sitä saa käyttää kehitys ja testauskäytössä.

Tietokantapalvelimen asennus:
[Microsoft SQL Server asennus](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)

Hallintatyökalu: 
[Microsoft SQL Server Management Studio, SSMS ](https://learn.microsoft.com/en-us/ssms/download-sql-server-management-studio-ssms)

Vaihtoehto SSMS:lle:
[Azure Data Studio](https://learn.microsoft.com/en-us/azure-data-studio/download-azure-data-studio?tabs=win-install%2Cwin-user-install%2Credhat-install%2Cwindows-uninstall%2Credhat-uninstall)

Asennusjärjestys on yksinkertainen, ensin kannattaa asentaa Tietokantapalvelin ja vasta sitten muut tarvittavat ohjelmistot (SSMS, ADT).

Tällä kurssilla jokainen asentaa SQL Serverin omalle koneelle, asennus vaatii admin-oikeudet. Asennuksen voi tehdä yleensä oletusasetuksilla, mutta on hyvä tietää mitä vaihtoehtoja on asennuksessa ja mihin ne vaikuttaa.

### Asennuksen vaiheet:

Asennusohjeet löytyy täältä: [asennusohje](https://learn.microsoft.com/en-us/sql/database-engine/install-windows/install-sql-server?view=sql-server-ver16)

Katsotaan kuitenkin asennuksen vaiheet yksi kerrallaan täältä: [step-by-step](https://www.csharp.com/article/step-by-step-installation-of-microsoft-sql-server-on-windows-system/) tai täältä [installation guide](https://www.visual-expert.com/EN/visual-expert-documentation/install-and-configure-visual-expert/sql-server-2019-installation-guide-visual-expert.html), näiden sivujen kautta pääsee tutustumaan asennusohjelman vaiheisiin ja asetuksiin, joten niitä voi selvitellä jo etukäteen. 
Tunnilla käydään koko asennus vaiheittain läpi selityksineen.

Oletuksena asennus onnistuu. Jos jotain outoa tapahtuu asennuksessa, koetetaan vikoja selvitellä tunnin aikana tai jälkikäteen Teamsin kautta.

Samaan palvelimeen (ja samalle työasemalle) voi asentaa useita SQL Server:eitä. Ensimmäinen on ns. oletusinstanssi, jolla ei ole nimeä. Muut asennukset ovat nimettyjä instansseja ja kirjautumisessa palvelimen nimeen lisätään instanssin nimi. Tällä kurssilla riittää yksi asennettu instanssi.

SQL Server tietokantainstanssi pystyy käsittelemään montaa tietokantaa, siksi ei ole kovin usein edes tarvetta asentaa montaa instanssia samalle koneelle.

### Tietokantapalvelimen käynnistys ja kirjatumistiedot.

SQL Server, kuten muutkin tietokantapalvelimet, on taustaprosessi, jolla ei ole käyttöliittymää. Sitä hallinnoidaan Services-toiminnon kautta (Palvelut, suomenkielisessä versiossa): käynnistys, sammutus, millä tunnuksella suoritetaan jne. 

Asennuksen jälkeen käynnistä Services (⊞ ja kirjoita Services), etsi SQL Server (MSSQLSERVER). Sarakkeilta löydät tilan (Status), käynnistystavan (Startup type) sekä käyttäjän, jonka oikeuksilla palvelin toimii (Log On As). Napauta riviä hiiren oikeanpuoleisella painikkeella ==> käynnistytoiminnot ja ominaisuudet (Properties). Valitse Properties (tai ominaisuudet) ja tutustu avautuvan ikkunan välilehdillä oleviin asetuksiin.

Tietokantapalvelimen ohella asentuu myös muita sovelluksia, esimerkiksi *SQL Server Profiler*, johon tutustutaan kurssin aikana sekä **SQL Server Configuration Manager**.

Configuration Managerilla voit myös hallita palvelinta käynnistysten osalta. Sen lisäksi tällä sovelluksella voit määritellä mitkä kommunikointiprotokollat ovat käytössä (Shared Memory, Named Pipes, TCP/IP). Jaettu muisti on oletuksena paikallisessa kommunoikoinnissa ollen myös nopein. Nimetyt putket ovat jo historian havinaa, verkossa liikennöidessä käytetään TCP/IP:tä. Nimetty putki voi olla tarpeen jokin todella vanhan client-kirjaston käytön yhteydessä. 

### SSMS ja ADT 
Näiden asennus menee oletusarvoilla. Asennuksen jälkeen onkin vuorossa tarkistus, että tietokantapalvelimeen pääset tietokantaan kiinni SSMS:llä.

SQL Serverin asennuksessa koneelle asentuu myös osql ja **SQLCMD**, nämä ovat komentorivipohjaisia hallintatyökaluja. Käynnistä komentotulkki (Command prompt) ja anna komento:
```code
SQLCMD -?
```
Saat listan komentoriviparametetreistä, joilla komentoa ohjataan. Jos (kun) tarvitset ajaa SQL-komentoja tietokantapalvelimelle ilman SSMS:n käyttöä, esimerkiksi jos ajastat toimintoja, on SQLCMD enemmän kuin tärkeä sovellus. Opettele SQLCMD:n peruskäyttö.

**OSQL** on vastaava sovellus, mutta tehty hieman vanhemmalla tekniikalla ja tietokantaan kytkeytymiskirjastoilla. Saa käyttöö, mutta suosituksena on SQLCMD. Jossain saatat vielä törmätä sovellukseen isql, sekin vastaa SQLCMD:tä, mutta pohjautuu erittäin vanhaan tekniikkaan, eikä edes asennu SQL Serverin mukana enää nykyään.

## Tietokantapalvelimen asetukset
Nyt SQL Server ja hallintatyökalut on asennettu, voidaan siis tutkia mitä asetuksia on säädettävissä.

Käynnistä SSMS ja kirjaudu sisään. Kirjautumisessa tarvitset palvelimen nimen (oman koneen nimi tai localhost). Koneen nimen saat selville montakin kautta, esimerkiksi komentotulkissa komennolla *systeminfo* tai käyttöliittymän kautta *System Information* -sovelluksella.

Kirjautumisessa pitää myös määritellä käytetäänkö SQL Server-tunnusta vai Windows (AD, Entra)-tunnusta. Uusin SSMS vaatii myös tiedon liikennöintikäytäntöön liittyvästä suojauksesta, valitse Optional. Windows Authentication käyttää kirjautuneen käyttäjän tietoja ja salasanaa, SQL Server-tunnus vaatii tunnuksen nimen ja validin salasanan. Kirjautumistunnuksista ja kirjautumisesta lisää tuonnempana.

Kirjautumisen jälkeen valitse Object Explorerissa palvelimen päällä hiiren oikealla valikko ja sieltä valitse **Properties**.

![Server properties](..\kuvat\ServerProperties.jpg)

Nämä asetukset ovat muutettavissa käyttöliittymän kautta tai TSQL-komennoilla, aiheesta lisää [täällä](https://learn.microsoft.com/en-us/sql/database-engine/configure-windows/view-or-change-server-properties-sql-server?view=sql-server-ver16). 

Tunnilla käydään osa asetuksista läpi, lähinnä niitä joita yleisimmin pitää säätää vai muuten parantaa toiminnan ymmärtämistä.

