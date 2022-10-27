# BizTalk Server: SQL Query to Repair Refcounts issues for All Messages
This script rebuilds all the MessageRefCountLog tables and the MessageZeroSum table to resolve the 'Messages w/out RefCounts' issue that MessageBoxViewer identifies. While doing this, control messages are rebuilt if needed.    

WARNINGS:                                                                                                                     *
 * THIS OPERATION WILL PERMANENTLY REMOVE OR ALTER DATA IN YOUR DATABASE.                                                     *
 * Before running this script make sure that:
  * All BizTalk databases should be backed up
  * All host instances should be stopped
  * All BizTalk SQL Agent jobs should be stopped.  

THIS SQL SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)