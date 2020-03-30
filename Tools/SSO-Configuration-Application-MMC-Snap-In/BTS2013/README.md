# BizTalk Server 2013: Fix for SSO Configuration Application MMC Snap-In
BizTalk Server leverages the Enterprise Single Sign-On (SSO) capabilities for securely storing critical information such as secure configuration properties (for example, the proxy user ID, and proxy password) for the BizTalk adapters. Therefore, BizTalk Server requires SSO to work properly. BizTalk Server automatically installs SSO on every computer where you install the BizTalk Server runtime.

But it also can keep your own application configuration data in SSO database, let say the usual configurations that we normally keep in a configuration file (“app.config”)). One of the great and useful tool that we normally use for archiving this is a custom tool original created by Richard Seroter, the: SSO Config Data Store Tool.

However since 2009 that Microsoft released a MMC snap-in to tackle this exact issue: SSO Configuration Application MMC Snap-In provides the ability to add and manage applications, add and manage key value pairs in the SSO database, as well as import and export configuration applications so that they can be deployed to different environment.

Unfortunately this tool will, or may, not work properly in BizTalk Server 2013, at least running in Windows Server 2012. At the first sight it seems that everything is working properly but when you try to create a key value pair you will see that nothing happens and no key is created, or only a few of them are created. I had a environment in which I was only able to create two keys, after that, the keys did not appear.

Update: Notice that this issue it’s also documented here https://support.microsoft.com/kb/2954101 (Known issues in BizTalk Server 2013) and you will find different solutions to solve it.

To fix this issue I recompile the SSOMMCSnapIn.dll using the latest version of “Microsoft.EnterpriseSingleSignOn.Interop.dll”. You just need to overlap the existing file, normally prsent in "C:\Program Files (x86)\Microsoft Services\SSO Application Configuration\" folder with this version.

![Fix for SSO Configuration Application MMC Snap-In](media/BizTalk-Server-2013-R2-SSO-App-Snapin.png)

THIS HOTFIX IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)