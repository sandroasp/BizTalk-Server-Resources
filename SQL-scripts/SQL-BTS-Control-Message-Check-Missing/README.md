# BizTalk Server: SQL Query to fix Control Message Check Missing Restart Msg in Spool table
It's not normal to happen but in some cases we may get this error: Control Message Check Missing Restart Msg in Spool table (can prevent some svc instances to be resumed, terminated or suspended).

This query will solve the issue by adding the missing control flags.
 
THIS SQL SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)