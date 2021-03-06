USE [BizTalkMgmtDb]
GO
/****** Object:  StoredProcedure [dbo].[sp_DeleteBackupHistoryAndMarkLogsHistory]    Script Date: 22/05/2014 17:59:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[sp_DeleteBackupHistoryAndMarkLogsHistory] @DaysToKeep smallint = null, @UseLocalTime bit = 0
AS
 BEGIN
	set nocount on
	IF @DaysToKeep IS NULL OR @DaysToKeep <= 0
		RETURN
	/*
		Only delete full sets
		If a set spans a day such that some items fall into the deleted group and the other don't don't delete the set
		
		Delete history only if history of full Backup exists at a later point of time
		why: history of full backup is used in sp_BackupAllFull_Schedule to check if full backup of databases is required or not. 
		If history of full backup is not present, job will take a full backup irrespective of other options (frequency, Backup hour)
	*/
		
	declare @PurgeDateTime datetime
	if (@UseLocalTime = 0)
		set @PurgeDateTime = DATEADD(dd, -@DaysToKeep, GETUTCDATE())
	else
		set @PurgeDateTime = DATEADD(dd, -@DaysToKeep, GETDATE())
	
	DELETE [dbo].[adm_BackupHistory] 
	FROM [dbo].[adm_BackupHistory] [h1]
	WHERE 	[BackupDateTime] < @PurgeDateTime
	AND	[BackupSetId] NOT IN ( SELECT [BackupSetId] FROM [dbo].[adm_BackupHistory] [h2] WHERE [h2].[BackupSetId] = [h1].[BackupSetId] AND [h2].[BackupDateTime] >= @PurgeDateTime)
	AND EXISTS( SELECT TOP 1 1 FROM [dbo].[adm_BackupHistory] [h2] WHERE [h2].[BackupSetId] > [h1].[BackupSetId] AND [h2].[BackupType] = 'db')


	/**************************************************************************************************** 
        Delete all the non referenced MarkLog rows in the BizTalk group.
        These rows are not removed by default.
        
        The logic for cursors and realservername is "stolen" from the BizTalk procedure sp_MarkBTSLogs.
        The cursor iterates all the databases that are backed up by BizTalk.
    ****************************************************************************************************/
	declare @localized_string_sp_DeleteBackupHistoryAndMarkLogsHistory_Failed_sp_GetRemoteServerNameFailed nvarchar(128)
	set @localized_string_sp_DeleteBackupHistoryAndMarkLogsHistory_Failed_sp_GetRemoteServerNameFailed = N'sp_GetRemoteServerName failed to resolve server name %s'  
	declare @localized_string_sp_DeleteBackupHistoryAndMarkLogsHistory_Failed_Deleting_Mark nvarchar(128)
	set @localized_string_sp_DeleteBackupHistoryAndMarkLogsHistory_Failed_Deleting_Mark = N'Failed running the deleting mark log proc on %s'

    DECLARE @BackupServer sysname, @BackupDB sysname, @RealServerName sysname, @errorDesc nvarchar(128)
    DECLARE @tsql nvarchar(1024)
    DECLARE @ret int, @error int

    /* Create a cursor */
    DECLARE BackupDB_Cursor insensitive cursor for
        SELECT    ServerName, DatabaseName
        FROM    admv_BackupDatabases
        ORDER BY ServerName

    open BackupDB_Cursor
    fetch next from BackupDB_Cursor into @BackupServer, @BackupDB
    WHILE (@@FETCH_STATUS = 0)
        BEGIN
            -- Get the proper server name
            EXEC @ret = sp_GetRemoteServerName @ServerName = @BackupServer, @DatabaseName = @BackupDB, @RemoteServerName = @RealServerName OUTPUT

			IF @@ERROR <> 0 OR @ret IS NULL OR @ret <> 0 OR @RealServerName IS NULL OR len(@RealServerName) <= 0
			BEGIN
				SET @errorDesc = replace( @localized_string_sp_DeleteBackupHistoryAndMarkLogsHistory_Failed_sp_GetRemoteServerNameFailed, N'%s', @BackupServer )
				RAISERROR( @errorDesc, 16, -1 )
				GOTO FAILED
			END
            
            /* Create the delete statement */
            select @tsql =
			'DELETE FROM [' + @RealServerName + '].[' + @BackupDB + '].[dbo].[MarkLog]
			WHERE DATEDIFF(day, REPLACE(SUBSTRING([MarkName],5,10),''_'',''''), GETDATE()) > ' + cast(@DaysToKeep as nvarchar(5) )
            
            /* Execute the delete statement */
            EXEC (@tsql)
			SELECT @error = @@ERROR   
			IF @error <> 0 or @ret IS NULL or @ret <> 0
			BEGIN
		     	SELECT @errorDesc = replace( @localized_string_sp_DeleteBackupHistoryAndMarkLogsHistory_Failed_Deleting_Mark, '%s', @BackupServer + N'.' + @BackupDB )
				GOTO FAILED     
			END
            
            /* Get the next DB. */
            fetch next from BackupDB_Cursor into @BackupServer, @BackupDB
        END
        
    close BackupDB_Cursor
	deallocate BackupDB_Cursor
	GOTO DONE
FAILED:	
	SET @ret = -1
	RAISERROR( @errorDesc, 16, -1 )
	
	GOTO DONE
DONE:	
	RETURN @ret
END
