# Check which BizTalk Server 2016 Feature Packs installed with PowerShell
We cannot rely on documentation, if they exist, to be accurate, special regarding to the status of the machines present in the environment that tell us what is installed on the machine, what are the updates (or CU) or service pack installed and so on… and regarding to BizTalk Server I do not remember another simple task like this, get or check the list of all BizTalk Cumulative Updates installed in your machine/environment, being so painful to perform!

Of course, there are some ways to check that, for example:
* **you can do it manually** by checking “Control Panel\Programs\Programs and Features” and then view the “Installed Updates”, however, this can be a very annoying task and sometimes time consuming just to try find them in that huge list because they are not organized in a category BizTalk
* **you can use BizTalk MsgBoxViewer** but still if you only want to check what CU are installed, or you need to analyze your entire system with this tool, or you need to uncheck all the select default queries and check only for the cumulative updates – which can also be an annoying and time consuming task
Probably there are other ways, nevertheless, I just want a quick and very easy way, because this is a basic and very simple task, to know what are the BizTalk Cumulative Updates installed like:

This is the list of BizTalk Cumulative Update installed in this machine: BTS2010LAB01 
- Biztalk Adaptor Framework 2010 CU1 
- Microsoft Biztalk Server 2010 CU1 
- Microsoft BizTalk Server 2010 CU2 
- Microsoft BizTalk Server 2010 CU3 
- Microsoft BizTalk Server 2010 CU4 
- Microsoft Biztalk Server 2010 CU5 
- Microsoft Biztalk Server 2010 CU6

## So how can we easily automate tasks? and reuse them whenever necessary and at the same time saving significant time for other tasks?

Using PowerShell is a good option. Windows PowerShell is a Windows command-line shell designed especially for system administrators and can be used by BizTalk administrators to help them in automating repetitive tasks or tasks that are time consuming to perform manually.

This is a simple script that allows you to configure the template name of the cumulative updates, that will change from version to version, and will give you the list of all cumulative updates installed in your machine.

THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Us
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)