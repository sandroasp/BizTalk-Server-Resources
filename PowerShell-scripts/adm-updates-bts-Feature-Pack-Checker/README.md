# Check which BizTalk Server 2016 Feature Packs installed with PowerShell
We cannot rely on documentation if they exist, to be accurate, especially regarding the status of the machines present in the environment that tell us what is installed on the machine or not. This script follows the sequence of scripts that I release in the past to check what Cumulative Updates where installed in the machines. However, Microsoft introduces a new concept within BizTalk Server 2016, it calls Feature Packs.

BizTalk Server 2016 will use Feature Pack (FP) approach to providing new functionalities to the product at a faster pace. Now new features (or at least non-breaking features) will be delivered when they’re ready we no longer need to wait 2 years for the next major release of the product to have new features!

BizTalk Server uses the feature pack to provide improvements, features, and closer integration with Azure. Feature Pack 1 extends functionality in key areas, such as deployment, analytics, and runtime.

Feature Pack’s will be available for Software Assurance customers running BizTalk Server 2016 Developer and Enterprise editions or customers running BizTalk Server 2016 in Azure under an Enterprise Agreement

With this, people in charge of monitoring and maintaining BizTalk Server environments will have to not only check if all the Cumulative Updates (nevertheless, this is the most critical operation) but if their organization decide to install FP, they also need to check if and what feature packs are installed in which machine.

Although it seems simple, this operation is just or more painful to perform as the cumulative updates.

Of course, there are some ways to check that, for example:
* **you can do it manually** by checking “Control Panel\Programs\Programs and Features” and then view the “View Installed Updates”, however, this can be a very annoying task and sometimes time-consuming.
* **you can use Windows Registry** but still if you only want to check what FPs that are installed this will be an annoying and time-consuming task.

Probably there are other ways, nevertheless, I just want a quick and very easy way, because this is a basic and very simple task, to know what are the BizTalk Server 2016 Feature Packs installed like:
* Microsoft BizTalk Server 2016 Feature Pack 1 is installed
* Microsoft BizTalk Server 2016 Feature Pack 2 is installed

So how can we easily automate tasks? and reuse them whenever necessary and at the same time saving significant time for other tasks?

Using PowerShell is a good option. Windows PowerShell is a Windows command-line shell designed especially for system administrators and can be used by BizTalk administrators to help them in automating repetitive tasks or tasks that are time-consuming to perform manually.

This is a simple script that allows you to configure the template name of the cumulative updates, that will change from version to version, and will give you the list of all Feature Packs installed in your machine.
 
THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Us
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)