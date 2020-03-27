# Configuration file to install Excel 2016 with Office 2016 Deployment Tool
In previous Office versions, such as Office 2010 or 2013, Microsoft used to provide traditional MSI (Windows Installer) that allowed Office users to select, at the time of installation, the desired Office programs available in the Office suite so that the Office setup wizard installs only selected programs oin their computers or servers. However, with Office 2016 version, Microsoft has started using a new virtualization technology called "Click-to-Run" or "C2R Installer" to distribute Office setup and installation files.

The limitation in this new installer technology is that it doesn't allow you to select, at the time of installation, the desired Office programs we want to install, instead, the installer downloads and installs all the Office programs in the Office suite.

Fortunately, Microsoft provides a separate official tool called "Office 2016 Deployment Tool" for us to be able to customize the “Click-to-Run” installer options so that you can force the installer to install only the desired Office programs.With the help of this tool, you can download Office setup files at your desired location and then configure the installer to install your selected Office apps only. You can also select which language should be installed and also customize lots of setup options.

Once you downloaded **Office 2016 Deployment Tool**, run it:
* On the License page, accept the license agreement by selecting “Click here to accept the Microsoft Software License terms” and then click “Continue”. 
* The installer will ask you to select a folder to extract the files. Select any desired folder  
* and it'll extract following 2 files in that folder:
  * **configuration.xml**: this XMLM file will be used to provide all required information to force the installer to install only selected Office programs with predefined things. You can consider this XML file as an automatic answer file which is used in unattended software installations.
  * **setup.exe** 
 
**NOTE**: You can download Office setup files using the Office 2016 Deployment Tool setup.exe file or you can use the Office 2016 ISO file that you might have downloaded previously. may previous download it.

To install Microsoft Office Excel:
* Open the container folder in which you extract the Office 2016 Deployment Tool
* Replace the content of the file available here for download
* Open the folder containing setup.exe and configuration.xml files in a command windows by pressing and holding the SHIFT key on your keyboard, then right-click on empty area in the folder and select the option "Open command window here". 
  * This will open Command Prompt window with the current directory active.
* Finally, to install the Office Excel 2016, you just need to type following command in Command Prompt and press Enter:
  * setup.exe /configure configuration.xmlo 
  * NOTE: you will also have the option “setup.exe /download configuration.xml” to download the required office setup files.

# About Me
**Sandro Pereira** | [DevScope](http://www.devscope.net/) | MVP & MCTS BizTalk Server 2010 | [https://blog.sandro-pereira.com/](https://blog.sandro-pereira.com/) | [@sandro_asp](https://twitter.com/sandro_asp)