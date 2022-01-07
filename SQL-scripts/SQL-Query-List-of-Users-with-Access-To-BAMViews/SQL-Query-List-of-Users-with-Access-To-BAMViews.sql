-- =================================================================================================================
-- Author:		Sandro Pereira
-- Create date: 2022/01/07
-- Description:	SQL Server Query that provides a list of users access to a specific or to all BAM Views
-- =================================================================================================================

WITH Query AS (
SELECT
    [UserName] = CASE dbprinc.[type]
                    WHEN 'S' THEN dbprinc.[name]
                    WHEN 'U' THEN dbusrlogin.[name] COLLATE Latin1_General_CI_AI
                 END,
    [UserType] = CASE dbprinc.[type]
                    WHEN 'S' THEN 'SQL User'
                    WHEN 'U' THEN 'Windows User'
                 END,
    [DatabaseUserName] = dbprinc.[name],
    [Role] = null,
    [PermissionType] = dbperm.[permission_name],
    [PermissionState] = dbperm.[state_desc],
    [ObjectType] = obj.type_desc,
    [ObjectName] = OBJECT_NAME(dbperm.major_id)
FROM
    sys.database_principals dbprinc WITH(NOLOCK) --> User database
LEFT JOIN
    sys.login_token dbusrlogin WITH(NOLOCK) --> Login accounts
		ON dbprinc.[sid] = dbusrlogin.[sid] 
LEFT JOIN
    sys.database_permissions dbperm WITH(NOLOCK) --> Permissions database
		ON dbperm.[grantee_principal_id] = dbprinc.[principal_id] 
LEFT JOIN
    sys.objects obj WITH(NOLOCK) --> All objects
		ON dbperm.[major_id] = obj.[object_id]
WHERE
    dbprinc.[type] in ('S','U')
UNION
-- List all access provisioned to a sql user or windows user/group through a database or application role
SELECT
    [UserName] = CASE dbmemberprinc.[type]
                    WHEN 'S' THEN dbmemberprinc.[name]
                    WHEN 'U' THEN dbusrlogin.[name] COLLATE Latin1_General_CI_AI
                 END,
    [UserType] = CASE dbmemberprinc.[type]
                    WHEN 'S' THEN 'SQL User'
                    WHEN 'U' THEN 'Windows User'
                 END,
    [DatabaseUserName] = dbmemberprinc.[name],
    [Role] = dbroleprinc.[name],
    [PermissionType] = dbperm.[permission_name],
    [PermissionState] = dbperm.[state_desc],
    [ObjectType] = obj.type_desc,
    [ObjectName] = OBJECT_NAME(dbperm.major_id)
FROM
    sys.database_role_members dbmembers WITH(NOLOCK) --> Role/member associations
JOIN
    sys.database_principals dbroleprinc WITH(NOLOCK) --> Roles
		ON dbroleprinc.[principal_id] = dbmembers.[role_principal_id]
JOIN
    sys.database_principals dbmemberprinc WITH(NOLOCK) --> Role members (database users)
		ON dbmemberprinc.[principal_id] = dbmembers.[member_principal_id]
LEFT JOIN
    sys.login_token dbusrlogin WITH(NOLOCK) --> Login accounts
		ON dbmemberprinc.[sid] = dbusrlogin.[sid]
LEFT JOIN
    sys.database_permissions dbperm WITH(NOLOCK) --> Permissions
		ON dbperm.[grantee_principal_id] = dbroleprinc.[principal_id]
LEFT JOIN
    sys.objects obj WITH(NOLOCK) --> All objects
		ON dbperm.[major_id] = obj.[object_id]
UNION
-- List all access provisioned to the public role, which everyone gets by default
SELECT
    [UserName] = '{All Users}',
    [UserType] = '{All Users}',
    [DatabaseUserName] = '{All Users}',
    [Role] = dbroleprinc.[name],
    [PermissionType] = perm.[permission_name],
    [PermissionState] = perm.[state_desc],
    [ObjectType] = obj.type_desc,
    [ObjectName] = OBJECT_NAME(perm.major_id)
FROM
    sys.database_principals dbroleprinc WITH(NOLOCK) --> Roles
LEFT JOIN
    sys.database_permissions perm WITH(NOLOCK) --> Role permissions
		ON perm.[grantee_principal_id] = dbroleprinc.[principal_id]
JOIN
    sys.objects obj WITH(NOLOCK) --> All objects
		ON obj.[object_id] = perm.[major_id]
WHERE
    --Only roles
    dbroleprinc.[type] = 'R' AND
    --Only public role
    dbroleprinc.[name] = 'public' AND
    --Only objects of ours, not the MS objects
    obj.is_ms_shipped = 0
)
SELECT * From  Query
-- All Views
WHERE ObjectType like 'View'
-- Specific View
--WHERE Role like '%view-name%' AND ObjectType like 'View'

