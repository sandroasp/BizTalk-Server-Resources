# PowerShell to Check if Windows Defender is running on the Server
Anti-virus can have a huge impact on BizTalk Server performance and normally the best approach for BizTalk Server environment and anti-virus software is using a perimeter based approach, where you normally don’t run the anti-virus software on the machine itself but protect the boundaries. 

I like to use this approach but if not possible at least you should configure antivirus software to avoid real-time scanning of BizTalk Server executables and file drops. Antivirus software real-time scanning of BizTalk Server executable files and any folders or file shares monitored by BizTalk Server receive locations can negatively impact BizTalk Server performance. If antivirus software is installed on the BizTalk Server computer(s), disable real-time scanning of non-executable file types referenced by any BizTalk Server receive locations (usually .XML, but can also be .csv, .txt, etc.) and configure antivirus software to exclude scanning of BizTalk Server executable Files.

There is also a good blog post from MSFT about Anti-virus exclusions regarding BizTalk Server:
* {BizTalk Server Anti-Virus Exclusions](https://docs.microsoft.com/en-us/archive/blogs/balbir_singh/biztalk-server-anti-virus-exclusions)

However, the first step is to find out if there is any Anti-virus running on your BizTalk Server.

I will not address all the possible existing Anti-virus in the market, instead, here I will focus only in Windows Defender for a simple reason: I have been creating several BizTalk Server DEV environments on Azure using Azure Virtual Machines and by default Windows Defender is configured.

So, I create this simple PowerShell script to use in all my environments just to check the basic environment assessment: to configure the template name of the cumulative updates, that will change from version to version, and will give you the list of all Feature Packs installed in your machine.

![Windows Defender](media/PowerShell-Windows-Defender-running.png)
 
THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Us
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)