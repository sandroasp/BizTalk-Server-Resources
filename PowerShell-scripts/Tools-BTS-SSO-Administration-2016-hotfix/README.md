# BizTalk Server 2016: PowerShell to fix SSO Administration Console

## SSO Administration Console
You can install the Enterprise Single Sign-On (SSO) Administration component as a stand-alone feature. This is useful if you need to administer the SSO system remotely. The hardware and software requirements are the same as for a typical Enterprise SSO installation.

After you install the administration component, you must use either ssomanage.exe or the SSO Administration MMC Snap-In to specify the SSO server that will be used for management. Both processes are included in the procedure that follows.

Installing the SSO administrative utility (ssomanage.exe) does not create shortcuts on the Start menu that let you access the command-line utilities. To run the SSO administrative utilities after installation, you must open a command prompt and navigate to the SSO directory located at Program Files\Common Files\Enterprise Single Sign-On.

However, SSO Administration shortcut that points to the Microsoft.EnterpriseSingleSignOn.StartMMC.exe executable file is not working properly in BizTalk Server 2016. And the reason why is with BizTalk Server 2016 there is a bug and the installation wizard doesn't create all the necessary key in the Register.

This PowerShell script allow you to fix this bug and put everything working normally again.

THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)