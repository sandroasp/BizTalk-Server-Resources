# Configure BizTalk Services to start automatically after a system restart with PowerShell
This is a simple script to configure BizTalk Services and Enterprise Single Sign-On Service to start automatically after a system restart.

By default, the “Startup type” propriety of BizTalk Services and Enterprise Single Sign-On Service are set as “Automatic”, however BizTalk Server services may not start automatically after a system restart, to avoid this behavior you must config the **Startup type** to **Automatic (Delayed Start)** option in this services:
* Enterprise Single Sign-On Service
* and BizTalk Service BizTalk Group : BizTalkServerApplication Service (or services)

THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)