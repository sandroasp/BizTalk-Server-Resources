# Extract a folder structure and automatically generate a PowerShell script to recreate the folder scturure on a different server with PowerShell

## Introduction
Script to extract a list all subfolders under a target path and generate a PowerShell file containing all the PowerShell commands to recreate the folder structure in a diffent Server.

Sample output into a ps1 file:
	New-Item -ItemType Directory -Path "D:\BiztalkFilePorts\APP1"
	New-Item -ItemType Directory -Path "D:\BiztalkFilePorts\APP2"
	New-Item -ItemType Directory -Path "D:\BiztalkFilePorts\APP3\Inbox"
	New-Item -ItemType Directory -Path "D:\BiztalkFilePorts\APP3\Outbox"
	New-Item -ItemType Directory -Path "D:\BiztalkFilePorts\APP3\Outbox\FLD1"
	New-Item -ItemType Directory -Path "D:\BiztalkFilePorts\APP3\Outbox\FLD2"
	New-Item -ItemType Directory -Path "D:\BiztalkFilePorts\APP4\Inbox"
	New-Item -ItemType Directory -Path "D:\BiztalkFilePorts\APP4\Outbox"
	...


THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)