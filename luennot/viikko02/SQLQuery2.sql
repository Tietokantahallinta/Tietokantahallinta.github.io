Perustelut:
Viel� ei tiedet� t�m�n tietokannan k�ytt��. K�ytt�ji� on tosin 
v�h�n. 6 henkil�kuntaa ja 20 asiakasta. Se on v�h�n. 
Mutta luodaan varovaisesti ehk� todenn�k�isimmin eniten liitoksia
k�ytt�v��n tauluun yksi ulkoinen indeksi. Kaikki FX kent�t ovat siis
potenttiaalisia indeksointi kohteita.

create index IX_KerhonJasenet_FKt 
on KerhonJasenet(KerhoNro, JasenID);

create index IX_Jasen_Sukunimi_Etunimi on Jasen(Sukunimi, Etunimi);

T�m�n j�lkeen ryhdyt��n seuraamaan tietokannan taulujen todellista k�ytt��.
Sit� on mahdollista monitoroida. N�ill� tunneilla tulee asiasta tarkemmin
seuraavilla tunneilla.

Kun todellista k�ytt�tilastoa saadaan, voidaan lis�t� lis�� indeksej�. Tai poistaa niit�.