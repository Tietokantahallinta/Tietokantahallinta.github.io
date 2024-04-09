Perustelut:
Vielä ei tiedetä tämän tietokannan käyttöä. Käyttäjiä on tosin 
vähän. 6 henkilökuntaa ja 20 asiakasta. Se on vähän. 
Mutta luodaan varovaisesti ehkä todennäköisimmin eniten liitoksia
käyttävään tauluun yksi ulkoinen indeksi. Kaikki FX kentät ovat siis
potenttiaalisia indeksointi kohteita.

create index IX_KerhonJasenet_FKt 
on KerhonJasenet(KerhoNro, JasenID);

create index IX_Jasen_Sukunimi_Etunimi on Jasen(Sukunimi, Etunimi);

Tämän jälkeen ryhdytään seuraamaan tietokannan taulujen todellista käyttöä.
Sitä on mahdollista monitoroida. Näillä tunneilla tulee asiasta tarkemmin
seuraavilla tunneilla.

Kun todellista käyttötilastoa saadaan, voidaan lisätä lisää indeksejä. Tai poistaa niitä.