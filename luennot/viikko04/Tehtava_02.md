# Tehtävä 02:

Pohdi seuraavia asioita:
1. Lisäät tietokannan Product-tauluun sarakkeet UpdatedBy ja TimeOfUpdate. Mitä hyötyä tästä voisi olla? Mikä voisi olla tilanne, missä tarvitaan tarkempaa seurantaa datalle?

2. Teet triggereiden avulla AuditTrail-tyyppisen seurannan tauluihin Customer, MarketingEvent, SpecialOffer, Order, OrderDetail ja ProductReview. Kaikki vaikuttaa tässä vaiheessa hyvältä varsinkin jos seuranta toimii eli kaikista muutoksista jää jälki. Jossain vaiheessa markkinointiosasto haluaa tehdä ajoja, joissa siirretään asiakastietoja Customer-taulusta InactiveCustomer-tauluun niiden asiakkaisen osalta, jotka eivät ole tilanneet mitään viimeisen vuoden aikana. <br><br>
Varsinainen kysymys on ei-tekninen, mutta aiheuttaa teknisiä toimenpiteitä. Mitä sinun ja muiden DBA-porukkaan kuuluvien pitäisi huomioida vaikkapa GDPR:n takia tässä tilanteessa? (Vinkki: liittyy aiheeseen *Tarkistuspyyntö rekisterinpitäjälle*)

**Palauta vastaukset Moodleen**





<!-- 
- Varmistusten teko (backup)

- Tee SQL Server Management Studiolla varmistus edellisessä tehtävässä luodusta Pankki tietokannasta. Voit tallentaa varmistuksen tietokoneesi C-asemalle, vaikkei se olekaan suositeltava paikka tuotannollisissa tietokantapalvelimissa. Voit myös tallentaa muistitikulle, jos se on mahdollista. Generoi tästä varmistus ajosta T-SQL scripti.

Palauta tämän jälkeen Moodleen, palautuslinkkiin  T-SQL kielinen scripti (Transact-SQL), jolla saat tehtyä varmistuksen SQL Serverissä.  -->
