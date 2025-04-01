# Tehtävä 03:

Schema ja oikeudet

Jos et edellisessä tehtävässä tehnyt jo HR-nimistä schemaa tietokantaan, tee se nyt.
Lisää HR-schemaan uusi taulu Henkilö. Henkilöllä on sarakkeina 
- HenkilöID (numerointi sekvenssillä)
- etunimi ja sukunimi
- työsuhteen aloitus ja lopetuspäivät
- toimipaikan nimi (teksti riittää)

Lisää tähän tauluun muutama rivi aineistoa.
Kirjaudu JaskJ ja AkuA-logineilla palvelimelle ja tutki miten juuri tekemäsi taulun käyttö onnistuu. Tarvittaessa anna JaskaJ:lle ja Aku:lle lisää oikeuksia (select ja insert, ei delete!).

Vaihda JaskaJ-käyttäjän oletusschemaksi HR ja kokeile uudelleen kirjautumisen jälkeen miten tauluviittauksen onnistuu.

Tee ja palauta skriptitiedosto, jossa on scheman ja taulun luontikomennot sekä tarvittavat GRANT-komennot oikeuksien antamiseen.


<!-- 
- Tietokannan ulkoiset indeksit

Yhdistyksen tietokantaa käyttää yhdistys, jossa on 6 vakinaista työntekijää, jotka käyttävät tietokantaa aktiivisesti. Yhdistyksellä on 20 jäsentä, jotka osallistuvat yhdistyksen järjestämien palveluiden käyttöön joka ilta innokkaasti. Viikonloppuisin yhdityksen palveluita käyttää vain noin puolet yhdistyksen jäsenistä. Kukaan yhdistyksen vakinaisesta henkilökunnasta ei ole käyttämässä tietokantaa viikonloppuisin.

Millaisia ulkoisia indeksejä loisit edellisen tehtävän 02 YhdistyksenTietokanta -nimiseen tietokantaan. Perustele omin sanoin.

Mitkä ovat ne syyt, miksi näitä ulkoisia indeksejä kannattaa luoda? Anna ainakin yhdestä ulkoisen indeksin luonnista sen luonti komento vastauksena.

![](YhdistyksenTietokantaKaavio.jpg)<br>
Kuva 1. Yhdistyksen tietokannan relaatiokaavio.

Palauta tämän jälkeen Moodleen, palautuslinkkiin luomasi ulkoisten indeksien  luonti lauseet T-SQL kielisenä scriptinä (Transact-SQL), yhdessä perusteluiden kanssa, milloin ulkoisia indeksejä kannattaa luoda. -->
