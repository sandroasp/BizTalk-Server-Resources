# Obtain a list of BizTalk Software Inventory installed with PowerShell
It’s always good to know what software is installed in our environment. Sometimes we need to know what version of BizTalk is installed or what version of the Adapter Pack, x86 or x64?

And preferably be able to get this list in an easy and automated way.

This is my first version of this script and I will present how we can accomplish this using PowerShell.

Result sample:

Caption:  Microsoft BizTalk Server Best Practices Analyzer
Description:  Microsoft BizTalk Server Best Practices Analyzer
Installation Date:  20110819
Installation Location:  C:\Program Files (x86)\BizTalkBPA\
Name:  Microsoft BizTalk Server Best Practices Analyzer
Version:  1.2.133.0
Vendor:  Microsoft Corporation

Caption:  Microsoft BizTalk Server 2010
Description:  Microsoft BizTalk Server 2010
Installation Date:  20120229
Installation Location:  C:\Program Files (x86)\Microsoft BizTalk Server 2010\
Name:  Microsoft BizTalk Server 2010
Version:  3.9.469.0
Product Edition:  Developer
Vendor:  Microsoft Corporation

Caption:  Microsoft BizTalk Adapter Pack
Description:  Microsoft BizTalk Adapter Pack
Installation Date:  20120430
Installation Location:  C:\Program Files (x86)\Microsoft BizTalk Adapter Pack\
Name:  Microsoft BizTalk Adapter Pack
Version:  3.5.6527.0
Vendor:  Microsoft Corporation

Caption:  Microsoft BizTalk Adapter Pack(x64)
Description:  Microsoft BizTalk Adapter Pack(x64)
Installation Date:  20120430
Installation Location:  C:\Program Files\Microsoft BizTalk Adapter Pack(x64)\
Name:  Microsoft BizTalk Adapter Pack(x64)
Version:  3.5.6527.0
Vendor:  Microsoft Corporation

I hope you find it useful.
 
THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)