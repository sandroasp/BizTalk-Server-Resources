# PowerShell to Quickly Find Which Windows Event Log a Source Belongs To
When you’re troubleshooting Windows systems, one of the first questions is: which Event Log is this source writing to? Sources like MSSQLSERVER, IIS-IISReset, or your own app’s source don’t always live where you expect. Hunting by hand wastes time—especially on busy servers. Here’s a clean, PowerShell-first approach, plus the gotchas to watch for.

## The fast path: query the provider
Modern eventing exposes providers and their linked logs. This is the quickest and most reliable route as this PowerShell will accomplish.

Why it helps: Get-WinEvent -ListProvider pulls the provider’s metadata, returning every log it writes to (e.g., Application, Microsoft-Windows-* channels). It’s instant, no scanning, and works across classic and newer Windows Eventing channels.

THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)