# Moving an Event Source To a Different/Custom Windows Event Log
Windows PowerShell is a Windows command-line shell designed especially for system administrators. It includes an interactive prompt and a scripting environment that can be used independently or in combination. PowerShell can be used by BizTalk administrators to help them in automating tasks and monitor certain resources or operations.

Many time in BizTalk developers like to write informations that will help them tracking and debuging there orchestrations like:
* Message received
* Message successfully Transformed
* Message sent to external system

The problem using C# code is that by default in the Application Log. Application event log is used to application installed in your server/machine like BizTalk Server to log the exceptions or problems and you should keep it clean. in other to proper monitor and find problems with your environment.

And also this are unnecessary information that are being logged in the Application Log in that don't provide any additional information to BizTalk Administrators.

With this script you can easily move an Event Source To a different or to a Custom Windows Event Log.

This will help BizTalk Administrators to take back control of their environments
 
THIS POWERSHELL & SQL SCRIPT ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)