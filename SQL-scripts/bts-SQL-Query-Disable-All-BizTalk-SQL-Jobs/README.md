# SQL Query to Disable All BizTalk SQL Server Agent jobs
BizTalk is shipped out with a total of 13 SQL Agent jobs. Two of these jobs must be configured. The two jobs that needs configuration are the two most important jobs. The **Backup BizTalk Server** and the **DTA Purge and Archive**.

Experienced BizTalk professionals know that all the BizTalk SQL Server Agent jobs except the MessageBox_Message_Cleanup_BizTalkMsgBoxDb job should be enabled and running successfully. Besides this job the other jobs should not be disabled!

However one of the most common and important tools to resolve problems that happens in BizTalk Server is the BizTalk Terminator tool (you can know more about this tool here). Terminator provides the easiest way to resolve most of these issues identified by the Monitor BizTalk Server Job.

Nevertheless, before running the Terminator tool, you must always make sure that
* you have a BizTalk Backup of your databases
* all the BizTalk hosts instances have been stopped,
* and all BizTalk SQL Agent jobs have been disabled.

Unfortunately, through SQL Server Management Studio console there is no easy way to disable or enable all jobs, forcing us to go one on one to disable or enable them.

This query will disable all the BizTalk SQL Server Agent jobs (including the MessageBox_Message_Cleanup_BizTalkMsgBoxDb).
 
THIS SQL SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)