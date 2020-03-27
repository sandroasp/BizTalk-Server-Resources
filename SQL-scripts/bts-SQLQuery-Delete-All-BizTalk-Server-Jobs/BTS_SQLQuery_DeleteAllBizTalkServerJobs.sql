USE msdb ;  
GO  

EXEC sp_delete_job  
    @job_name = N'Backup BizTalk Server (BizTalkMgmtDb)', @delete_unused_schedule=1 ;  
GO  

EXEC sp_delete_job  
    @job_name = N'CleanupBTFExpiredEntriesJob_BizTalkMgmtDb', @delete_unused_schedule=1 ;  
GO  

EXEC sp_delete_job  
    @job_name = N'DTA Purge and Archive (BizTalkDTADb)', @delete_unused_schedule=1 ;  
GO  

EXEC sp_delete_job  
    @job_name = N'MessageBox_DeadProcesses_Cleanup_BizTalkMsgBoxDb', @delete_unused_schedule=1 ;  
GO  

EXEC sp_delete_job  
    @job_name = N'MessageBox_Message_Cleanup_BizTalkMsgBoxDb', @delete_unused_schedule=1 ;  
GO  

EXEC sp_delete_job  
    @job_name = N'MessageBox_Message_ManageRefCountLog_BizTalkMsgBoxDb', @delete_unused_schedule=1 ;  
GO  

EXEC sp_delete_job  
    @job_name = N'MessageBox_Parts_Cleanup_BizTalkMsgBoxDb', @delete_unused_schedule=1 ;  
GO  

EXEC sp_delete_job  
    @job_name = N'MessageBox_UpdateStats_BizTalkMsgBoxDb', @delete_unused_schedule=1 ;  
GO  

EXEC sp_delete_job  
    @job_name = N'Monitor BizTalk Server (BizTalkMgmtDb)', @delete_unused_schedule=1 ;  
GO  

EXEC sp_delete_job  
    @job_name = N'Operations_OperateOnInstances_OnMaster_BizTalkMsgBoxDb', @delete_unused_schedule=1 ;  
GO  

EXEC sp_delete_job  
    @job_name = N'PurgeSubscriptionsJob_BizTalkMsgBoxDb', @delete_unused_schedule=1 ;  
GO  

EXEC sp_delete_job  
    @job_name = N'Rules_Database_Cleanup_BizTalkRuleEngineDb', @delete_unused_schedule=1 ;  
GO  

EXEC sp_delete_job  
    @job_name = N'TrackedMessages_Copy_BizTalkMsgBoxDb', @delete_unused_schedule=1 ;  
GO  

