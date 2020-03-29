# Terminate Suspended (not resumable) Routing Failure Report Instances PowerShell
There are many things to consider when planning this type of installation, often the network infrastructure already exists and BizTalk Server must coexist with other network applications. 

This 145 pages detailed installation document that explains how to install, configure and optimize Microsoft BizTalk Server 2013 R2 on a basic multi-computer running Windows Server 2012 R2. This information will help you to plan the installation and configuration of BizTalk Server 2013 R2, applications and components on which it depends. 

## Contents                                       
* BizTalk Server Installation scenario.
* The need for a Domain Controller - Windows Groups and Service Accounts.
  * Create Domain Groups and Users.
  * Planning the use of a new Organizational Unit.
  * Windows Groups Used In BizTalk Server.
  * IIS_WPG and IIS_IUSRS Group.
  * User and Service Accounts Used In BizTalk Server.
  * Summary of users and Groups Affiliation.
  * SQL Server Service Accounts. 
  * References.
* Preparing Computers for Installation - Important considerations before set up the servers.
  * Change the Machine name.
  * Join the Local Administrators Group.
  * The user running the BizTalk Server configuration must belong…
  * Install Critical Windows Updates.
  * Disable IPv6 (optional).
  * Turn off Internet Explorer Enhanced Security Configuration (optional).
  * Disable User Account Control (optional).
  * Turn Windows Firewall off (optional).
  * Configure Microsoft Distributed Transaction Coordinator (MS DTC).
  * COM+ Network Access considerations.
* Preparing and Install SQL Server 2014 machine.
  * Important considerations before set up the servers.
  * Install SQL Server 2014.
  * Configure SQL Server Database Mail feature.
  * Install Service Pack 1 for Microsoft SQL Server 2014.
  * Configure SQL Server for Remote Connections.
  * Configured SQL Server protocols - Disable the Shared Memory Protocol, Enable TCP/IP and Named Pipes.
  * Configure SQL Server Database Engine to listen on a specific TCP Port (optional).
  * Configure SQL Analysis Server to listen on a specific TCP Port (optional).
  * Configuring Microsoft Distributed Transaction Coordinator (DTC) to work through a firewall or network address translation firewalls (optional).
  * List of ports between BizTalk Server and SQL Server (optional).
  * Configure Firewall on SQL Server machine (optional).
    * Inbound Rules.
    * Outbound Rules.
* Preparing and install prerequisites on BizTalk Server 2013 R2 machine.
  * Important considerations before set up the servers.
  * Enable Internet Information Services.
  * Running the BAM Portal in a 64-bit Environment.
  * Install Windows Identity Foundation (WIF) (optional).
  * Install Microsoft Office Excel 2013 (optional).
  * Install Visual Studio 2013 (optional).
  * Remove Microsoft SQL Server Express.
  * SQL Server Considerations.
  * Install SQL Server 2014 Client Tools.
  * Create SQL Alias to communicate with remote SQL Server using Non-Standard Port (optional).
  * List of ports between SQL Server and BizTalk Server (optional).
  * Configure Firewall on BizTalk Server machine.
    * Inbound Rules.
    * Outbound Rules.
* Testing environment connectivity’s.
  * TCPView.
  * DTCPing.
  * DTCTester.
  * SQL Server 2014 Client Tools.
* Install and configure BizTalk Server 2013 R2 machine.
  * Install BizTalk Server 2013 R2.
  * Verify Your Installation.
  * Configure BizTalk Server.
  * Pin BizTalk Server Administration to taskbar.
  * Validate Mail account used by BizTalk to send BAM Alerts.
  * Install BizTalk Adapter Pack.
  * Microsoft BizTalk Adapter Pack and Microsoft BizTalk Adapter Pack (x64).
  * Steps to install BizTalk Adapter Pack.
  * Add adapters to BizTalk Administration Console.
  * Install Critical Windows Updates and BizTalk Server Cumulative Update Package.
  * Configure BizTalk Server SQL Jobs.
  * How to configure Backup BizTalk Server (BizTalkMgmtDb).
  * How to configure DTA Purge and Archive (BizTalkDTADb).
  * MessageBox_Message_Cleanup_BizTalkMsgBoxDb.
* Optimize the BizTalk Server 2013 R2 environment
  * Deleting BizTalk backup files.
  * Implementing a custom sp_DeleteBackupHistory.
  * Implementing a Maintenance Plan to clean BizTalk Database backup’s files.
  * Pre-allocate space and define auto-growth settings for BizTalk Server databases. 112
  * Configure BizTalk Server Windows Services.
  * Install and configure BizTalk Health Monitor.
  * How to register BizTalk Health Monitor Snap-In.
  * How to integrate BHM Snap-In into BizTalk Admin Console.
  * Install SSO Configuration Application MMC Snap-In
  * Configure BizTalk Jobs History (Microsoft SQL Server Agent job history log).
  * To resize the job history log based on raw size.
  * Force Full Backup BizTalk Server (BizTalkMgmtDb) job.
  * Managing and cleaning BizTalk Server MarkLog database tables.
  * Configure host and Host instances.
  * Power Mode.
  * Consider setting the 'text in row' table option to boost BizTalk Server Performance.
  * How to exploit the Text in Row table option in BizTalk Server.
  * General network TCP settings that can impact BizTalk Server
 
THIS USER GUIDE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Us
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)