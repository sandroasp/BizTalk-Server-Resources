# BizTalk Server Adapters

## File-Z Adapter
The native FILE adapter released with BizTalk eats all zero-byte (empty) files without triggering any associated processes. This behaviour, according to Microsoft, is by design. Though you can argue that it is not consistent how empty files are treated by different adapters, e.g. FTP adapter can transfer empty files with no problem.

What we want here is to have a file adapter that works exactly like the FTP Adapter, i.e., pick up the empty files and trigger a process. This is what File-Z Adapter does.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)
