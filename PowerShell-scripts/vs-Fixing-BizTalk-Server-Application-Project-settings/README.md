# Visual Studio: Fixing BizTalk Server Application Project setting with PowerShell

## Introduction
BizTalk Server Application Project project don't automatically migrate from BizTalk Server 2016 to 2020.
The .btaproj struct file is the same from BizTalk Server 2016 to BizTalk Server 2020, but inside the following configurations are different:
 - The property Project > PropertyGroup > CustomProjectExtensionsPath
  - 2016 has: $(BTSINSTALLPATH)\Developer Tools\BuildSystem\
  - 2020 needs to be: $(MSBuildExtensionsPath)\Microsoft\BizTalk\BuildSystem\
 - The property Project > Import
  - 2016 has: 
   - Project="$(CustomProjectExtensionsPath)CustomProject.Default.props"
   - Project="$(CustomProjectExtensionsPath)CustomProject.props"
   - Project="$(CustomProjectExtensionsPath)CustomProjectCs.targets"
  - 2020 needs to be:
   - Project="$(CustomProjectExtensionsPath)CustomProject.Default.props"
   - Project="$(CustomProjectExtensionsPath)CustomProject.props"
   - Project="$(CustomProjectExtensionsPath)CustomProject.targets"

This script automatically solve all those issues.

THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)