# BizTalk 2006: Cleaning MarkLog Tables According to Some of the Best Practices
This script Applies to:
* Microsoft BizTalk Server 2006

All the BizTalk database which is being backed up by the 'Backup BizTalk Server' job has one table called “MarkLog”. These tables are holding all the transaction marks (they are actually timestamps in a string format), set to a specific database, created by the 3th step (MarkAndBackUpLog) of the 'Backup BizTalk Server' job. This step, MarkAndBackupLog, is responsible for marking the logs for backup, and then backing them up. So each time this step runs, by default each 15 minutes, a string is stored on that table with the following naming convention:
* Log_<yyyy>_<MM>_<dd>_<HH>_<mm>_<ss>_<fff>

Unfortunately BizTalk has no out-of-the-box possibilities to clean up these tables. And the normal procedure is to run the terminator tool to clean it up which means that we need to stop our environment, i.e., downtime in our integration platform.

And if we look at the description of this “PURGE Marklog table” task in the Terminator Tool, it says that this operation calls a SQL script that cleans up everything in Marklog table – and maybe this is not a best practices!

## Best Practices
Is these information (timestamps) useful for BizTalk Administrators? Should I clean all the data inside this tables or should I maintain a history?

For the same reason that we maintain a Backup history in the Adm_BackupHistory table controlled by the step “Clear Backup History” of the 'Backup BizTalk Server' job. This information is important for example to keep an eye on the backup/log shipping history records to see whether the back is working correctly and data/logs are restored correctly in the stand by environment. The information on the MarkLog tables are also useful for the BizTalk Administration team!

So as long as the MarkLog tables have the same info (data from the same dates) as the backup job days to keep you can safely delete the rest of the information.

As a best practices: you should respect the @DaysToKeep parameter that you specify in the “Clear Backup History” step of the 'Backup BizTalk Server' job.

And this is why that in my opinion, you shouldn’t use the Terminator tool to perform this operation!

Is safe to clean this information in runtime?

The rows in the Marklog table are not “required” and can be cleaned whenever you want as long the BizTalk Backup Job is not running.

 Special thanks for Tord Glad Nordahl for reviewing and all the feedback, and to my friends at DevScope Rui Romano and Pedro Sousa for the helping me developing this SQL Query.
 
THIS SQL SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Us
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)