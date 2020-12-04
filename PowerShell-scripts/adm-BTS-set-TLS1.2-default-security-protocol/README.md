# PowerShell to Configure TLS 1.2 as the default security protocol on BizTalk Server
TLS 1.2 is now fully supported in newer versions of BizTalk Server. This includes all the adapters and accelerators. You can also disable SSL, TLS 1.0, and TLS 1.1 in BizTalk Server. But BizTalk Server came out-of-the-box and works very well with SSL (Secure Socket Layer) 3.0 or TLS (Transport Layer Security) 1.0, and these are the security protocol used. Newer versions of BizTalk Server allow us to use TLS 1.2, but that required extra manual configurations that we need to do in the environment.

This PowerShell is optimized for:
* BizTalk Server 2020
* BizTalk Server 2016

## Specify that the default security protocol on BizTalk Server is TLS 1.2
This PowerShell script will create the necessary DWORD on HKEY_LOCAL_MACHINE to configure TLS 1.2 as the default security protocol and will set the .NET Framework 4.0 to use the latest version of the SecurityProtocol, by creating SchUseStrongCrypto DWORDs for both 32- and 64-bit hosts.

THIS POWERSHELL IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)