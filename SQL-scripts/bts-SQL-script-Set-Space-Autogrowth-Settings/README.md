# Pre-allocate space and define auto-growth settings for BizTalk Server databases
Auto growth setting plays an important role in BizTalk configuration for performance reasons, why?

SQL Server database auto-growth is a blocking operation which hinders BizTalk Server database performance. When SQL Server increases the size of a file, it must first initialize the new space before it can be used. This is a blocking operation that involves filling the new space with empty pages.

Therefore it's recommended to:
* Set this value (databases auto-growth) to a fixed value of megabytes instead of to a percentage, so SQL server doesn't waste is resources expanding the data and log files during heavy processing. This is especially true for the MessageBox and Tracking (DTA) databases:
  * In a high throughput BizTalk Server environment, the MessageBox and Tracking databases can significantly increase. If auto-growth is set to a percentage, then auto-growth will be substantial as well.
  * As a guideline for auto-growth, for large files increment should be no larger than 100 MB, for medium-sized files 10 MB, or for small files 1 MB.
  * This should be done so that, if auto-growth occurs, it does so in a measured fashion. This reduces the likelihood of excessive database growth.
* Also allocate sufficient space for the BizTalk Server databases in advance to minimize the occurrence of database auto-growth.

## How can I implement these optimizations?
The execution of this SQL script will set automatically the values for all BizTalk Server databases according to what is recommended. Not only the auto-growth property but also the database and log file size:
* **BizTalkDTADb (BizTalk Tracking database)**: Data file having a file size of 2 GB with 100 MB growth and a log file of 1 GB with 100 MB growth.
* **BizTalkMgmtdb (BizTalk Management database)**: Data file having a file size of 512 MB with 100 MB growth and a log file of 512 MB with 100 MB growth.
* **SSODB (SSO database)**: Data file having a file size of 512 MB with 100 MB growth and a log file of 512 MB with 100 MB growth.
* **BizTalkMsgBoxDb (BizTalk MessageBox database)**: Data file having a file size of 2 GB with 100 MB growth and a log file of 2 GB with 100 MB growth.
* **BAMPrimaryImport (BAM Primary Import database)**: Data file having a file size of 150 MB with 10 MB growth and a log file of 150 MB with 100 MB growth.
* **BAMArchive (BAM Archive)**: Data file having a file size of 70 MB with 10 MB growth and a log file of 200 MB with 10 MB growth.
* **BizTalkRuleEngineDb (Rule Engine database)**: Data file with 1 MB growth and a log file with 1 MB growth.

**Note**: These values ​​were used for a standalone environment. In a high throughput BizTalk Server environment you should consider devide the BizTalkMsgBoxDb in 8 data files, each having a file size of 2 GB with 100 MB growth and a log file of 20 GB with 100 MB growth. Because the BizTalk MessageBox databases are the most active, we recommend you place the data files and transaction log files on dedicated drives to reduce the likelihood of problems with disk I/O contention, as is explained here: http://msdn.microsoft.com/en-us/library/ee377048.aspx
 
THIS SQL SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)