SELECT C.CustomerID, C.CompanyName, A.StateProvince, A.CountryRegion, O.SalesOrderID, O.OrderDate 
FROM SalesLT.SalesOrderHeader O 
INNER JOIN SalesLT.Customer C ON O.CustomerID = C.CustomerID
INNER JOIN SalesLT.Address A ON O.ShipToAddressID = A.AddressID 
WHERE A.StateProvince = 'California'
UNION
SELECT C.CustomerID, C.CompanyName, A.StateProvince, A.CountryRegion, O.SalesOrderID, O.OrderDate 
FROM SalesLT.SalesOrderHeader O 
INNER JOIN SalesLT.Customer C ON O.CustomerID = C.CustomerID
INNER JOIN SalesLT.Address A ON O.ShipToAddressID = A.AddressID 
WHERE A.StateProvince = 'Utah';


SELECT C.CustomerID, C.CompanyName, A.StateProvince, A.CountryRegion, O.SalesOrderID, O.OrderDate
FROM SalesLT.SalesOrderHeader O 
INNER JOIN SalesLT.Customer C ON O.CustomerID = C.CustomerID
INNER JOIN SalesLT.Address A ON O.ShipToAddressID = A.AddressID
WHERE A.StateProvince IN ('California', 'Utah')
ORDER BY C.CustomerID, O.SalesOrderID; 
GO

UPDATE STATISTICS SalesLT.Customer
UPDATE STATISTICS SalesLT.SalesOrderHeader
