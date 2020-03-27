# BizTalk Server: SQL Script to delete all BizTalk Server databases
Uninstalling (removing) BizTalk Server does not remove SQL databases, SQL Server roles, SQL Server Agent jobs, SQL Server Integration Services Packages, SQL Server Analysis Services Databases, the groups that you created during configuration, or any items that you created in Visual Studio .NET. The BizTalk Server directory also preserves any files that you added.

**Important**: You must remove your BizTalk Server configuration before you delete BizTalk databases. If you do not remove your BizTalk Server configuration before you delete BizTalk databases, the registry keys for the databases are not deleted. For information about removing your BizTalk Server configuration, see Removing the BizTalk Server Configuration.

You can manually delete the following BizTalk Server databases when you remove BizTalk Server:
* **BAM Archive Database**: default database name **BAMArchive**
* **BAM Notification Services Application Database**: default database name **BAMAlertsApplication**
* **BAM Primary Import Database**: default database name **BAMPrimaryImport**
* **BAM Star Schema Database**: default database name **BAMStarSchema**
* **BizTalk Tracking Database**: default database name **BizTalkDTADb**
* **Configuration Database**: default database name **BizTalkMgmtDb**
* **BizTalk MessageBox Database**: default database name **BizTalkMsgBoxDb**
* **Rule Engine Database**: default database name **BizTalkRuleEngineDb**
* **Enterprise Single Sign-On database**: default database name **SSODB**

Or you can use this SQL Server script to delete all the BizTalk Server databases

**Note**: A number of BizTalk Server-related jobs under SQL Server Enterprise Manager - SQL Server Agent still exists, including also a BAM Analysis database and several SQL Server Integration Services packages, that you also need to remove.
 
THIS SQL SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Us
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)