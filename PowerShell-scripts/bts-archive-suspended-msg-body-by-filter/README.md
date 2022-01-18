# Save BizTalk Server suspended messages body/payload using filters with PowerShell

Script that, based on a filter set by operator, will retrieve the body/payload of suspended BizTalk Server messages and save it to a specific folder.

To use this script you need to provide two filter parameters:
 * Enter the name of a BizTalk service which caused the suspended messages.
  * You may use wildcards (*) for the remainder of the name
 * Enter key part(s) of the error description for suspended messages. 
  * You may use wildcards (*) for the remainder of the error description. 

Credits to Christian Jakobsson that was the original creater of the first version of this script. 
Note: this versions has several changes.

THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)