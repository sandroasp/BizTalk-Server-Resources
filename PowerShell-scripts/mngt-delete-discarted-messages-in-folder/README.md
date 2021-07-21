# Delete Discarted messages from local folders using PowerShell
Windows PowerShell is a Windows command-line shell designed especially for system administrators. It includes an interactive prompt and a scripting environment that can be used independently or in combination. PowerShell can be used by BizTalk administrators to help them in automating tasks and monitor certain resources or operations.

Many times in BizTalk Server, depending on several scenarios, like:
* Testing
* Certain part of the application are not yet ready to production
* or even discarted unwanted messages
we want/need to create a send port and subscribe certain messages to be discarded on a folder, otherwise, they will get stuck on the administration console and we don't want that.

The problem is that after a while the folder will get a huge amount of messages and writing a large number of files to disk will get progressively slower as the number of files in the target directory gets large. This is because your computer’s operating system must keep track of all of the files in a directory. Even bulk deleting all of these files will take a longer time. Moving or deleting files from the target directory on a regular basis will ensure that the performance is not adversely affected.<br>A large number of small files make more impact than a small number of large files, and most of the time, BizTalk Server consumes/produces small messages. At some point you may completely fill the hard drive, which is more critical.

With this script you can easily configure the folders and the type of files you want to monitor and delete from.

This will help BizTalk Administrators to take full control of their environments
 
THIS POWERSHELL SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)