# PowerShell to configure Default Dynamic Send Port Handlers for each Adapter
Since BizTalk Server 2013 we have available a new feature: Configurable Dynamic Send Port Handler. Which means that, when we are creating a Dynamic Send Port, an adapter Send Handler can be configurable for every installed adapter, by default it uses the default send handler associated in each adapter. This Includes both One-Way and Solicit-Response Dynamic Ports. 

However, this new features also brings us some setbacks, special for BizTalk Administrators, for example:
* When we are installing a new environment, if we install the EDI features, this will add a dynamic port call “ResendPort” (don’t need to describe the propose of this port) and the default send handler for each adapter will be the “BizTalkServerApplication”;
  * If we create different or dedicated handlers for each functionality, for example receive handlers, send handlers, process handlers and so on; and if we want to delete the “BizTalkServerApplication” as a send handler for each adapter…  we can’t, we first need to:
    * Manually reconfigure the default Dynamic Send port handlers for each dynamic port first, configuring them with the new default send handler;
    * and then manually delete the “BizTalkServerApplication” as a send handler for each adapter;
* And so on;

All of these tasks are time consuming, and to be fair, they are a little boring to do after we know how to do it manually;

## So how can we automate tasks?

Using PowerShell is a good option.

Windows PowerShell is a Windows command-line shell designed especially for system administrators and can be used by BizTalk administrators to help them in automating repetitive tasks or tasks that are time consuming to perform manually.

This is a simple script that allows you to configure the default send handlers associated with all the existing Dynamic Send ports in your environment.

THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)