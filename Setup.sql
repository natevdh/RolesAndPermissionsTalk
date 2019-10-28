/*
	Makes a presumption that you have the latest World Wide Importers DB: https://docs.microsoft.com/en-us/sql/samples/wide-world-importers-oltp-install-configure?view=sql-server-ver15
	And it is restored as [WideWorldImporters-Full]
*/


GO
CREATE LOGIN [BasicExample] WITH PASSWORD=N'mypassword', DEFAULT_DATABASE=[WideWorldImporters-Full], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
CREATE LOGIN [SalesManagerExample] WITH PASSWORD=N'mypassword', DEFAULT_DATABASE=[WideWorldImporters-Full], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
CREATE LOGIN [MideastSalesExample] WITH PASSWORD=N'mypassword', DEFAULT_DATABASE=[WideWorldImporters-Full], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
CREATE LOGIN [NewEnglandSalesExample] WITH PASSWORD=N'mypassword', DEFAULT_DATABASE=[WideWorldImporters-Full], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
CREATE LOGIN [MultiSalesExample] WITH PASSWORD=N'mypassword', DEFAULT_DATABASE=[WideWorldImporters-Full], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF
GO
CREATE USER [BasicExample] FROM LOGIN [BasicExample]
GO
CREATE USER [SalesManagerExample] FROM LOGIN [SalesManagerExample]
GO
CREATE USER [MideastSalesExample] FROM LOGIN [MideastSalesExample]
GO
CREATE USER [NewEnglandSalesExample] FROM LOGIN [NewEnglandSalesExample]
GO
CREATE USER [MultiSalesExample] FROM LOGIN [MultiSalesExample]
GO

CREATE Role [Sales Manager]
GO
CREATE ROLE [SalesDept]
GO
DROP SECURITY POLICY [Application].[FilterCustomersBySalesTerritoryRole]
GO
CREATE OR ALTER FUNCTION [Application].[DetermineCustomerAccess](@CityID INT)
RETURNS TABLE
WITH SCHEMABINDING
AS
RETURN (SELECT 1 AS AccessResult
        WHERE IS_ROLEMEMBER(N'db_owner') <> 0
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


CREATE TYPE dbo.UniqueINTs AS TABLE (
	ID INTEGER PRIMARY KEY
)