# Azure SQL - tietokanta pilvipalvelussa

# Johdatus Azure SQL:ään

## Mikä on Azure?

Azure on Microsoftin tarjoama pilvipalvelualusta, joka tarjoaa laajan valikoiman palveluita sovellusten rakentamiseen, käyttämiseen ja hallintaan maailmanlaajuisessa verkossa sijaitsevissa datakeskuksissa. Azure mahdollistaa mm. palvelimettoman laskennan, sovelluskehityksen, tietovarastoinnin, tekoälyn käytön sekä relaatiotietokantojen ajamisen pilvessä.

---

## Tietokantavaihtoehdot Azure-ympäristössä

Azure tarjoaa useita vaihtoehtoja SQL Serverin ja muiden tietokantojen käyttöön:

### 1. **Azure SQL Database**
- *Platform as a Service (PaaS)*-ratkaisu
- Hallinnoitu tietokanta, joka skaalautuu automaattisesti
- Ei tarvitse huolehtia päivityksistä tai infrastruktuurista
- Soveltuu uusille sovelluksille ja SaaS-palveluille

### 2. **Azure SQL Managed Instance**
- Myös PaaS, mutta tarjoaa laajemman yhteensopivuuden paikallisen SQL Serverin kanssa
- Tuki SQL Server Agentille, DB Mailille, linked servereille jne.
- Hyvä vaihtoehto, kun halutaan nostaa olemassa oleva SQL Server pilveen mahdollisimman vähin muutoksin

### 3. **SQL Server on Azure Virtual Machines**
- *Infrastructure as a Service (IaaS)*-ratkaisu
- Täysi hallinta SQL Server -instanssiin, aivan kuten omassa konesalissa
- Hyvä valinta, kun vaaditaan erityistä räätälöintiä tai tiettyjä ominaisuuksia, joita PaaS ei tue

---

## Olemassa olevan tietokannan siirto Azureen

Tietokannan siirtoon on useita vaihtoehtoja:

### Vaihtoehdot:
- **Data Migration Assistant (DMA)**: analysoi yhteensopivuuden ja auttaa siirrossa
- **Azure Database Migration Service (DMS)**: automaattinen migraatiotyökalu, tukee myös jatkuvaa replikointia
- **BACPAC-tiedostot**: vienti ja tuonti tiedostojen avulla
- **Transactional Replication**: mahdollistaa tietojen kopioinnin pilveen lähes reaaliajassa

### Huomioitavaa:
- Yhteensopivuus: tarkista SQL-versioiden yhteensopivuus ja tuetut ominaisuudet
- Sovellusyhteydet: varmista, että sovellus osaa käyttää pilvipalvelua (palomuuri, connection string, autentikointi)
- Suorituskykytestit ja latenssi: pilviympäristö ei aina käyttäydy kuten oma konesali

---

## Hallinnointi ja varmistukset: Azure vs. oma konesali

| Ominaisuus    | Azure SQL Database                                        | Paikallinen SQL Server (oma konesali)             |
|---------------|-----------------------------------------------------------|---------------------------------------------------|
| Ylläpito      | Microsoft huolehtii päivityksistä ja käyttöjärjestelmästä | Käyttäjä vastaa kaikesta                          |
| Skaalautuvuus | Dynaaminen, voidaan säätää kuormituksen mukaan            | Manuaalinen resurssien lisäys                     |
| Varmistukset  | Automaattiset, jopa PITR (Point-in-Time Restore)          | Manuaaliset tai skriptatut                        |
| Saatavuus     | Sisäänrakennettu korkea saatavuus                         | Vaatii konfiguraatiota ja lisenssejä              |
| Monitorointi  | Azure Monitor, Query Performance Insight                  | SQL Server Management Studio, 3rd party -työkalut |

---

## Hinnoittelu

Azure SQL -palveluiden hinnoittelu perustuu useisiin tekijöihin:

### 1. **Hinnoittelumallit**
- DTU (Database Transaction Unit) – vanhempi malli pienille ympäristöille
- vCore – joustavampi, laskutus erikseen prosessorista, muistista ja tallennuksesta
- Provisioned vs. Serverless – maksatko koko ajan (provisioned) vai vain käytöstä (serverless)

### 2. **Skaalautuvuus**
- Voit määrittää kapasiteetin tarpeen mukaan tai käyttää automaattista skaalausta
- skaalautuminen helpompaa verrattuna omaan konesaliin (prosessit, muisti, levytila)

### 3. **Lisäkulut**
- Tallennustila, varmuuskopiot, liikennöinti (etenkin ulosmenoliikenne)
- Lisensointi: voit käyttää omaa SQL-lisenssiäsi (Azure Hybrid Benefit)

### Hintalaskuri:
- [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/) auttaa arvioimaan kustannuksia eri vaihtoehdoilla

---

## Yhteenveto

Azure SQL tarjoaa joustavan ja hallitun tavan käyttää relaatiotietokantoja pilvessä. Valittavissa on eri palvelumalleja tarpeen mukaan – kevyistä, täysin hallituista ratkaisuista aina täyteen kontrolliin IaaS-muodossa. Siirtymä vaatii suunnittelua, mutta tuo merkittäviä hyötyjä ylläpidon helppouden, saatavuuden ja skaalautuvuuden osalta.

