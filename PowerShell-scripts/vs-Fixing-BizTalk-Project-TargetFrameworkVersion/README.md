# Visual Studio: Fixing BizTalk Project Target Framework Version with PowerShell

## Introduction
All versions of BizTalk Server supports different versions of .Net Framework. One of the key pieces while migrating projects is to migrate the .Net Framework associated in the project. While bts projects automatically update the framework while you open for the first time in Visual Studio, csharp project doesn't do the same. So we need to go one by one and update the target framework.

This seems a slight and easy task but now imagine that you have almost 200 projects inside a unique Visual Studio Solution!

With this PowerShell you will be able to automatically update all projects to the desire Targer Framework and avoid spending numerous hours doing this task manually.

THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)