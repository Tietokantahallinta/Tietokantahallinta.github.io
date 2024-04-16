
revoke select, insert, update, delete, alter on Jasen to paakayttaja cascade;
revoke select, insert, update, delete, alter on Osoite to paakayttaja cascade;
revoke select, insert, update, delete, alter on KerhonJasenet to paakayttaja cascade;
revoke select, insert, update, delete, alter on Postinumero to paakayttaja cascade;
revoke select, insert, update, delete, alter on Kerho to paakayttaja cascade;
revoke select, insert, update, delete, alter on Yhdistys to paakayttaja cascade;
revoke select, insert, update, delete, alter on Tyontekija to paakayttaja cascade;


revoke select, insert, update, delete on Jasen to kayttaja1;
revoke select, insert, update, delete on KerhonJasenet to kayttaja1;
revoke select, insert, update, delete on Osoite to kayttaja1;


revoke select, insert, update, delete on Kerho to Ohjaaja;
revoke select, insert, update, delete on KerhonJasenet to Ohjaaja;


revoke select, insert, update, delete on Tyontekija to johtaja cascade;
revoke select on Jasen to johtaja cascade;
revoke select on Osoite to johtaja cascade;
revoke select on KerhonJasenet to johtaja cascade;
revoke select on Postinumero to johtaja cascade;
revoke select on Kerho to johtaja cascade;
revoke select on Yhdistys to johtaja cascade;

create role DataAdmin authorization paakayttaja;
grant select, insert, update, delete, alter on Jasen to DataAdmin with grant option;
grant select, insert, update, delete, alter on Osoite to DataAdmin with grant option;
grant select, insert, update, delete, alter on KerhonJasenet to DataAdmin with grant option;
grant select, insert, update, delete, alter on Postinumero to DataAdmin with grant option;
grant select, insert, update, delete, alter on Kerho to DataAdmin with grant option;
grant select, insert, update, delete, alter on Yhdistys to DataAdmin with grant option;
grant select, insert, update, delete, alter on Tyontekija to DataAdmin with grant option;
EXEC sp_addrolemember 'DataAdmin', 'johtaja';
EXEC sp_addrolemember 'DataAdmin', 'paakayttaja';

create role KerhonOhjaaja authorization paakayttaja;
grant select, insert, update, delete on Jasen to KerhonOhjaaja;
grant select, insert, update, delete on Osoite to KerhonOhjaaja;
grant select, insert, update, delete on KerhonJasenet to KerhonOhjaaja;
grant select, insert, update, delete on Postinumero to KerhonOhjaaja;
grant select, insert, update, delete on Kerho to KerhonOhjaaja;
grant select on Yhdistys to KerhonOhjaaja;
grant select,  update on Tyontekija to KerhonOhjaaja;
EXEC sp_addrolemember 'KerhonOhjaaja', 'Ohjaaja';

create role Jasen authorization paakayttaja;
grant select, update on Jasen to Jasen;
grant select, update on Osoite to Jasen;
grant select, insert on KerhonJasenet to Jasen;
grant select on Postinumero to Jasen;
grant select on Kerho to Jasen;
grant select on Yhdistys to Jasen;
grant select on Tyontekija to Jasen;
EXEC sp_addrolemember 'Jasen', 'kayttaja1';






