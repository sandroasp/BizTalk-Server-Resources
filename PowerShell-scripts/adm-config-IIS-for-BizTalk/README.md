# Enable all the requires IIS features for BizTalk Server with PowerShell
Microsoft Internet Information Services (IIS) provides a Web application infrastructure for many BizTalk Server features. BizTalk Server requires IIS for the following features:
* HTTP adapter
* SOAP adapter
* Windows SharePoint Services adapter
* Secure Sockets Layer (SSL) encryption
* BAM Portal

And you can enable this features by using the Server Manager (check BizTalk 2010 Installation and Configuration – Enable Internet Information Services (Part 1))

In alternative you can also enable these features by using PowerShell.

Server Manager’s command-line counterpart is the ServerManager module for Windows PowerShell. Generally, this module is not imported into Windows PowerShell by default. Instead, you need to import the module before you can use the cmdlets it provides. To import the Server Manager module, enter Import-Module ServerManager at the Windows PowerShell prompt. Once the module is imported, you can use it with the currently running instance of Windows PowerShell. The next time you start Windows PowerShell, you’ll need to import the module again if you want to use its features.

You can enable all the requires IIS features for BizTalk Server by using the following script.

Note that you must be running Windows PowerShell with elevated user rights.

THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)