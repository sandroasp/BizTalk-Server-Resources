# WCF-Loopback Adapter
A loopback adapter is simply a two way send adapter that simply returns a copy of the outbound message. It gives you two opportunities to execute pipelines and maps on the way out and when it comes back in without the overhead of some kind of repository. One negative of the loopback adapter is that it’s a solicit response send port. You can’t bind a one way logical port in an orchestration to the send operation of a two way. So you’ll have to use content based routing (CBR) if an orchestration constructs the envelope.

The original version of this adapter was original created by http://synthesisconsulting.net. Unfortunately, not available anymore. This adapter was created from the idea of that previous adapter. 

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)
