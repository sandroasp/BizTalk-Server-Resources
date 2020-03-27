# BizTalk Server: Script to delete BizTalk SQL Server Analysis Services Databases
Uninstalling (removing) BizTalk Server does not remove SQL databases, SQL Server roles, SQL Server Agent jobs, SQL Server Integration Services Packages, SQL Server Analysis Services Databases, the groups that you created during configuration, or any items that you created in Visual Studio .NET. The BizTalk Server directory also preserves any files that you added.

You can manually delete the following BizTalk Server SQL Server Analysis Services Databases when you remove BizTalk Server:
* BAM Analysis database: default database name BAMAnalysis
* Or you can use this script to delete all the BizTalk Server SQL Server Analysis Services Databases.

**Note**: A number of BizTalk Server databases and BizTalk Server-related jobs under SQL Server Enterprise Manager - SQL Server Agent still exists, including several SQL Server Integration Services packages, that you also need to remove.
 
THIS SQL SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Us
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)