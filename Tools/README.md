# BizTalk Server: Tools and Utilities
This is a list of small tools, utilities available for you to use along with BizTalk Server to perform a variety of functions/tasks. Or resources to support external tools for BizTalk Server.

## BizTalk360 Monitor BRE Undeployed policies alarm
[BizTalk360](https://www.biztalk360.com/) offers a tool for BizTalk Administrators to monitor a BizTalk Solution by running database queries that can be evaluated against a defined threshold and receive alerts when the query does not return the expected values. The administrators can set the warning and error condition values in BizTalk360. In addition, they also need to provide the SQL Instance Name and the Database Name where the query will be executed and can target any database. The database query monitoring requires queries that return a scalar value such as string, integer or Boolean. Once the query is saved, BizTalk360 checks for the query result and alerts the administrator when the value exceeds the threshold range.

This JSON file configuration contains all the configurations for you to create an alarm and two database queries with a defined threshold that in case on not being in an expected state will notify you that there are BRE Policies, highest versions, that aren’t in the deployed state.

## BizTalk360 Database Query to monitor BRE in Saved state
[BizTalk360](https://www.biztalk360.com/) offers a tool for BizTalk Administrators to monitor a BizTalk Solution by running database queries that can be evaluated against a defined threshold and receive alerts when the query does not return the expected values. The administrators can set the warning and error condition values in BizTalk360. In addition, they also need to provide the SQL Instance Name and the Database Name where the query will be executed and can target any database. The database query monitoring requires queries that return a scalar value such as string, integer or Boolean. Once the query is saved, BizTalk360 checks for the query result and alerts the administrator when the value exceeds the threshold range.

This Database Query is able Dto monitor BRE in Saved state and it can be used on BizTalk360 Alarms.

## BizTalk360 Secure SQL Server Query to check BRE that are not in a Deployed state
[BizTalk360](https://www.biztalk360.com/) allows you to create “Secure SQL Queries” that allow us to: Write optimized SQL queries and store them with friendly names in BizTalk360, Assign who will have permissions to run the queries and run the queries, of course

This SQL Query will allow us to easily check if any policy is in a non-compliance state.

## BizTalk Documenter tool: Cover Customization Resources
The BizTalk Documenter has been available for many years and different BizTalk versions, starting with 2004 to the latest one: BizTalk Server 2016. And once again, without a doubt for me, BizTalk Documenter is my favorite documentation tool, and I do think that if each product had a tool like for the generation of technical documentation, it would be simpler to do, as the existing documentation significantly improved.

These are the resources you need to customize the cover page.

## Configuration file to install Excel 2016 with Office 2016 Deployment Tool
In previous Office versions, such as Office 2010 or 2013, Microsoft used to provide traditional MSI (Windows Installer) that allowed Office users to select, at the time of installation, the desired Office programs available in the Office suite so that the Office setup wizard installs only selected programs oin their computers or servers. However, with Office 2016 version, Microsoft has started using a new virtualization technology called "Click-to-Run" or "C2R Installer" to distribute Office setup and installation files.

Fortunately, Microsoft provides a separate official tool called "Office 2016 Deployment Tool" for us to be able to customize the “Click-to-Run” installer options so that you can force the installer to install only the desired Office programs.With the help of this tool, you can download Office setup files at your desired location and then configure the installer to install your selected Office apps only. You can also select which language should be installed and also customize lots of setup options. This configuration will allow you to install the Excel only.

## BizTalk Server 2013 R2: Fix for SSO Configuration Application MMC Snap-In
BizTalk Server leverages the Enterprise Single Sign-On (SSO) capabilities for securely storing critical information such as secure configuration properties (for example, the proxy user ID, and proxy password) for the BizTalk adapters. Therefore, BizTalk Server requires SSO to work properly. BizTalk Server automatically installs SSO on every computer where you install the BizTalk Server runtime.

However since 2009 that Microsoft released a MMC snap-in to tackle this exact issue: SSO Configuration Application MMC Snap-In provides the ability to add and manage applications, add and manage key value pairs in the SSO database, as well as import and export configuration applications so that they can be deployed to different environment.
Unfortunately this tool will, or may, not work properly in BizTalk Server 2013 R2, at least running in Windows Server 2012 R2. At the first sight it seems that everything is working properly but when you try to create a key value pair you will see that nothing happens and no key is created, or only a few of them are created. I had a environment in which I was only able to create two keys, after that, the keys did not appear.

To fix this issue I recompile the SSOMMCSnapIn.dll using the latest version of “Microsoft.EnterpriseSingleSignOn.Interop.dll”. You just need to overlap the existing file, normally prsent in "C:\Program Files (x86)\Microsoft Services\SSO Application Configuration\" folder with this version.

## BizTalk Monitor Suspend Instance Terminator Service


THESE TOOLS/RESOURCES ARE PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)