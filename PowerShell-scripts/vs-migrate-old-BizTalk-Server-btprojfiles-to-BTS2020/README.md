# Visual Studio: Migrate old BizTalk Server btproj files to BizTalk 2020 with PowerShell

## Introduction
The script translate the relevant information from the old project model into its MSBuild equivalent. That typically includes:
 - ProjectGuid
 - Assembly name
 - Default/root namespace
 - Assembly version information
 - Strong-name configuration
 - Build configurations
 - Output paths
 - Project references
 - Assembly references
 - BizTalk schemas
 - Maps
 - Orchestrations
 - Pipelines
 - Other project files
 - BizTalk-specific build actions
 - Relevant project properties

This script automatically solve all those issues.

THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)