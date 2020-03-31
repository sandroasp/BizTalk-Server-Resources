# PowerShell to Configure BizTalk Server 2010/2009 Host and Host Instances
One of the tasks that we need to do in all our new BizTalk environment over and over again is creating and configuring the Host, Host Instances and of course the adapter handlers.

This PowerShell is optimized for:
* BizTalk Server 2010
* BizTalk Server 2009

## Best practices for Configuring Hosts and Host Instances
As the official documentation specify, in addition to the high availability aspects of the host instance configuration, you should separate sending, receiving, processing, and tracking functionality into multiple hosts. This provides flexibility when configuring the workload in your BizTalk group and is the primary means of distributing processing across a BizTalk group.

This also allows you to stop one host without affecting other hosts. For example, you may want to stop sending messages to let them queue up in the MessageBox database, while still allowing the inbound receiving of messages to occur.

Separating host instances by functionality also provides some of the following benefits:
* Each host instance has its own set of resources such as memory, handles, and threads in the .NET thread pool.
* Multiple BizTalk Hosts will also reduce contention on the MessageBox database host queue tables since each host is assigned its own work queue tables in the MessageBox database.
* Throttling is implemented in BizTalk Server at the host level. This allows you to set different throttling characteristics for each host.
* Security is implemented at the host level; each host runs under a discrete Windows identity.

However, this also may bring some potential drawbacks if too many host instances are created because each host instance is a Windows service (BTSNTSvc.exe or BTSNTSvc64.exe), which generates additional load against the MessageBox database and consumes computer resources (such as CPU, memory, threads), so you need to be careful.

Normally we read that we need to create at least 4 host instances: sending, receiving, processing, and tracking, but that's not absolutely true because, at least with the newer environments, we typically use 64-bits versions and in this case we also need to create at least one Host Instance that will run on 32-bits because FTP adapter, SQL adapter, POP3 adapter and MIME Decoder on 64-bit host instances is not supported by the product (http://technet.microsoft.com/en-us/library/aa560166.aspx)

We can define that one of the best practices for hosts and host instances is the following:
* **BizTalkServerTrackingHost**: A BizTalk Host that hosts tracking is responsible for moving the DTA and BAM tracking data from the MessageBox database to the BizTalk Tracking (DTA) and BAM Primary Import databases. This movement of tracking data has an impact on the performance of other BizTalk artifacts that are running on the same host that is hosting tracking. Thus, you should use a dedicated host that does nothing but host tracking.
  * Only the option “Allow Host Tracking” must be selected because we only will use this host for tracking.
* **BizTalkServerReceiveHost**: All options (“Allow Host Tracking”, “32-bits only” or “Make this default host in the group”) should be unselected. This host will be responsible for processing messages after they are picked up in a receive location. When a host contains a receiving item, such as a receive location (with a pipeline), the message decoding and decrypting occurs in a pipeline within this host. 
  * All receive handlers, except the isolated ones like SOAP, HTTP, WCF-BasicHttp, WCF-WsHttp or WCF-CustomIsolated and 32-bit adapters (FTP, SQL and POP3) will be configured for this host. This will mean also that all receive locations will run in this host instance.
* **BizTalkServerReceive32Host**: has the same goal as the previous however this must have the “32-bits only” option selected so that we can run the 23-bits adapters.
  * The receive handlers for the FTP, SQL and POP3 adapters will be configured for this host.
* **BizTalkServerSendHost**: All options (“Allow Host Tracking”, “32-bits only” or “Make this default host in the group”) should be unselected. This host will be responsible for processing messages before they are sent out to the send port. When a host contains a sending item, such as a send port, the message signing and encryption occurs in a pipeline within this host.
  * All send handlers, except 32-bit adapters like native SQL and FTP adapter, will be configured for this host. This will mean also that all send ports will run in this host instance.
* **BizTalkServerSend32Host**: has the same goal as the previous however this must have the “32-bits only” option selected so that we can run the 32-bits adapters.
  * The Send handlers for the FTP and SQL adapters will be configured for this host.
* **BizTalkServerApplication**: Only the option “32-bits only” should be select on this host. This host will be responsible for process messages based on the instructions in orchestrations that need to run in 32-bits.
* **BizTalkServerApplication64Host**: Only the option “Make this default host in the group” should be select on this host. This host will be responsible for process messages based on the instructions in all or most common orchestrations. 

## Adapter Handlers
An adapter handler is an instance of a BizTalk host in which the adapter code runs. When you specify a send or receive handler for an adapter you are specifying which host instance the adapter code will run in the context of. An adapter handler is responsible for executing the adapter and contains properties for a specific instance of an adapter.

The default BizTalk Server configuration will only create one in-process host, "BizTalkServerApplication", that will be associated as a receive and send adapter handler for all of the installed adapters, with the exception of HTTP, SOAP, WCF-BasicHttp, WCF-WSHttp and WCF-CustomIsolated  adapter receive handlers that can only be running in an isolated host.

But, for purposes of load balancing, to provide process isolation for a particular adapter handler or to providing High Availability for BizTalk Hosts and according to  best practices we should strategically create dedicated logical hosts to run specific areas of functionality such as tracking, receiving messages, sending messages and processing orchestrations.
 
THIS POWERSHELL IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)