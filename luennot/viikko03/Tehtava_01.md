# Tehtävä 01:

## Stored proc

Käytetään Takkulan tietokantaa tässä harjoituksessa.

- Tee proseduuri, joka saa parametrina ainenumeron, kurssikerran sekä oppilasnumeron. Jos kaikki parametrit löytyvät tietokannasta (siis nämähän ovat avaimia!), lisää opiskelija kurssille suoritustauluun niin, että arvosana ja myöntäjä ovat NULL-arvossa ja päivämäärä on ilmoittautumishetki (pelkkä päiväys, ei kellonaikaa). 
- Testaa toiminta. 
- Korjaa suoritustaulua niin, että lisäät uuden sarakkeen IlmoittaumisPvm (ALTER TABLE) ja päivitä tähän riveille kurssin alkupäivämäärä.
- Muuta proseduuria niin, että pvm asetetaan NULL-arvoon ja Ilmoittautumispäiväksi tulee nykyhetki mutta niin, että ilmoittautumisen voi tehdä vain kaksi viikkoa ennen kurssin alkupäivää ja kaksi viikkoa alkamisen jälkeen. Joudut varmaan tekemään lisää aihneistoa testaamista varten. 

Palauta funktiot ja testaava SQL-lauseet Moodleen tekstinä

<!-- 
- Tietokannan käyttäjätunnusten luonti ja oikeuksien antaminen käyttäjätunnus kohtaisesti

Käytä tässä tehtävässä YhdistyksenTietokanta -nimistä tietokantaa, jonka olet luonnut aikaisemmissa tehtävissä.

Luo siihen käyttäjätunnus kyseisen tietokannan datan ylläpitäjälle (ns. pääkäyttäjä). Tällä käyttäjällä siis pitää olla tarpeelliset oikeudet YhdistysTietokannan sisältämän datan ylläpitämiseen.

Luo käyttäjätunnus, jolla on niin sanotun tavallisen käyttäjän oikeudet. Heitä voi olla useita erilaisia. Toiminnan ohjaaja, yhdistyksen johtaja,  yhdistyksen taloudenhoitaja, yhdistykseen liittynyt asiakas. Millaisia oikeuksia näillä voisi olla. 

Miten instanssiin kirjautuminen kannattaisi tehdä?

Miten nämä oikeudet olisi järkevää jakaa erilaisille käyttäjille. Anna kirjallinen vastaus tästä Moodlessa olevaan tehtävän palautuslinkkiin.


Palauta tämän jälkeen Moodleen, palautuslinkkiin myös T-SQL kielinen scripti (Transact-SQL), jolla saat luotua tarvittavat käyttäjät. -->
