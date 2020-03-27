# BizTalk Server Databases: SQL Query to repair all databases in Suspect mode
**Note**: This script actually works with all types of SQL Server databases, it doesn't necessary required to be a BizTalk Server database.

Sometimes, we come across numerous critical situations like when SQL Server database go into suspect mode. And if you have a database in MS SQL that is tagged as (suspect) and you are unable to connect to the database.

This can happen for severa reasons:
* The database could have become corrupted. 
* There is not enough space available for the SQL Server to recover the database during startup. 
* The database cannot be opened due to inaccessible files or insufficient memory or disk space. 
* The database files are being held by operating system, third party backup software etc. 
* There was an unexpected SQL Server Shutdown, power failure or a hardware failure.

being in the Suspect mode means that:
* At least the primary filegroup is suspect and may be damaged. 
* The database cannot be recovered during startup of SQL Server. 
* The database is unavailable. 
* And that additional action by the user is required to resolve the problem.

This script will execute the necessary steps to recover all the database marked as SUSPECT. 
 
THIS SQL SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)