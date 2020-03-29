# Visual Studio: Fixing BizTalk Project Signing Properties with PowerShell

## Introduction
In the process of deploying a BizTalk solution, Visual Studio first builds the assemblies. The deployment process requires that each assembly is strongly signed. You can strongly sign your assemblies by associating the project with a strong name assembly key file. If you haven't already done so, before deploying a solution from Visual Studio, use the following procedure to generate a strong name assembly key file and assign it to each project in the solution.

To configure a strong name assembly key file
* In Visual Studio Solution Explorer, right-click the project and then click Properties.
* Click the Signing tab and choose Browse in the Choose a strong name key file drop down box.
* Browse to the key file and click it. Click Open, and then close the project properties.
* Repeat steps 3 through 6 for each project in the solution that you want to deploy using this strong name assembly key file.

This seems a slight and easy task but now imagine that you have almost 200 projects inside a unique Visual Studio Solution!

With this PowerShell you will be able to parameterize all projects inside a Visual Studio Solution running a single line of code and avoid spending numerous hours doing this task manually.

THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)