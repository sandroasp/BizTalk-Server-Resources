# How to set SQL Server Network Protocols in the SQL Server for BizTalk Server Databases with PowerShell
Windows PowerShell is a Windows command-line shell designed especially for system administrators. It includes an interactive prompt and a scripting environment that can be used independently or in combination. PowerShell can be used by BizTalk administrators to help them in automating tasks and monitor certain resources or operations.

How to configure SQL Server Network Protocols in the SQL Server that houses BizTalk Server databases with PowerShell
All network protocols are installed by SQL Server Setup, but may or may not be enabled. And you need to be aware that this protocols can have impact in your BizTalk Environment, for example:

Under certain stress conditions (such as clients accessing SQL Server from the same computer), the SQL Server Shared Memory protocol may lower BizTalk Server performance.
BizTalk Server loses connectivity with a remote SQL Server computer that houses the BizTalk Server databases and this may happen if the necessary protocols for SQL Server are not enabled.
So normally we need to perform the following configuration:
* Disable the “Shared Memory” and “VIA” protocols
* And Enable the “TCP/IP” and “Named Pipes” protocols

## How can I configure SQL Server Network Protocols with PowerShell?
This is a simple script to configure SQL Server Network Protocols for SQL Server that houses BizTalk Server databases. ND Because after we correctly set up the protocols, we need to restart the SQL services for the changes to take effect, this script additional also restart all the services and also BizTalk Services if they exist! However this last part is optional.

THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)