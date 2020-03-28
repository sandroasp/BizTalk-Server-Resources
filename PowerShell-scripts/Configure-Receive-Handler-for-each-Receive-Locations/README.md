# PowerShell to Configure Receive Handlers from existing Receive locations
When we are configuring/optimizing a new environment, if some features are installed like EDI features or RosettaNet Accelerator, if we create different or dedicated host and host instances for each functionality, for example a host instance for receive, send, process (orchestrations), tracking and so on; of course then we need to associate them as a specific handler of each adapter (receive or send handler) and if we want to delete the “BizTalkServerApplication” as a receive handler from each adapter… we can’t!

This happens because, at least, both EDI and RosettaNet will create during the installation some Receive Ports. And all these ports, by default during the installation, are configured with the only existing Receive handler available at the time: “BizTalkServerApplication”.

To accomplish the task of deleting “BizTalkServerApplication” as a receive handler of each adapter, we need to:

Manually reconfigure the Receive handler for each the existing receive location first, configuring them with the new Receive Handler;
and then manually delete the “BizTalkServerApplication” as a Receive handler for each adapter; 
All of these tasks are time consuming, and to be fair, they are a little boring to do after we know how to do it manually;

## So how can we automate tasks?
Using PowerShell is a good option.

Windows PowerShell is a Windows command-line shell designed especially for system administrators and can be used by BizTalk administrators to help them in automating repetitive tasks or tasks that are time consuming to perform manually.

This is a simple script that allows you to configure the receive handlers associated with all the existing Receive Ports in your environment that are using the SQL Adapter, but this can be easily changed to cover all the Receive Locations independently of the configured adapter.

THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)