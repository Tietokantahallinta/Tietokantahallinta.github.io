create login paakayttaja with password = 'salasana1', 
default_database = YhdistyksenTietokanta;
create user paakayttaja for login paakayttaja;
grant select, insert, update, delete, alter on Jasen to paakayttaja with grant option;
grant select, insert, update, delete, alter on Osoite to paakayttaja with grant option;
grant select, insert, update, delete, alter on KerhonJasenet to paakayttaja with grant option;
grant select, insert, update, delete, alter on Postinumero to paakayttaja with grant option;
grant select, insert, update, delete, alter on Kerho to paakayttaja with grant option;
grant select, insert, update, delete, alter on Yhdistys to paakayttaja with grant option;
grant select, insert, update, delete, alter on Tyontekija to paakayttaja with grant option;

create login kayttaja1 with password = 'xcvR65341VUW#', 
default_database = YhdistyksenTietokanta;
create user kayttaja1 for login kayttaja1;
grant select, insert, update, delete on Jasen to kayttaja1;
grant select, insert, update, delete on KerhonJasenet to kayttaja1;
grant select, insert, update, delete on Osoite to kayttaja1;

create login Ohjaaja with password = 'xcvR65341VUW', 
default_database = YhdistyksenTietokanta;
create user Ohjaaja for login Ohjaaja;
grant select, insert, update, delete on Kerho to Ohjaaja;
grant select, insert, update, delete on KerhonJasenet to Ohjaaja;

create login johtaja with password = 'xcvR65341VUW', 
default_database = YhdistyksenTietokanta;
create user johtaja for login johtaja;
grant select, insert, update, delete on Tyontekija to johtaja;
grant select on Jasen to johtaja with grant option;
grant select on Osoite to johtaja with grant option;
grant select on KerhonJasenet to johtaja with grant option;
grant select on Postinumero to johtaja with grant option;
grant select on Kerho to johtaja with grant option;
grant select on Yhdistys to johtaja with grant option;





