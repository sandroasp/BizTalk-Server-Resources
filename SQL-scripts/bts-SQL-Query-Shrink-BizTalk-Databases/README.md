# BizTalk Server Database: SQL Query to Shrink BizTalk Databases
**Run this script wisely and only in case of disaster recovery. This can damage your BizTalk Server environment if not properly used.**

If for some reason, like disaster recovery, you need to shrink BizTalk databases, you should first:
* Do a full backup to BizTalk Databases - Criticality: Extremely important.
* Stop all BizTalk services - Criticality: Extremely important.
* Stop IIS server (run iisreset from start/stop) if you are running any Web Services or WCF - Criticality: Extremely important.
* Disabled all BizTalk SQL Agent jobs - Criticality: Extremely important.

This script will execute the necessary steps to shrink all the databases. It can be change according to your needs. 
 
THIS SQL SCRIPT IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Us
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)