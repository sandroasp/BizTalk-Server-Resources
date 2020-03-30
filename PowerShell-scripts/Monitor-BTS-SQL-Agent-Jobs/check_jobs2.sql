use msdb 
GO

WITH MostRecentSched AS  
 (  
 -- For each job get the most recent scheduled run date (this will be the one where Rnk=1)  
 SELECT job_id, 
		next_scheduled_run_date,
		RANK() OVER (PARTITION BY job_id ORDER BY next_scheduled_run_date DESC) AS Rnk  
 FROM sysjobactivity  
 ) 
 select name [Job Name], 
	next_scheduled_run_date [Next Scheduled Run Date], 
        DATEDIFF(minute, next_scheduled_run_date, SYSDATETIME()) AS [Minutes Delayed],
		CASE WHEN enabled=1 THEN 'Enabled'  
          ELSE 'Disabled'  
        END [Job Status]
from MostRecentSched MRS
JOIN   sysjobs SJ  
ON     MRS.job_id=SJ.job_id
where Rnk=1
	AND name in ('Backup BizTalk Server (BizTalkMgmtDb)', 'CleanupBTFExpiredEntriesJob_BizTalkMgmtDb',
				 'DTA Purge and Archive (BizTalkDTADb)', 'MessageBox_DeadProcesses_Cleanup_BizTalkMsgBoxDb', 
				 'MessageBox_Parts_Cleanup_BizTalkMsgBoxDb','MessageBox_UpdateStats_BizTalkMsgBoxDb',
				 'Monitor BizTalk Server (BizTalkMgmtDb)','Operations_OperateOnInstances_OnMaster_BizTalkMsgBoxDb',
				 'PurgeSubscriptionsJob_BizTalkMsgBoxDb', 'Rules_Database_Cleanup_BizTalkRuleEngineDb',
				 'TrackedMessages_Copy_BizTalkMsgBoxDb')
	AND DATEDIFF(minute, next_scheduled_run_date, SYSDATETIME()) >= 1
order by name, next_scheduled_run_date desc;