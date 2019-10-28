SELECT 
	per.PrincipalName
    ,per.PrincipalType
    ,per.ClassDescription
    ,per.RelatesTo
    ,per.PermissionName
    ,per.PermissionState  
	,per.PermissionState + ' '+ per.PermissionName + ' ON '+ per.ClassDescription+'::'+REPLACE(QUOTENAME(per.RelatesTo),'.','].[')+' TO '+QUOTENAME(per.PrincipalName) AS RecreateStatement
	,'REVOKE '+ per.PermissionName + ' ON '+ per.ClassDescription+'::'+REPLACE(QUOTENAME(per.RelatesTo),'.','].[')+' TO '+QUOTENAME(per.PrincipalName) AS RevokeStatement
FROM (
	SELECT 
		dp.name AS PrincipalName
		,dp.type_desc AS PrincipalType
		,CASE 
			WHEN dper.class_desc = 'DATABASE' THEN 'Database'
			WHEN dper.class_desc = 'TYPE' THEN 'Type'
			WHEN dper.class_desc = 'OBJECT_OR_COLUMN' AND dper.minor_id = 0 THEN 'Object'
			WHEN dper.class_desc = 'OBJECT_OR_COLUMN' AND dper.minor_id != 0 THEN 'Column'
			ELSE dper.class_desc
			END AS ClassDescription
		,CASE dper.class_desc
			WHEN 'DATABASE' 
				THEN 'Database'
			WHEN 'SCHEMA' 
				THEN (
					SELECT s1.name 
					FROM sys.schemas s1
					WHERE s1.schema_id = dper.major_id 
						AND dper.minor_id = 0)
			WHEN 'OBJECT_OR_COLUMN' 
				THEN 
					CASE 
						WHEN dper.minor_id = 0 AND dper.major_id > 0
							THEN
								(
								SELECT s2.name+N'.'+o2.name 
								FROM sys.objects o2
								JOIN sys.schemas s2 ON s2.schema_id = o2.schema_id
								WHERE dper.major_id = o2.object_id
								)
						WHEN dper.minor_id = 0 AND dper.major_id < 0
							THEN
								(
								SELECT s3.name+N'.'+o3.name 
								FROM sys.system_objects o3
								JOIN sys.schemas s3 ON s3.schema_id = o3.schema_id
								WHERE dper.major_id = o3.object_id
								)
						WHEN dper.minor_id > 0  AND dper.major_id > 0
							THEN
								(
								SELECT s4.name+N'.'+o4.name+N'.'+c4.name 
								FROM sys.objects o4
								JOIN sys.schemas s4 ON s4.schema_id = o4.schema_id
								JOIN sys.columns c4 ON c4.object_id = o4.object_id
								WHERE dper.major_id = o4.object_id
								AND dper.minor_id = c4.column_id
								)
					END
			WHEN 'TYPE'
				THEN (
					SELECT s4.name+'.'+ty.name
					FROM sys.types ty
					JOIN sys.schemas s4 ON s4.schema_id = ty.schema_id
					WHERE dper.major_id = ty.user_type_id
				)
			END  AS RelatesTo
		,dper.permission_name COLLATE Latin1_General_100_CI_AS AS PermissionName
		,dper.state_desc AS PermissionState
		--, dper.*
	FROM sys.database_permissions dper
	JOIN sys.database_principals dp ON dper.grantee_principal_id = dp.principal_id
) per
--While it is important to know what rights public has you can remove them from some of the work
WHERE per.PrincipalName <> 'public'
AND per.PermissionName <> 'CONNECT'
ORDER BY PrincipalType
	,PrincipalName





