User2: Asiakas (Milla)
Ajetaan toisena
begin transaction
update tilit set saldo = saldo - 150
where tilinro = 710100;

Ajetaan neljäntenä
update tilit set saldo = saldo + 150
where tilinro = 910101;

Ajetaan kuudentena;
commit;

select * from tilit;



