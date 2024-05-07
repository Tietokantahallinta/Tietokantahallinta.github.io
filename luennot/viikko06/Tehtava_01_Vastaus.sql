dbcc showcontig('Purchasing.PurchaseOrderHeader'); 

use master;
go
alter database [AdventureWorks2012] 
set single_user;
go
dbcc checkdb (AdventureWorks2012, repair_fast);

dbcc checkdb (AdventureWorks2012, repair_rebuild);

alter database [AdventureWorks2012] 
set multi_user;
go

use AdventureWorks2012;

dbcc checktable('Purchasing.PurchaseOrderHeader');
