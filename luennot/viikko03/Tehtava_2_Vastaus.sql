
revoke select, insert, update, delete, alter on Jasen to DataAdmin cascade;
revoke select, insert, update, delete, alter on Osoite to DataAdmin cascade;
revoke select, insert, update, delete, alter on KerhonJasenet to DataAdmin cascade;
revoke select, insert, update, delete, alter on Postinumero to DataAdmin cascade;
revoke select, insert, update, delete, alter on Kerho to DataAdmin cascade;
revoke select, insert, update, delete, alter on Yhdistys to DataAdmin cascade;
revoke select, insert, update, delete, alter on Tyontekija to DataAdmin cascade;


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

create role paakayttaja authorization DataAdmin;
grant select, insert, update, delete, alter on Jasen to paakayttaja with grant option;
grant select, insert, update, delete, alter on Osoite to paakayttaja with grant option;
grant select, insert, update, delete, alter on KerhonJasenet to paakayttaja with grant option;
grant select, insert, update, delete, alter on Postinumero to paakayttaja with grant option;
grant select, insert, update, delete, alter on Kerho to paakayttaja with grant option;
grant select, insert, update, delete, alter on Yhdistys to paakayttaja with grant option;
grant select, insert, update, delete, alter on Tyontekija to paakayttaja with grant option;
sp_addrolemember 'paakayttaja', 'johtaja';









