# BizTalk Server: SQL Script to delete all BizTalk Server SQL Server Agent jobs
Uninstalling (removing) BizTalk Server does not remove SQL databases, SQL Server roles, SQL Server Agent jobs, SQL Server Integration Services Packages, SQL Server Analysis Services Databases, the groups that you created during configuration, or any items that you created in Visual Studio .NET. The BizTalk Server directory also preserves any files that you added.

You can manually delete the following BizTalk Server SQL Server Agent jobs when you remove BizTalk Server:
* Backup BizTalk Server (BizTalkMgmtDb)
* CleanupBTFExpiredEntriesJob_BizTalkMgmtDb
* DTA Purge and Archive (BizTalkDTADb)
* MessageBox_DeadProcesses_Cleanup_BizTalkMsgBoxDb
* MessageBox_Message_Cleanup_BizTalkMsgBoxDb
* MessageBox_Message_ManageRefCountLog_BizTalkMsgBoxDb
* MessageBox_Parts_Cleanup_BizTalkMsgBoxDb
* MessageBox_UpdateStats_BizTalkMsgBoxDb
* Monitor BizTalk Server (BizTalkMgmtDb)
* Operations_OperateOnInstances_OnMaster_BizTalkMsgBoxDb
* PurgeSubscriptionsJob_BizTalkMsgBoxDb
* Rules_Database_Cleanup_BizTalkRuleEngineDb
* TrackedMessages_Copy_BizTalkMsgBoxDb

Or you can use this SQL Server script to delete all the BizTalk Server SQL Server Agent jobs.

**Note**: A number of BizTalk Server databases still exists, including also a BAM Analysis database and several SQL Server Integration Services packages, that you also need to remove.
 
THIS SQL SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)
