# Tehtävä 01:

Luo uusi tietokanta, nimellä ei ole merkitystä ja voit käyttää oletusarvoja luonnissa.

Tehtävänä on tehdä CREATE TABLE-lauseet niin, että osa INSERT-lauseista toimii ja osa ei toimi (ei saa toimia!). Joudut aineiston perusteella päättelemään taulut, niiden sarakkeet, avaimet, viiteavaimet ja rajoitteet. INSERT-lauseita ei saa muuttaa, vaikka niissä voi olla virheitä.

Seuraavana aineisto, huomaa kommentit <br> **-- PITÄÄ TOIMIA** ja <br> **-- EI SAA TOIMIA**
```sql
-- PITÄÄ TOIMIA:
INSERT INTO Luokitus VALUES(1000, 'Jarrut');
INSERT INTO Luokitus VALUES(1001, 'Valot');
INSERT INTO Luokitus VALUES(2008, 'Moottori');

INSERT INTO Valmistaja(Valmistaja_id, Nimi, WWWOsoite) VALUES (432, 'BreakParts Ltd', 'www.brakes.uk.co');
INSERT INTO Valmistaja VALUES (311, 'Jaskan osa oy', 'www.jaskanosa.fi');
INSERT INTO Valmistaja(Valmistaja_id, Nimi, WWWOsoite) VALUES (132, 'Saab', 'www.legacyparts.com');
INSERT INTO Valmistaja VALUES (1201, 'VW', 'google.fi');

INSERT INTO Varaosa VALUES(1,  'H2 polttimo', 7.99, null, 'A23', '2022-08-10', 82, 1001, 1201);
INSERT INTO Varaosa VALUES(2,  'Jarrulevy', 44.99, 'Saab 9000', 'B13', null, 3, 1000, 311);
INSERT INTO Varaosa VALUES(30, 'Jarrupala', 100, 'Skoda Octavia', 'B13', '2024-01-10', 8, 1000, 432);
INSERT INTO Varaosa VALUES(10, 'Suodatin', 17.49, 'Saab 96', 'Z2', '2023-03-21', 0, 2008, 132);
INSERT INTO Varaosa VALUES(5,  'Venttiili', 15, null, 'M15', '2024-02-02', 10, 2008, 311);

select * from Varaosa;
select * from Luokitus;
select * from Valmistaja;


-- EI SAA TOIMIA:

INSERT INTO Luokitus VALUES(1010, 'Ilmastointilaitteen korjaussarjat');
INSERT INTO Luokitus VALUES(1021, '4H polttimo');
INSERT INTO Luokitus VALUES(2038, ' Pakosarja');

INSERT INTO Valmistaja(Valmistaja_id, Nimi) VALUES (1301, 'Bosch');
INSERT INTO Valmistaja VALUES (401, 'Kallen Kalliit Kustoimointituotteet', 'CustomParts.fi');

INSERT INTO Varaosa VALUES(11, 'H7 polttimo', 7.99, null, 'C123', getdate(), 1, 1001, 1201);
INSERT INTO Varaosa VALUES(2,  'Jarrulevy Super ', 44.99, 'Saab 9000', 'B13', null, 3, 1000, 311);
INSERT INTO Varaosa VALUES(33,  null, 100, 'Volvo V90', 'V13', '2024-01-10', 1, 1001, 432);
INSERT INTO Varaosa VALUES(12, 'Tunkki', 77.49, null, 'Z2', '2023-03-21', 0, 2009, 132);
INSERT INTO Varaosa VALUES(15, 'Tankki', 0, null, 'X15', '2024-02-02', 4, 2008, 312);

delete from luokitus where Luokitus = 'Jarrut';
update valmistaja set Valmistaja_id = 343 where Valmistaja_id = 311;
```

Palauta tämän jälkeen Moodleen taulujen luontilauseet tekstinä niin että sen voi tallentaa tiedostoon ja ajaa skriptinä. Insert-lauseita ei tarvitse palauttaa.
