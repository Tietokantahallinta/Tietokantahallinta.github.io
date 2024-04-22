create table Tilit (
	tilinro int not null primary key,
	saldo decimal(10,2) not null
);

Aloitus tilanne:
delete from tilit;
insert into Tilit (tilinro, saldo) values (710100, 2000);
insert into Tilit (tilinro, saldo) values (910101, 200000);

select * from tilit;

User 2: Milla
Katsotaan aloitustilanne:
select * from Tilit;

User 2: Milla maksaa operaattori maksunsa, 40 e.
Ajetaan ensimmäiseksi
begin transaction
update Tilit set saldo = saldo - 40 where tilinro = 710100;
update Tilit set saldo = saldo + 40 where tilinro = 910101;

Ajeteaan toiseksi
select * from tilit;

Ajetaan neljänneksi

Ajetaan viidenneksi
select * from tilit;


