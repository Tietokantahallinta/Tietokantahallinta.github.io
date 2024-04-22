delete from Tilit;
drop table Tilit;

create table Tilit (
	tilinro int not null primary key,
	saldo decimal(10,2) not null
);

Aloitus tilanne:
delete from tilit;
insert into Tilit (tilinro, saldo) values (710100, 2000);
insert into Tilit (tilinro, saldo) values (910101, 200000);

select * from tilit;

User 2: Milla suorittaa operaattori maksun 40 e
Ilman transaktioiden hallintaa
update Tilit set saldo = saldo - 40 where tilinro = 710100;
update Tilit set saldo = saldo + 40 where tilinro = 910101;

User 2: Milla maksaa operaattori maksunsa, 40 e.
begin transaction
update Tilit set saldo = saldo - 40 where tilinro = 710100;
update Tilit set saldo = saldo + 40 where tilinro = 910101;
commit

select * from tilit;

(rollback)

User 1: Pankin kontrollori
select * from Tilit where tilinro = 910101;

User 2: Milla maksaa operaattori maksunsa, 40 e.
Ajetaan ensimmäiseksi
begin transaction
update Tilit set saldo = saldo - 40 where tilinro = 710100;
update Tilit set saldo = saldo + 40 where tilinro = 910101;

Ajeteaan kolmanneksi
select * from tilit;

Ajetaan neljänneksi
commit
select * from tilit;


