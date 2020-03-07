SELECT 
	CalcValues.PrincipalName,
    CalcValues.PrincipalType,
    CalcValues.ClassDescription,
    CalcValues.SchemaName,
    CalcValues.EntityName,
    CalcValues.ColumnName,
    CalcValues.PermissionName,
    CalcValues.PermissionState
	--,CalcGrantDenyRevoke.GrantDenyStatement
	--,CalcGrantDenyRevoke.RevokeStatement
FROM sys.database_permissions dper
JOIN sys.database_principals dp ON dper.grantee_principal_id = dp.principal_id
CROSS APPLY (
	SELECT dp.name COLLATE DATABASE_DEFAULT AS PrincipalName
		,dp.type_desc COLLATE DATABASE_DEFAULT AS PrincipalType
		,CASE 
			WHEN dper.class_desc = N'OBJECT_OR_COLUMN' AND dper.minor_id = 0 THEN 'OBJECT'
			WHEN dper.class_desc = N'OBJECT_OR_COLUMN' AND dper.minor_id != 0 THEN 'COLUMN'
			WHEN dper.class_desc = N'DATABASE_PRINCIPAL'
				THEN (
					SELECT CASE WHEN dp2.type = 'A' THEN 'APPLICATION ROLE' ELSE 'DATABASE_PRINCIPAL' END
					FROM sys.database_principals dp2
					WHERE dp2.principal_id = dper.major_id
				)
			ELSE dper.class_desc
			END COLLATE DATABASE_DEFAULT AS ClassDescription
			/*
			--ToDo Finish up gettting all of the items on this list into here
			DATABASE
			OBJECT_OR_COLUMN
			SCHEMA
			DATABASE_PRINCIPAL
			ASSEMBLY
			TYPE
			XML_SCHEMA_COLLECTION
			MESSAGE_TYPE
			SERVICE_CONTRACT
			SERVICE
			REMOTE_SERVICE_BINDING
			ROUTE
			FULLTEXT_CATALOG
			SYMMETRIC_KEYS
			CERTIFICATE
			ASYMMETRIC_KEY
			*/
		, CASE  
			WHEN dper.class_desc = N'SCHEMA'
				THEN (
					SELECT s1.name 
					FROM sys.schemas s1
					WHERE s1.schema_id = dper.major_id 
						AND dper.minor_id = 0)
			WHEN dper.class_desc = N'OBJECT_OR_COLUMN'
				THEN (
					SELECT s3.name
					FROM sys.all_objects o3
					JOIN sys.schemas s3 ON s3.schema_id = o3.schema_id
					WHERE dper.major_id = o3.object_id
				)
			WHEN dper.class_desc = N'TYPE'
				THEN (
					SELECT s4.name
					FROM sys.types ty
					JOIN sys.schemas s4 ON s4.schema_id = ty.schema_id
					WHERE dper.major_id = ty.user_type_id
				)
			END AS SchemaName
		, CASE  
			WHEN dper.class_desc = N'OBJECT_OR_COLUMN'
				THEN (
					SELECT o3.name
					FROM sys.all_objects o3
					JOIN sys.schemas s3 ON s3.schema_id = o3.schema_id
					WHERE dper.major_id = o3.object_id
				)
			WHEN dper.class_desc = N'TYPE'
				THEN (
					SELECT ty.name
					FROM sys.types ty
					JOIN sys.schemas s4 ON s4.schema_id = ty.schema_id
					WHERE dper.major_id = ty.user_type_id
				)
			WHEN dper.class_desc = N'DATABASE_PRINCIPAL'
				THEN (
					SELECT dp2.name
					FROM sys.database_principals dp2
					WHERE dp2.principal_id = dper.major_id
				)
			END COLLATE DATABASE_DEFAULT AS EntityName
		, CASE  
			WHEN dper.class_desc = N'OBJECT_OR_COLUMN'
				AND dper.minor_id > 0
				THEN (
					SELECT ac3.name
					FROM sys.all_objects o3
					JOIN sys.schemas s3 ON s3.schema_id = o3.schema_id
					JOIN sys.all_columns ac3 ON ac3.object_id = o3.object_id
					WHERE dper.major_id = o3.object_id
					AND ac3.column_id = dper.minor_id
				)
			END AS ColumnName
		,dper.permission_name COLLATE DATABASE_DEFAULT AS PermissionName
		,dper.state_desc COLLATE DATABASE_DEFAULT AS PermissionState
) CalcValues
CROSS APPLY (
	SELECT 
		CalcValues.PermissionState + ' '
		+ CalcValues.PermissionName
		+ISNULL(' ON ' 
			+NULLIF(CalcValues.ClassDescription,'DATABASE')
			+ISNULL('::'
				+ISNULL(QUOTENAME(CalcValues.SchemaName),'')
				+CASE WHEN CalcValues.SchemaName IS NOT NULL AND CalcValues.EntityName IS NOT NULL THEN '.' ELSE '' END
				+ISNULL(QUOTENAME(CalcValues.EntityName),'')
				+ISNULL('('+CalcValues.ColumnName+')',''),''),'')
			+' TO '+QUOTENAME(CalcValues.PrincipalName) AS GrantDenyStatement
		,'REVOKE '
		+ CalcValues.PermissionName
		+ISNULL(' ON ' 
			+NULLIF(CalcValues.ClassDescription,'DATABASE')
			+ISNULL('::'
				+ISNULL(QUOTENAME(CalcValues.SchemaName),'')
				+CASE WHEN CalcValues.SchemaName IS NOT NULL AND CalcValues.EntityName IS NOT NULL THEN '.' ELSE '' END
				+ISNULL(QUOTENAME(CalcValues.EntityName),'')
				+ISNULL('('+CalcValues.ColumnName+')',''),''),'')
			+' TO '+QUOTENAME(CalcValues.PrincipalName) AS RevokeStatement
) CalcGrantDenyRevoke
WHERE CalcValues.PrincipalName <> 'public'
AND CalcValues.PermissionName <> 'CONNECT'
