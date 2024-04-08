create table Postinumero (
	PostinumeroID int not null primary key identity(1,1),
	Postinumero char(5) not null,
	Postitoimipaikka varchar(25) not null,
	Maa varchar(25) not null
);

create table Osoite (
	OsoiteID int not null primary key identity(1,1),
	Katuosoite varchar(30) not null,
	PostinumeroID int not null,
	foreign key (PostinumeroID) references Postinumero(PostinumeroID)
);

create table Yhdistys (
	YhdistysTunnus char(10) not null primary key,
	Nimi varchar(30) not null,
	ToiminnanJohtajaID int null,
	OsoiteID int null,
	Puhelin varchar(15) null,
	wwwosoite varchar(100) null,
	foreign key (OsoiteID) references Osoite(OsoiteID)
);

create table Tyontekija (
	TyontekijaID int not null primary key identity(1,1),
	Sukunimi varchar (25) not null,
	Etunimi varchar(20) not null,
	TyoPuhelin varchar(15) null,
	TyoSahkoposti varchar(50) null,
	OsoiteID int not null,
	YhdistysTunnus char(10) not null,
	foreign key (OsoiteID) references Osoite(OsoiteID),
	foreign key (YhdistysTunnus) references Yhdistys(YhdistysTunnus)
);

create table Kerho (
	KerhoNro int not null primary key identity(1,1),
	KerhonNimi varchar not null,
	Kuvaus varchar(50) null,
	PerustamisPVM date not null,
	VetajaID int null,
	YhdistysTunnus char(10) not null,
	foreign key (VetajaID) references Tyontekija(TyontekijaID),
	foreign key (YhdistysTunnus) references Yhdistys(YhdistysTunnus)
);

create table Jasen (
	JasenID int not null primary key identity(1,1),
	Sukunimi varchar (25) not null,
	Etunimi varchar(20) not null,
	Puhelin varchar(15) null,
	YhdistysTunnus char(10) not null,
	Sahkoposti varchar(50) null,
	OsoiteID int not null,
	foreign key (OsoiteID) references Osoite(OsoiteID),
	foreign key (YhdistysTunnus) references Yhdistys(YhdistysTunnus)
);

create table KerhonJasenet (
	KJID int not null primary key identity(1,1),
	KerhoNro int not null,
	JasenID int not null,
	foreign key (KerhoNro) references Kerho(KerhoNro),
	foreign key (JasenID) references Jasen(JasenID)
);

alter table Yhdistys 
	add constraint constr_yhdistys_tj
		foreign key (ToiminnanJohtajaID)
			references Tyontekija(TyontekijaID)
				on delete set null;

alter table Yhdistys 
	drop constraint constr_yhdistys_tj;
drop table KerhonJasenet;
drop table Jasen;
drop table Kerho;
drop table Tyontekija;
drop table Yhdistys;
drop table Osoite;
drop table Postinumero;





