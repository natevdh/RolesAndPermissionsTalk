
CREATE OR ALTER VIEW [Website].[Customers_WithRoles]
AS
SELECT s.CustomerID,
       s.CustomerName,
       c.CityName AS CityName,
	   sp.SalesTerritory
FROM Sales.Customers AS s
JOIN [Application].Cities AS c ON s.DeliveryCityID = c.CityID
JOIN Application.StateProvinces sp ON sp.StateProvinceID = c.StateProvinceID
where (
	IS_ROLEMEMBER('Sales Manager') = 1
	OR IS_ROLEMEMBER('db_owner') = 1
	OR (
		IS_ROLEMEMBER('Mideast Sales') = 1
		AND sp.SalesTerritory = 'Mideast'
	)
	OR (
		IS_ROLEMEMBER('New England Sales') = 1
		AND sp.SalesTerritory = 'New England'
	)
)
GO
--As Myself
SELECT * FROM [WideWorldImporters-Full].[Website].[Customers_WithRoles]
GO
GRANT SELECT ON [Website].[Customers_WithRoles] TO [SalesDept]
GO


EXECUTE AS USER='NewEnglandSalesExample'
GO
SELECT * FROM [WideWorldImporters-Full].[Website].[Customers_WithRoles]
GO
REVERT
GO


EXECUTE AS USER='MideastSalesExample'
GO
SELECT * FROM [WideWorldImporters-Full].[Website].[Customers_WithRoles]
GO
REVERT
GO

EXECUTE AS USER='MultiSalesExample'
GO
SELECT * FROM [WideWorldImporters-Full].[Website].[Customers_WithRoles]
GO
REVERT
GO

EXECUTE AS USER='SalesManagerExample'
GO
SELECT * FROM [WideWorldImporters-Full].[Website].[Customers_WithRoles]
GO
REVERT
GO








/*
	Security Policies
	Database -> Security -> Security Policies
*/
GO
ALTER   FUNCTION [Application].[DetermineCustomerAccess](@CityID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN (SELECT 1 AS AccessResult
        WHERE IS_ROLEMEMBER(N'db_owner') <> 0
		OR IS_ROLEMEMBER('Sales Manager') = 1
        OR IS_ROLEMEMBER((SELECT sp.SalesTerritory
                          FROM [Application].Cities AS c
                          INNER JOIN [Application].StateProvinces AS sp
                          ON c.StateProvinceID = sp.StateProvinceID
                          WHERE c.CityID = @CityID) + N' Sales') <> 0
	   );
GO







DROP SECURITY POLICY [Application].[FilterCustomersBySalesTerritoryRole]
GO
ALTER   FUNCTION [Application].[DetermineCustomerAccess](@CityID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN (SELECT 1 AS AccessResult
        WHERE IS_ROLEMEMBER(N'db_owner') <> 0
		OR IS_ROLEMEMBER('Sales Manager') = 1
        OR IS_ROLEMEMBER((SELECT sp.SalesTerritory
                          FROM [Application].Cities AS c
                          INNER JOIN [Application].StateProvinces AS sp
                          ON c.StateProvinceID = sp.StateProvinceID
                          WHERE c.CityID = @CityID) + N' Sales') <> 0
	   );
GO
CREATE SECURITY POLICY [Application].[FilterCustomersBySalesTerritoryRole] 
ADD FILTER PREDICATE [Application].[DetermineCustomerAccess]([DeliveryCityID]) ON [Sales].[Customers],
ADD BLOCK PREDICATE [Application].[DetermineCustomerAccess]([DeliveryCityID]) ON [Sales].[Customers] AFTER UPDATE
WITH (STATE = ON, SCHEMABINDING = ON)
GO
EXECUTE AS USER='SalesManagerExample'
GO
SELECT * FROM [WideWorldImporters-Full].[Website].[Customers_WithRoles]
GO
REVERT
GO






/*
	filtering column data
*/
CREATE OR ALTER VIEW [Website].[Customers_WithRoles]
AS
SELECT s.CustomerID,
       s.CustomerName,
       c.CityName AS CityName,
	   sp.SalesTerritory,
	   CASE WHEN IS_ROLEMEMBER('Sales Manager') = 1 OR IS_ROLEMEMBER('db_owner') = 1 THEN s.IsOnCreditHold ELSE NULL END AS IsOnCreditHold,
	   CASE WHEN IS_ROLEMEMBER('Sales Manager') = 1 OR IS_ROLEMEMBER('db_owner') = 1 THEN s.PhoneNumber ELSE '(###) ###-'+RIGHT(s.PhoneNumber,4) END AS PhoneNumber
FROM Sales.Customers AS s
JOIN [Application].Cities AS c ON s.DeliveryCityID = c.CityID
JOIN Application.StateProvinces sp ON sp.StateProvinceID = c.StateProvinceID
where (
	IS_ROLEMEMBER('Sales Manager') = 1
	OR IS_ROLEMEMBER('db_owner') = 1
	OR (
		IS_ROLEMEMBER('Mideast Sales') = 1
		AND sp.SalesTerritory = 'Mideast'
	)
	OR (
		IS_ROLEMEMBER('New England Sales') = 1
		AND sp.SalesTerritory = 'New England'
	)
)
GO

GO --Execute as self
SELECT * FROM [WideWorldImporters-Full].[Website].[Customers_WithRoles]
GO



EXECUTE AS USER='MultiSalesExample'
GO
SELECT * FROM [WideWorldImporters-Full].[Website].[Customers_WithRoles]
GO
REVERT
GO







/*
Dynamic Data Masking. 
- Not covered in the talk because if a person has direct access to a database they can bypass parts of it. 
- More info see this link https://docs.microsoft.com/en-us/sql/relational-databases/security/dynamic-data-masking?view=sql-server-ver15
*/