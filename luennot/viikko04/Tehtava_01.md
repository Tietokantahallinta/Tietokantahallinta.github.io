# Tehtävä 01:

- Tee lyhyt esimerkki, jolla osoitat missä TRYCAST on parempi kuin CAST ja mistä syystä. Miten yhdistäisit nämä ISNULL tai COALESCE-komentoihin. Mitä eroa on ISNULL ja COALESCE:llä (ainakin kaksi eroa).


- JSON-muotoista dataa voi tallentaa merkkijonona SQL Server-tietokantaan. Tehtävänäsi on kirjoittaa lyhyt kysely esimerkkitauluun siten, että se palauttaa seuraavan datan:
```sql
id	Nimi	Kaupunki
1	Matti Teppo	Helsinki
2	Liisa Virtanen	Turku
3	Jaakko Parantainen	Vantaa
```

Käytä esimerkissä seuraavaa taulua ja rivejä:
```sql
CREATE TABLE AsiakasData (
    id INT PRIMARY KEY,
    tiedot NVARCHAR(MAX)
);

INSERT INTO AsiakasData VALUES 
(1, N'{ "nimi": "Matti Teppo", "kaupunki": "Helsinki", "tilaushistoria": [{ "tuote": "Kirja", "maara": 5 }] }'),
(3, N'{ "nimi": "Jaakko Parantainen", "kaupunki": "Vantaa", "tilaushistoria": [{ "tuote": "Kirja", "maara": 22 }] }'),
(2, N'{ "nimi": "Liisa Virtanen", "kaupunki": "Turku", "tilaushistoria": [{ "tuote": "ATK-laite", "maara": 1 }] }');
```

Käytä JSON-datan lukemiseen tarkoitettuja funktiota ja lisätehtävänä on keksiä miten kyselyn voi tehdä ilman JSON-funktioita'



Palauta vastauksesi Moodleen.




<!-- - Kahden eri transaktion (esim. kahden eri käyttäjän tai ikkunan) kilpailutilanne samasta datarivistä tietokannassa.

- Tee seuraavanlainen tehtävä SQL Server:in Management Studiossa.
- Tee Pankki niminen tietokanta.
- Luo sinne tietokanta taulu, jonka nimi on tilit: 
<code>
create table tilit
(tiliNro int primary key,
summa money);
</code>
<br>
- Lisää sen jälkeen tilit tauluun muutama tili tieto tilinumerolle 1001001 ja 1001002:
<br>
<code>
insert into tilit (tiliNro, summa) VALUES (1001001,700);
insert into tilit (tiliNro, summa) VALUES (1001002,500.5);
</code>
<br>
- Varmistu, että rivien lisäämenen tauluun onnistui:
<code>
select * from tilit;
</code>
<br>
Tuloksena pitäisi tulla:
tiliNro summa<br>
1001001	700,00<br>
1001002	500,50<br>
<br>
- Seuraavaksi tehtävä jatku siten, että nykyisestä SQL Server Management Studion ikkunasta tulee "Ikkuna 1". Tämän lisäksi tarvitse avata "Ikkuna 2", joka on tavallaan jonkin toisen käyttäjän käyttämä transaktio.

![](Kuva_T01_01.PNG)<br>
Kuva 1. Kahden "käyttäjää" kahden ikkunan avulla.<br>

- Ikkunassa 1 on jo todettu, että taulun tilit kaksi datariviä näkyvät niin kuin pitääkin.

- Nyt siirrytään Ikkunaan 2.
- Ja siellä aloitetaan transaktio Transact SQL:n eli T-SQL:n komennolla begin transaction. Tällainen transaktio lopetetaan joko komennolla commit tai rollback, jos halutaan peruuttaa transaktio. 
- Aja Ikkuna 2:ssa seuraavat lauseet. Kyseessä on tilisiirto tai maksu pankin järjestelmissä. Nyt käytämme sitä mahdollisimman selkeänä esimerkkinä aloitetusta transaktiosta, ja mitä vaikutuksia sillä on.

<code>
begin transaction
update tilit set summa = summa - 20 where tiliNro=1001001;
update tilit set summa = summa + 20 where tiliNro=1001002;

select * from tilit;
</code>

- Siirry takaisin Ikkuna 1:een
<code>
select * from tilit;
</code>
<br>

![](Kuva_T01_02.PNG)<br>
Kuva 2. Kilpailutilanne, jossa Ikkuna 1 odottaa Ikkuna 2:ta.<br>

- Kerro omin sanoin tämän tehtävän vastauksessasi Moodleen, mitä tässä kohtaa tapahtuu. Miksi Ikkuna 1:een ei tule tulosta, mutta Ikkuna 2:een tulee?

- Siirry nyt seuraavaksi takaisin Ikkuna 2:een ja aja siellä commit lause, lopettaaksesi kesken eräisen transaktion siellä

<br>
<code>
commit;
</code>
<br>

![](Kuva_T01_03.PNG)<br>
Kuva 3. Loppu tilanne, jossa lukot vapautetaan.<br>

- Kerro lopuksi vastauksessasi Moodleen, miksi nyt Ikkuna 1 saa tuloksen pitkän odottelun jälkeen.

- Mitä merkitystä tällä on tietokanta palvelimen yllä pidon kannalta? Mitkä ovat seuraukset, jos jossa applikaatiossa on tämän kaltaisesti virheellisesti toimivat transaktio? Miksi tällaisen tilisiirron tai maksu tekemiseen on käytettävä transaktiot, kuten Ikkuna 2:ssa on tehty. Mitkä olisivat seuraukset, jollei käytettäisi?

Palauta tämän jälkeen Moodleen, palautuslinkkiin  T-SQL kielinen scripti (Transact-SQL), jolla saat aikaan kilpailutilanteen. Sekä omin sanoin esittämäsi vastaukset tapahtumien kulusta.  
-->
