# Change the startup type for BizTalk services to Automatic (Delayed Start) with PowerShell

After rebooting the operating system BizTalk Server services can fails to start automatically. This is a Microsoft known Issues with BizTalk Runtime forcing us to manually start the services.
To fix this we should manually configure the Startup type of these services to Automatic (Delayed Start).

This script will automatically go thru all BizTalk Server services installed on the machine and set up the Startup type to Automatic (Delayed Start).

THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)