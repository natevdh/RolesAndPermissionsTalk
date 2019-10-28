
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
EXECUTE AS USER='MultiSalesExample'
GO
SELECT * FROM [WideWorldImporters-Full].[Website].[Customers_WithRoles]
GO
REVERT
GO