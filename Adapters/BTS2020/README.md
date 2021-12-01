# BizTalk Server Adapters

## File-Z Adapter
The native FILE adapter released with BizTalk eats all zero-byte (empty) files without triggering any associated processes. This behaviour, according to Microsoft, is by design. Though you can argue that it is not consistent how empty files are treated by different adapters, e.g. FTP adapter can transfer empty files with no problem.

What we want here is to have a file adapter that works exactly like the FTP Adapter, i.e., pick up the empty files and trigger a process. This is what File-Z Adapter does.

## File-RADITZ Adapter
The native FILE adapter released with BizTalk eats all zero-byte (empty) files without triggering any associated processes. This behaviour, according to Microsoft, is by design. Though you can argue that it is not consistent how empty files are treated by different adapters, e.g. FTP adapter can transfer empty files with no problem.

However this behavior can cause problems in certain scenarios. There are system than can create empty files first without locking it, then it grabs the file again and writes some data to it. 
With the defaukt BizTalk Server FILE adapter, the adapter may grab the file AFTER the system creates the empty file but BEFORE the system attempts to write to it, therefor causing integration issues. Or we simple may not want to pick up that files.

The File-RADITZ adapter, is kind of the arch enemy of the File-Z Adapter, this adapter don't pickup or process empty (zero-byte) files.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)
