# Manage messages being archived locally into the hard drive with PowerShell
**Windows PowerShell** is a Windows command-line shell designed especially for system administrators. It includes an interactive prompt and a scripting environment that can be used independently or in combination. PowerShell can be used by BizTalk administrators to help them in automating tasks and monitor certain resources or operations.

Is very common in integration scenarios to see messages being archived locally into the hard drive - either by using a pipeline component like BizTalk Archiving - SQL and File or by simple using the default functionalities in BizTalk like filters:
*Create a Send Port with a filter expression equal to the name of Receive Port or type of the message you want to archive. 

This can happen for several reasons, for example:
* The messages needs to be archived for legal reasons (normally (recommended) we use an "external" repository - not a local hard drive in the server)
* or because it is practical and useful to have the file so it can easily be reprocessed in case of failure

The common problem with some of these approach is that normally we tend to implement the archive mechanism and we forget to implement a cleaning mechanism and we end up with several problems after a while.

With this script you can be able to automatically monitoring these folders on the servers using PowerShell.

This script allows you to set:
* The numbers of hours, minutes or days that you want to archive the files, leaving only the recent ones – if the creation time of the file is older than this parameter then it will be archived and deleted from the folder
* The directory you want to monitor
* And for each subdirectory it will check if exist files to be archived
  * if so, it will create a zip file, using the 7-zip tool, in a different location “BackupFileWarehouse”
  * otherwise will not create any file and move to the next directory

## Requirements
* 7-Zip utility tool
 
THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Us
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)