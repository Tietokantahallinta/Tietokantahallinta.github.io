select * from tilit;

User1 (pankki palautaa asiakkaalle yli veloituksesta
rahaa takaisin:

Ajetaan ensimm�isen�
begin transaction
update tilit set saldo = saldo - 20 
where  tilinro = 910101;

Ajetaan kolmantena
update tilit set saldo = saldo + 20 
where tilinro = 710100;

Menee jonoon odottamaan

Ajetaan viidenten�
commit;

select * from tilit;

