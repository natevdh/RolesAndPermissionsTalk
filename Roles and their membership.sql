SELECT dp.name AS Role
	,dp.type_desc
	,dp.principal_id
FROM sys.database_principals dp
WHERE dp.type_desc IN (
	'DATABASE_ROLE'
)


SELECT rp.name AS RoleName
	,m.name AS MemberName
	,m.type_desc AS MemberType
FROM sys.database_principals rp
JOIN sys.database_role_members drm ON drm.role_principal_id = rp.principal_id
JOIN sys.database_principals m ON m.principal_id = drm.member_principal_id



