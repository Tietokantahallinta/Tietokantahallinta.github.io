-- TAKKULA-tietokannan taulujen datan INSERT-lauseet (SQL Server): 9.5.2022

/* Poistetaan kaikki entiset tiedot tauluista */
DELETE FROM SUORITUS;
DELETE FROM KURSSI;
DELETE FROM AINE;
DELETE FROM OPETTAJA;
DELETE FROM OPPILAS;

/* Lisätään uudet rivit tauluihin */

INSERT INTO OPPILAS 
(oppilasnro, etunimi, sukunimi, syntpvm, lahiosoite, postinro, postitmp, sukupuoli) VALUES 
('o148', 'Sanna', 'Rentukka', '1997-10-22', 'Puronvarsi 662 F', '00630', 'Helsinki', 'N'),
('o210', 'Kaarlo', 'Kuikka', '1992-08-31', 'Huilupolku 58 C 2', '00420', 'Helsinki', 'M'),
('o298', 'Raimo', 'Veto', '1989-12-01', 'Ketjukuja 196 A 81', '00680', 'Helsinki', 'M'),
('o348', 'Kaarina', 'Käki', '1977-04-03', 'Äimäkuja 79', '01260', 'Vantaa', 'N'),
('o349', 'Johan', 'Bompas', '1998-05-17', 'Övre-Gumminkuja 115', '01590', 'Maisala', 'M'),
('o354', 'Usko', 'Huhta', '1993-05-22', 'Toivola 100', '01800', 'Klaukkala', 'M'),
('o410', 'Leila', 'Liimatta', '1971-03-03', 'Nysätie 44 G', '02880', 'Veikkola', 'N'),
('o473', 'Fredrik', 'Leino', '1998-11-22', 'Haukas 20 A 20', '02400', 'Kyrkslätt', 'M'),
('o548', 'Valma', 'Vuori', '1986-10-10', 'Jäspilänkatu 22', '04200', 'Kerava', 'N'),
('o558', 'Greta', 'Hullerus', '1999-03-28', 'Havs-hanikka 800 A', '02360', 'Esbo', 'N'),
('o649', 'Martti', 'Keto', '1999-03-28', 'Siamintie 66 B 1', '00560', 'Helsinki', 'M'),
('o654', 'Rosina', 'Laine', '2000-05-07', 'Liplatus 55 D', '02320', 'Espoo', 'N');

INSERT INTO OPETTAJA 
(opettajanro, etunimi, sukunimi, syntpvm, puhelin, palkka) VALUES 
('h303', 'Veli', 'Ponteva', '1997-07-25', '09-123456', 1950.00),
('h290', 'Sisko', 'Saari', '1972-11-01', '09-776655', 3145.00),
('h430', 'Emma', 'Virta', '1966-04-18', '015-33002', 3620.00),
('h180', 'Seppo', 'Kokki', '1967-02-03', '09-808800', 3165.00),
('h560', 'Olka', 'Tahko', '1972-05-30', '09-666977', 3180.00),
('h784', 'Veera', 'Vainio', '1956-04-12', '09-203749', 3210.00);
 
INSERT INTO AINE 
(ainenro, nimi, vastuuopettaja, suorituspisteet) VALUES 
('a450', 'Virtuaaliverkot (VPN)', 'h430', 3),
('a730', 'E-bisnestä aloittelijoille', 'h290', 4),
('a290', 'Javan jatkokurssi', 'h430', 2),
('a480', 'Tieto tietokannoista', 'h784', 3);
 
INSERT INTO KURSSI 
(ainenro, kurssikerta, alkupvm,loppupvm, opettajanro, osallistujalkm) VALUES 
('a450', 1, '2020-01-03', '2020-02-25', 'h303', 2),
('a730', 1, '2020-03-15', '2020-05-30', 'h290', 6),
('a290', 1, '2020-08-01', '2020-09-15', 'h430', 3),
('a480', 1, '2020-02-10', '2020-04-22', 'h180', 3),
('a450', 2, '2020-12-01', '2021-03-10', 'h560', 2),
('a480', 2, '2021-01-15', '2021-03-30', 'h784', 2),
('a290', 2, '2021-03-02', NULL, NULL, NULL);
 
INSERT INTO SUORITUS
(oppilasnro, ainenro, kurssikerta, pvm, arvosana, myontaja) VALUES 
('o148', 'a730', 1, '2020-06-01', 3, 'h290'),
('o210', 'a450', 2, '2021-03-02', 3, 'h303'),
('o210', 'a730', 1, '2020-06-05', 1, 'h290'),
('o298', 'a290', 1, '2020-09-06', 3, 'h430'), 
('o298', 'a480', 2, '2021-04-05', 3, 'h784'), 
('o348', 'a730', 1, '2020-06-07', 4, 'h290'), 
('o349', 'a290', 1, '2020-09-11', 4, 'h430'), 
('o354', 'a480', 1, '2020-05-22', 4, 'h784'), 
('o410', 'a290', 1, '2020-05-15', 2, 'h180'), 
('o410', 'a730', 1, '2020-06-01', 3, 'h290'), 
('o473', 'a450', 1, '2020-03-14', 2, 'h303'), 
('o473', 'a730', 1, '2020-06-10', 3, 'h290'), 
('o473', 'a480', 2, '2020-04-06', 0, 'h784'), 
('o548', 'a290', 1, '2020-09-20', 2, 'h430'), 
('o548', 'a450', 2, NULL, NULL, NULL), 
('o649', 'a730', 1, '2020-06-02',4, 'h290'), 
('o649', 'a480', 1, '2020-05-03',4, 'h180'), 
('o654', 'a450', 1, '2020-03-18',4, 'h303');

-- End --