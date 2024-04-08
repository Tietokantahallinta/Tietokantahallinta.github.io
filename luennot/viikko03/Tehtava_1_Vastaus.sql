create login DataAdmin with password = 'salasana1', 
default_database = YhdistyksenTietokanta;
create user DataAdmin for login DataAdmin;
grant select, insert, update, delete, alter on Jasen to DataAdmin with grant option;
grant select, insert, update, delete, alter on Osoite to DataAdmin with grant option;
grant select, insert, update, delete, alter on KerhonJasenet to DataAdmin with grant option;
grant select, insert, update, delete, alter on Postinumero to DataAdmin with grant option;
grant select, insert, update, delete, alter on Kerho to DataAdmin with grant option;
grant select, insert, update, delete, alter on Yhdistys to DataAdmin with grant option;
grant select, insert, update, delete, alter on Tyontekija to DataAdmin with grant option;

create login kayttaja1 with password = 'salasana1', 
default_database = YhdistyksenTietokanta;
create user kayttaja1 for login kayttaja1;
grant select, insert, update, delete on Jasen to kayttaja1;
grant select, insert, update, delete on KerhonJasenet to kayttaja1;
grant select, insert, update, delete on Osoite to kayttaja1;

create login Ohjaaja with password = 'salasana1', 
default_database = YhdistyksenTietokanta;
create user Ohjaaja for login Ohjaaja;
grant select, insert, update, delete on Kerho to Ohjaaja;
grant select, insert, update, delete on KerhonJasenet to Ohjaaja;

create login johtaja with password = 'salasana1', 
default_database = YhdistyksenTietokanta;
create user johtaja for login johtaja;
grant select, insert, update, delete on Tyontekija to johtaja;
grant select on Jasen to johtaja with grant option;
grant select on Osoite to johtaja with grant option;
grant select on KerhonJasenet to johtaja with grant option;
grant select on Postinumero to johtaja with grant option;
grant select on Kerho to johtaja with grant option;
grant select on Yhdistys to johtaja with grant option;





