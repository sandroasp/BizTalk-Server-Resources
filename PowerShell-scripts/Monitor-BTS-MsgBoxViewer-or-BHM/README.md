# How to schedule MBV or BHM and customize notification alerts with PowerShell
There are several ways that you can integrate and schedule Message Box Viewer or BizTalk Health Monitor, since Message Box Viewer (aka MBV) is deprecated, and it is now replaced by BizTalk Health Monitor (aka BHM).
* The first option is to use BHM itself, for that, if you have BHM integrated with BizTalk Administration Console.
* The second option is, for example, to use BizTalk360
* and so on...

However, I want to full customize my notification warnings and I want to receive an email notification if:
* Critical Warnings are raised 
* and non-Warnings are raised

but in some environments, special in small or test environments, I know that BizTalk machines are not fully configured as High Availability or according to all the best performance. These are limitations that we need to live with it sometimes.

Which leads us to each time that the report is generated, we need to made a review to the report and analyze the real and the “false” warnings, special the non-critical warnings.

With this script you can be able to easily monitor the health of your BizTalk environment (engine and architecture) by scheduling Message Box Viewer(MBV) or BizTalk Health Monitor (BHM) and customize alerts using PowerShell.

Only if the script finds any critical warning (there are no conditions in critical warnings) or any non-critical warning that is not expected (what I may consider a “false” or expected warning) a mail notification will be sent.

Additional, if a notification mail is sent, I will also want to send the completed report (compressed) attached to the email. 

This script allows you to set:
* Set your email notification settings 
* Set location settings – the location of the tool and where the reports are saved can be different
* Critical errors we want to be notified (in this case all of them)

THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)