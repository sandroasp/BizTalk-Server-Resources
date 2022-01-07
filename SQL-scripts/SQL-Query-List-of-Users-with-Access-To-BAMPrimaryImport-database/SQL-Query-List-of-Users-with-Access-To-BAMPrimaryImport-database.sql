-- =================================================================================================================
-- Author:		Sandro Pereira
-- Create date: 2022/01/07
-- Description:	SQL Server Query that provides a list of users that has access to the BAMPrimaryImport database
-- =================================================================================================================

USE BAMPrimaryImport
GO

SELECT Name, SUser_SName(SID) as UserAccount 
FROM sysusers WITH(NOLOCK)
WHERE ISLogin = 1 AND issqluser = 0 AND isntuser = 1
