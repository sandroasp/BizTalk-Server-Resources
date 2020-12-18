# Extract a list of all Private Message Queuing (MSMQ) names to a CSV file with PowerShell

## Introduction
Script to extract a list of all Private Message Queuing (MSMQ) names to a CSV file with PowerShell.

Sample output into a CSV file:
	QueueName                 Transactional UseJournalQueue
	---------                 ------------- ---------------
	private$\sapqueue                  True           False
	private$\opc                       True           False
	private$\trax                      True           False
	private$\sapstocktransfer          True           False
	private$\sapzabl                   True           False
	private$\registoproducao           True           False
	private$\eplantgalvanic            True           False
	private$\stripping                 True           False
	private$\preprocesso               True           False
	private$\assembly                  True           False
	...

THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)