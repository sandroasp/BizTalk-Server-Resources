# Enumerate BizTalk Processes
To debug BizTalk external assemblies or pipeline components, you must attach the Visual Studio debugger to the correct host process. For In-Process hosts, attach to BTSNTSvc.exe (check the PID if multiple hosts are running). For Isolated hosts (HTTP, SOAP, WCF), attach to w3wp.exe (IIS). This guide ensures you hit your breakpoints every time by identifying the right process for your specific component.

This tool allows you to identify the process ID of all running BizTalk hosts.

THIS TOOL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)