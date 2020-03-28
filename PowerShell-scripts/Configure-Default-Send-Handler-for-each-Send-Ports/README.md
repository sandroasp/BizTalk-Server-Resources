# PowerShell to Configure the Default Send Handler for each static Send Port
When we are configuring/optimizing a new environment, if some features are installed like ESB Toolkit, if we create different or dedicated host and host instances for each functionality, for example a host instance for receive, send, process (orchestrations), tracking and so on; of course then we need to associate them as a specific handler of each adapter (receive or send handler) and if we want to delete the “BizTalkServerApplication” as a Send handler we can't for some adapters!

This happens because during the ESB Toolkit installation it will be created a static send port call “ALL.Exceptions” that connects with SQL “EsbExceptionDb” database. And this port will be configured with the default send handler (at that time) configured in your environment, that is by default the “BizTalkServerApplication”.

To accomplish the task of deleting “BizTalkServerApplication” as a Send handler of each adapter, we need to:

Manually reconfigure the Send handler for each the existing send port first, configuring them with the new or correct Send Handler;
and then manually delete the “BizTalkServerApplication” as a Send handler for each adapter; 
All of these tasks are time consuming, and to be fair, they are a little boring to do after we know how to do it manually;

## So how can we automate tasks?
Using PowerShell is a good option.

Windows PowerShell is a Windows command-line shell designed especially for system administrators and can be used by BizTalk administrators to help them in automating repetitive tasks or tasks that are time consuming to perform manually.

This is a simple script that allows you to configure the Send handler associated with all the existing Static Send Ports in your environment independently of the adapter that is configured:

THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)