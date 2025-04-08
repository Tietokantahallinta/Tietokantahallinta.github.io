-- TAKKULA-tietokannan taulujen luontilauseet (SQL Server): 9.5.2022

-- Poistetaan taulut, jos ne ovat ennestään olemassa
DROP TABLE IF EXISTS SUORITUS;
DROP TABLE IF EXISTS OPPILAS;
DROP TABLE IF EXISTS KURSSI;
DROP TABLE IF EXISTS AINE;
DROP TABLE IF EXISTS OPETTAJA;

-- Sitten luodaan taulut

CREATE TABLE OPETTAJA (
    opettajanro     CHAR(4)  NOT NULL,
    etunimi         VARCHAR(10) ,
    sukunimi        VARCHAR(10) ,
    palkka          DECIMAL(8,2),
    puhelin         VARCHAR(10) ,
    syntpvm         DATE,
    PRIMARY KEY (opettajanro));

CREATE TABLE AINE (
    ainenro         CHAR(4)  NOT NULL,
    nimi            VARCHAR(30) ,
    vastuuopettaja  CHAR(4) ,
    suorituspisteet SMALLINT,
    PRIMARY KEY (ainenro),
    FOREIGN KEY (vastuuopettaja) REFERENCES OPETTAJA(opettajanro));

CREATE TABLE KURSSI (
    ainenro         CHAR(4)  NOT NULL,
    kurssikerta     SMALLINT NOT NULL,
    alkupvm         DATE,
    opettajanro     CHAR(4) ,
    osallistujalkm  SMALLINT,
    loppupvm        DATE,
    PRIMARY KEY (ainenro, kurssikerta),
    FOREIGN KEY (ainenro) REFERENCES AINE(ainenro),
    FOREIGN KEY (opettajanro) REFERENCES OPETTAJA(opettajanro));

CREATE TABLE OPPILAS (
    oppilasnro      CHAR(4)  NOT NULL,
    etunimi         VARCHAR(10) ,
    sukunimi        VARCHAR(10) ,
    syntpvm         DATE,
    lahiosoite      VARCHAR(20) ,
    postinro        CHAR(5) ,
    sukupuoli       CHAR(1) ,
    postitmp        VARCHAR(10) ,
    PRIMARY KEY (oppilasnro));

CREATE TABLE SUORITUS (
    oppilasnro      CHAR(4)  NOT NULL,
    ainenro         CHAR(4)  NOT NULL,
    kurssikerta     SMALLINT NOT NULL,
    pvm             DATE,
    arvosana        SMALLINT,
    myontaja        CHAR(4) ,
    PRIMARY KEY (oppilasnro, ainenro, kurssikerta),
    FOREIGN KEY (oppilasnro) REFERENCES OPPILAS(oppilasnro),
    FOREIGN KEY (ainenro, kurssikerta) REFERENCES KURSSI(ainenro, kurssikerta),
    FOREIGN KEY (myontaja) REFERENCES OPETTAJA(opettajanro),
	CHECK ((arvosana BETWEEN 0 AND 5) OR (arvosana IS NULL)));
    
--  End --