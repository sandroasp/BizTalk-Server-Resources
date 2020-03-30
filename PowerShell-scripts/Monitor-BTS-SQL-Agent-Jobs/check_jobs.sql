use msdb 
GO

WITH MostRecentSched AS  
 (  
 -- For each job get the most recent scheduled run date (this will be the one where Rnk=1)  
 SELECT job_id, 
		last_executed_step_date,
		RANK() OVER (PARTITION BY job_id ORDER BY last_executed_step_date DESC) AS Rnk  
 FROM sysjobactivity  
 ) 
 select name [Job Name], 
	last_executed_step_date [Last Scheduled Run Date], 
        DATEDIFF(minute, last_executed_step_date, SYSDATETIME()) AS [Minutes Delayed],
		CASE WHEN enabled=1 THEN 'Enabled'  
          ELSE 'Disabled'  
        END [Job Status]
from MostRecentSched MRS
JOIN   sysjobs SJ  
ON     MRS.job_id=SJ.job_id
where Rnk=1
and ((
		((name = 'Backup BizTalk Server (BizTalkMgmtDb)' and DATEDIFF(minute, last_executed_step_date, SYSDATETIME()) > 17)) 
		OR (name = 'CleanupBTFExpiredEntriesJob_BizTalkMgmtDb' and DATEDIFF(minute, last_executed_step_date, SYSDATETIME()) > 722) 
		OR (name = 'Monitor BizTalk Server (BizTalkMgmtDb)' and DATEDIFF(minute, last_executed_step_date, SYSDATETIME()) > 11520) 
		OR (name = 'Rules_Database_Cleanup_BizTalkRuleEngineDb' and DATEDIFF(minute, last_executed_step_date, SYSDATETIME()) > 62)
		OR (name = 'MessageBox_UpdateStats_BizTalkMsgBoxDb' and DATEDIFF(minute, last_executed_step_date, SYSDATETIME()) > 7)
		OR (name IN ('DTA Purge and Archive (BizTalkDTADb)','MessageBox_DeadProcesses_Cleanup_BizTalkMsgBoxDb', 'MessageBox_Parts_Cleanup_BizTalkMsgBoxDb', 'Operations_OperateOnInstances_OnMaster_BizTalkMsgBoxDb', 'PurgeSubscriptionsJob_BizTalkMsgBoxDb', 'TrackedMessages_Copy_BizTalkMsgBoxDb') and DATEDIFF(minute, last_executed_step_date, SYSDATETIME()) > 1)
	) OR (name IN ('Backup BizTalk Server (BizTalkMgmtDb)','CleanupBTFExpiredEntriesJob_BizTalkMgmtDb', 
	               'DTA Purge and Archive (BizTalkDTADb)', 'MessageBox_DeadProcesses_Cleanup_BizTalkMsgBoxDb', 
				   'MessageBox_Message_ManageRefCountLog_BizTalkMsgBoxDb', 'MessageBox_Parts_Cleanup_BizTalkMsgBoxDb', 
				   'MessageBox_UpdateStats_BizTalkMsgBoxDb', 'Monitor BizTalk Server (BizTalkMgmtDb)',
				   'Operations_OperateOnInstances_OnMaster_BizTalkMsgBoxDb',
				   'PurgeSubscriptionsJob_BizTalkMsgBoxDb', 'Rules_Database_Cleanup_BizTalkRuleEngineDb',
				   'TrackedMessages_Copy_BizTalkMsgBoxDb') AND SJ.enabled = 0)
	  OR (name = 'MessageBox_Message_Cleanup_BizTalkMsgBoxDb' AND SJ.enabled = 1) 
	)
order by name, last_executed_step_date desc;