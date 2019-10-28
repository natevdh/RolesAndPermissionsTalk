

--Drop Users
DROP USER IF EXISTS [BasicExample] 
GO
DROP USER IF EXISTS [SalesManagerExample] 
GO
DROP USER IF EXISTS [MideastSalesExample]
GO
DROP USER IF EXISTS [NewEnglandSalesExample]
GO
DROP USER IF EXISTS [MultiSalesExample]
GO
--Drop Logins
IF EXISTS (SELECT 1 FROM sys.server_principals sp WHERE sp.name = 'BasicExample')
BEGIN
	DROP LOGIN [BasicExample]
END
GO
IF EXISTS (SELECT 1 FROM sys.server_principals sp WHERE sp.name = 'SalesManagerExample')
BEGIN
	DROP LOGIN [SalesManagerExample]
END
GO

IF EXISTS (SELECT 1 FROM sys.server_principals sp WHERE sp.name = 'MideastSalesExample')
BEGIN
	DROP LOGIN [MideastSalesExample]
END
GO

IF EXISTS (SELECT 1 FROM sys.server_principals sp WHERE sp.name = 'NewEnglandSalesExample')
BEGIN
	DROP LOGIN [NewEnglandSalesExample]
END
GO

IF EXISTS (SELECT 1 FROM sys.server_principals sp WHERE sp.name = 'MultiSalesExample')
BEGIN
	DROP LOGIN [MultiSalesExample]
END
GO

--Drop Custom Roles
DROP ROLE IF EXISTS [Sales Manager]
GO
ALTER ROLE SalesDept DROP MEMBER [Mideast Sales]
GO
ALTER ROLE SalesDept DROP MEMBER [New England Sales]
GO
DROP ROLE IF EXISTS SalesDept
GO
DROP ROLE IF EXISTS BasicRole
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
	    OR (ORIGINAL_LOGIN() = N'Website'
		    AND EXISTS (SELECT 1
		                FROM [Application].Cities AS c
				        INNER JOIN [Application].StateProvinces AS sp
				        ON c.StateProvinceID = sp.StateProvinceID
				        WHERE c.CityID = @CityID
				        AND sp.SalesTerritory = SESSION_CONTEXT(N'SalesTerritory'))));
GO
CREATE SECURITY POLICY [Application].[FilterCustomersBySalesTerritoryRole] 
ADD FILTER PREDICATE [Application].[DetermineCustomerAccess]([DeliveryCityID]) ON [Sales].[Customers],
ADD BLOCK PREDICATE [Application].[DetermineCustomerAccess]([DeliveryCityID]) ON [Sales].[Customers] AFTER UPDATE
WITH (STATE = ON, SCHEMABINDING = ON)
GO

DROP TYPE dbo.UniqueINTs
