# Terminate Suspended (not resumable) Routing Failure Report Instances PowerShell
One of the annoying thing with working with Direct Bound Ports in Orchestrations, in special MessageBox direct bound ports that allow us to easily implement decouple publish-subscribe design patterns, is that you may get a situation in which you get a lot of Routing Failure Report Instances in the state Suspended (not resumable).

Using PowerShell is a good option to delete all of this kind of messages, you can send a report and delete or just simply delete it. Windows PowerShell is a Windows command-line shell designed especially for system administrators and can be used by BizTalk administrators to help them in automating repetitive tasks or tasks that are time-consuming to perform manually.

Because was controlling the error inside the main orchestration I don’t have the need of additional report, so this is a simple script will allow you to delete all Routing Failure Report Instances suspended with the state Suspended (not resumable) from your BizTalk Server environment.
 
THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Us
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)