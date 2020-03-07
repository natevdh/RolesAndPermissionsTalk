ALTER ROLE [Sales Manager] ADD MEMBER [SalesManagerExample]
ALTER ROLE [Mideast Sales] ADD MEMBER [MideastSalesExample]
ALTER ROLE [New England Sales] ADD MEMBER [NewEnglandSalesExample]

SELECT rp.name AS RoleName
	,m.name AS MemberName
	,m.type_desc AS MemberType
FROM sys.database_principals rp
JOIN sys.database_role_members drm ON drm.role_principal_id = rp.principal_id
JOIN sys.database_principals m ON m.principal_id = drm.member_principal_id
WHERE m.name IN ('SalesManagerExample','MideastSalesExample','NewEnglandSalesExample')



ALTER ROLE [New England Sales] ADD MEMBER [MultiSalesExample]
ALTER ROLE [Mideast Sales] ADD MEMBER [MultiSalesExample]

SELECT rp.name AS RoleName
	,m.name AS MemberName
	,m.type_desc AS MemberType
FROM sys.database_principals rp
JOIN sys.database_role_members drm ON drm.role_principal_id = rp.principal_id
JOIN sys.database_principals m ON m.principal_id = drm.member_principal_id
WHERE m.name = 'MultiSalesExample'


ALTER ROLE [SalesDept] ADD MEMBER [Sales Manager]
ALTER ROLE [SalesDept] ADD MEMBER [Mideast Sales]
ALTER ROLE [SalesDept] ADD MEMBER [New England Sales]

SELECT rp.name AS RoleName
	,m.name AS MemberName
	,m.type_desc AS MemberType
FROM sys.database_principals rp
JOIN sys.database_role_members drm ON drm.role_principal_id = rp.principal_id
JOIN sys.database_principals m ON m.principal_id = drm.member_principal_id



EXECUTE AS USER = 'SalesManagerExample'
GO
SELECT * FROM Application.Cities c
GO
REVERT
GO


GRANT SELECT ON Application.Cities TO SalesDept
GO
EXECUTE AS USER = 'SalesManagerExample'
GO
SELECT * FROM Application.Cities c
GO
REVERT
GO