# Visual Studio: Fixing BizTalk Project Deployment Properties with PowerShell

## Introduction
Before you can deploy a solution from Visual Studio into a BizTalk application, you must first set project properties, especially the Server and the Configuration Database. If a solution in Visual Studio contains multiple projects, you must separately configure properties for each project.

To configure project properties you normally need to:
* In Visual Studio Solution Explorer right-click a project for which you want to configure properties, and then click Properties.
* Click the Deployment tab in Project Designer.
* Configure the following project properties 
  * **Application Name**: Name of the BizTalk application to which to deploy the assemblies in this project. If the application already exists, the assemblies will be added to it when you deploy the project. If the application does not exist, the application will be created. If this field is blank, the assemblies will be deployed to the default BizTalk application in the current group. Names that include spaces must be enclosed by double quotation marks (").
  * **Configuration Database**: Name of the BizTalk Management database for the group, BizTalkMgmtDb by default.
  * **Server**: Name of the SQL Server instance that hosts the BizTalk Management database on the local computer. In a single-computer installation, this is usually the name of the local computer.
  * **Redeploy**: Setting this to True (the default) enables you to redeploy the BizTalk assemblies without changing the version number.
  * **Install to Global Assembly Cache**: Setting this to True (the default) installs the assemblies to the Global Assembly Cache (GAC) on the local computer when you install the application. Set this to False only if you plan to use other tools for this installation, such as gacutil.
  * **Restart Host Instances**: Setting this to True automatically restarts all host instances running on the local computer when the assembly is redeployed. If set to False (the default), you must manually restart the host instances when you redeploy an assembly.
  * **Enable Unit Testing**: Specifies whether to enable unit testing for the project.
* and then click OK.
* Repeat steps 1, 2, and 3 for each project in the solution.

This seems a slight and easy task but now imagine that you have almost 200 projects inside a unique Visual Studio Solution!

With this PowerShell you will be able to parameterize all projects inside a Visual Studio Solution running a single line of code and avoid spending numerous hours doing this task manually.

THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)