/*
	World Wide Importers DB: https://docs.microsoft.com/en-us/sql/samples/wide-world-importers-oltp-install-configure?view=sql-server-ver15
	And it is restored as [WideWorldImporters-Full]
*/

SELECT SUSER_NAME(), USER_NAME()

EXECUTE AS USER = 'BasicExample'
GO
SELECT SUSER_NAME(), USER_NAME()
GO
REVERT



-------
EXECUTE AS USER = 'BasicExample'
GO
SELECT * FROM Application.Cities c
GO
REVERT

-------


GRANT SELECT ON Application.Cities TO BasicExample
GRANT SELECT ON Application.Countries TO BasicExample

EXECUTE AS USER = 'BasicExample'
GO
SELECT * FROM Application.Cities c
GO
REVERT
GO

REVOKE SELECT ON Application.Countries TO BasicExample
----------------

DENY SELECT (Location) ON Application.Cities TO BasicExample

EXECUTE AS USER = 'BasicExample'
GO
SELECT c.CityID,
       c.CityName,
       c.StateProvinceID,
       c.Location,
       c.LatestRecordedPopulation,
       c.LastEditedBy,
       c.ValidFrom,
       c.ValidTo 
FROM Application.Cities c
GO
REVERT

REVOKE SELECT (Location) ON Application.Cities TO BasicExample








GRANT SELECT (Location)  ON Application.Cities TO BasicExample

REVOKE SELECT ON Application.Cities TO BasicExample



GRANT SELECT ON schema::SALES TO BasicExample
GRANT SELECT ON Object::Sales.Orders TO BasicExample
GRANT EXECUTE ON TYPE::dbo.UniqueINTs TO BasicExample