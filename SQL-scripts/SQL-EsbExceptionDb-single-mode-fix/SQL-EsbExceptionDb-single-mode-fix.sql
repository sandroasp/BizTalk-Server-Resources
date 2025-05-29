-- =================================================================================================================
-- Author:		Sandro Pereira
-- Create date: 2025/05/29
-- Description:	SQL Server Query that fix EsbExceptionDb single mode state
-- =================================================================================================================

USE master
GO
DECLARE @killProcess varchar(max) = '';
SELECT @killProcess = @killProcess + 'KILL ' + CONVERT(varchar(10), spid) + '; '
FROM master..sysprocesses WHERE spid > 50 AND dbid = DB_ID('EsbExceptionDb')
EXEC(@kill);
 
GO
SET DEADLOCK_PRIORITY HIGH
ALTER DATABASE [EsbExceptionDb] SET MULTI_USER WITH NO_WAIT
ALTER DATABASE [EsbExceptionDb] SET MULTI_USER WITH ROLLBACK IMMEDIATE
GO