# Tiedon suojaaminen

Data on syytä suojata käyttöoikeuksien hallinnalla ja muilla tietoturvaan liittyvillä toimilla, esimerkiksi palomuuri- ja muut verkkoasetukset. Näiden lisäksi tieto voidaan sala kryptaamalla. Tiedon suojaamiseen kryptausta käyttämällä löytyy valmiina SQL Serverisä neljä erilaista tapaa:
1. Transparent Data Encryption (TDE)
2. Column-Level Encryption (CLE)
3. Always Encrypted
4. Backup Encryption


## TDE
Näillä kaikilla on erilaisia ominaisuuksia ja käyttötarkoituksia. Aloitetaan ensimmäisestä (**TDE**), jolla suojataan tietokantatiedostot (sekä data- että lokitiedostot) sekä varmuuskopiot. Jos TDE ei ole käytössä ja tietokantatiedostot vuotavat jotenkin ulkopuoliselle taholle, pystyy eri työkaluilla lukemaan tietokantatiedoston sisältä kaiken datan (DEMO). Jotta tämä riski vältetään, voidaan käyttää TDE:tä. EU:ssa käytössä oleva GDPR taitaa jopa määrätä että tietokantatiedostot on kryptattava.
Silloin kun tietokanta on käytössä, pitää SQL Server tiedostot lukittuna ja niitä ei pääse lukemaan ohi tietokantapalvelimen. Jos palvelimen ajaa alas, on tietokanta luettavissa eri työkaluilla. Lisää tietoa [TDE:stä](https://learn.microsoft.com/en-us/sql/relational-databases/security/encryption/transparent-data-encryption?view=sql-server-ver16) löytyy Learn-sivukstolta.
Lyhyesti vaiheet miten TDE-suojaus tapahtuu: 

```sql
-- siirrytään master-kantaan
USE MASTER;
-- 1. Luo master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'VahvaSalasana123!';

-- 2. Luo sertifikaatti
CREATE CERTIFICATE TDE_Certificate WITH SUBJECT = 'TDE Sertifikaatti';
GO

-- 3. Luo salausavain ja ota TDE käyttöön
USE SalattavaDB;
GO
CREATE DATABASE ENCRYPTION KEY
    WITH ALGORITHM = AES_256
    ENCRYPTION BY SERVER CERTIFICATE TDE_Certificate;
GO
-- 4. Ota kryptaus käyttöön tietokannassa
ALTER DATABASE SalattavaDB
    SET ENCRYPTION ON;
```
Tämän toimenpidesarjan jälkeen tietokantatiedostot ovat kryptattu, eikä niistä saa mitään tietoa luettue millään työkalulla. Salaaminen ja purkaminen tapahtuu täysin automaattisesti, eikä se näy sovellustasolle lainkaan. 

### Column-Level Encryption ([CLE](https://learn.microsoft.com/en-us/sql/relational-databases/security/encryption/encrypt-a-column-of-data?view=sql-server-ver16))

CLE:llä voi suojata yksittäisiä sarakkeita, esim. henkilötunnukset, luottokorttinumerot ja muut vastaavat tiedot.
Vaatii enemmän työtä kuin TDE, ja Vaatii usein muutoksia sovelluskoodiin, koska data pitää kryptata ja dekryptata eksplisiittisesti.

Esimerkki:
```sql
-- Luo master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'ToinenVahvaSalasana!';

-- Luo sertifikaatti
CREATE CERTIFICATE ColumnCert
    WITH SUBJECT = 'Sarakekryptaus Sertifikaatti';

-- Luo symmetrinen avain
CREATE SYMMETRIC KEY ColumnKey
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE ColumnCert;

-- Käytä avainta kryptaukseen
OPEN SYMMETRIC KEY ColumnKey DECRYPTION BY CERTIFICATE ColumnCert;

-- Kryptaa dataa
UPDATE Asiakas SET Henkilotunnus = ENCRYPTBYKEY(KEY_GUID('ColumnKey'), '123456-7890') WHERE AsiakasID = 4242;

-- Dekryptaa dataa
SELECT CONVERT(varchar, DECRYPTBYKEY(Henkilotunnus)) AS Henkilotunnus
FROM Asiakas;
```

### [Always Encrypted](https://learn.microsoft.com/en-us/sql/relational-databases/security/encryption/always-encrypted-database-engine?view=sql-server-ver16)
Estää edes tietokannan ylläpitäjiä näkemästä arkaluontoista dataa. Salaus tapahtuu sovelluspäässä, ei SQL Serverissä.
Hyvä GDPR-herkän datan suojaamiseen. 

Toiminta käytännössä:
1. Avainhallinta:
- Salausavaimet tallennetaan Windows-sertifikaattivarastoon, Azure Key Vaultiin tai muuhun ulkoiseen hallintajärjestelmään.
- On olemassa kaksi tyyppiä avaimia:
    - Column Encryption Key (CEK): Kryptaa/dekryptaa sarakedatan.
    - Column Master Key (CMK): Suojaa CEK:n.

2. Data on kryptattu SQL Serverissä:
- Sarakkeet, joissa Always Encrypted on käytössä, näyttävät kryptatulta datalta SQL Serverin kautta (myös SSMS:ssa).
- Sovellus lähettää kryptatun arvon ja vastaanottaa kryptatun arvon, joka dekryptataan asiakaspäässä.

3. Salausmoodit:
- Deterministic: Sama syöte → sama kryptattu arvo (sallii haku- ja join-operaatiot).
- Randomized: Jokainen syöte → eri kryptattu arvo (turvallisempi, mutta ei tue hakuja/join-operaatioita).



### [Backup Encryption](https://learn.microsoft.com/en-us/sql/relational-databases/backup-restore/backup-encryption?view=sql-server-ver16)
Varmuuskopion suojaaminen tiedostotasolla.

```sql
BACKUP DATABASE TietokannanNimi
TO DISK = 'D:\Backup\Tietokanta.bak'
WITH COMPRESSION,
ENCRYPTION(ALGORITHM = AES_256, SERVER CERTIFICATE = TDE_Certificate);
```

