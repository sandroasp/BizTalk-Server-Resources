##############################################################################################
# Script to properly configure the BizTalk Server environment according to some of the 
# best practices by separate sending, receiving, processing, and tracking functionality 
# into multiple hosts.
#
# Author: Sandro Pereira
##############################################################################################
[void] [System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.ExplorerOM")

#############################################################
# Global Variables
#############################################################
[string] $bizTalkDbServer = "BTSSQL\INSTANCE"
[string] $bizTalkDbName = "BizTalkMgmtDb"

#############################################################
# This function will create a new BizTalk Host
# HostType: In-process	1, Isolated	2
#############################################################
function CreateBizTalkHost(
    [string]$hostName, 
    [int]$hostType, 
    [string]$ntGroupName, 
    [bool]$authTrusted, 
    [bool]$isTrackingHost, 
    [bool]$is32BitOnly)
{
    try
    {
        [System.Management.ManagementObject]$objHostSetting = ([WmiClass]"root/MicrosoftBizTalkServer:MSBTS_HostSetting").CreateInstance()

        $objHostSetting["Name"] = $hostName
        $objHostSetting["HostType"] = $hostType
        $objHostSetting["NTGroupName"] = $ntGroupName
        $objHostSetting["AuthTrusted"] = $authTrusted
        $objHostSetting["IsHost32BitOnly"] = $is32BitOnly 
        $objHostSetting["HostTracking"] = $isTrackingHost

        $putOptions = new-Object System.Management.PutOptions
        $putOptions.Type = [System.Management.PutType]::CreateOnly;

        [Type[]] $targetTypes = New-Object System.Type[] 1
        $targetTypes[0] = $putOptions.GetType()

        $sysMgmtAssemblyName = "System.Management"
        $sysMgmtAssembly = [System.Reflection.Assembly]::LoadWithPartialName($sysMgmtAssemblyName)
        $objHostSettingType = $sysMgmtAssembly.GetType("System.Management.ManagementObject")

        [Reflection.MethodInfo] $methodInfo = $objHostSettingType.GetMethod("Put", $targetTypes)
        $methodInfo.Invoke($objHostSetting, $putOptions)
		
		Write-Host "Host $hostName was successfully created" -Fore DarkGreen
    }
    catch [System.Management.Automation.RuntimeException]
    {
		if ($_.Exception.Message.Contains("Another BizTalk Host with the same name already exists in the BizTalk group.") -eq $true)
        {
			Write-Host "$hostName can't be created because another BizTalk Host with the same name already exists in the BizTalk group." -Fore DarkRed
        }
		else{
        	write-Error "$hostName host could not be created: $_.Exception.ToString()"
		}
    }
}

#############################################################
# This function will update an existent BizTalk Host
# HostType: Invalid: 0, In-process:	1, Isolated: 2
#############################################################
function UpdateBizTalkHost ( 
    [string]$hostName, 
    [int]$hostType, 
    [string]$ntGroupName, 
    [bool]$authTrusted, 
    [bool]$isTrackingHost, 
    [bool]$is32BitOnly,
	[bool]$isDefaultHost)
{
    try
    {
        [System.Management.ManagementObject]$objHostSetting = ([WmiClass]"root/MicrosoftBizTalkServer:MSBTS_HostSetting").CreateInstance()

        $objHostSetting["Name"] = $hostName
        $objHostSetting["HostType"] = $hostType
        $objHostSetting["NTGroupName"] = $ntGroupName
        $objHostSetting["AuthTrusted"] = $authTrusted
        $objHostSetting["IsHost32BitOnly"] = $is32BitOnly 
        $objHostSetting["HostTracking"] = $isTrackingHost
		$objHostSetting["IsDefault"] = $isDefaultHost

        $putOptions = new-Object System.Management.PutOptions
        $putOptions.Type = [System.Management.PutType]::UpdateOnly; # This tells WMI it's an update.

        [Type[]] $targetTypes = New-Object System.Type[] 1
        $targetTypes[0] = $putOptions.GetType()

        $sysMgmtAssemblyName = "System.Management"
        $sysMgmtAssembly = [System.Reflection.Assembly]::LoadWithPartialName($sysMgmtAssemblyName)
        $objHostSettingType = $sysMgmtAssembly.GetType("System.Management.ManagementObject")

        [Reflection.MethodInfo] $methodInfo = $objHostSettingType.GetMethod("Put", $targetTypes)
        $methodInfo.Invoke($objHostSetting, $putOptions)
		
		Write-Host "Host $hostName was successfully updated" -Fore DarkGreen
    }
    catch [System.Management.Automation.RuntimeException]
    {
        write-Error "$hostName host could not be updated: $_.Exception.ToString()"
    }
}

#############################################################
# This function will create a new BizTalk Host Instance
#############################################################
function CreateBizTalkHostInstance(
	[string]$hostName,
	[string]$serverName,
	[string]$username,
	[string]$password)
{
    try
    {
        [System.Management.ManagementObject]$objServerHost = ([WmiClass]"root/MicrosoftBizTalkServer:MSBTS_ServerHost").CreateInstance()

        $objServerHost["HostName"] = $hostName
        $objServerHost["ServerName"] = $serverName
        $objServerHost.Map()

        [System.Management.ManagementObject]$objHostInstance = ([WmiClass]"root/MicrosoftBizTalkServer:MSBTS_HostInstance").CreateInstance()

        $name = "Microsoft BizTalk Server " + $hostName + " " + $serverName
        $objHostInstance["Name"] = $name
        $objHostInstance.Install($username, $password, $true)

		Write-Host "HostInstance $hostName was mapped and installed successfully. Mapping created between Host: $hostName and Server: $Server);" -Fore DarkGreen
    }
    catch [System.Management.Automation.RuntimeException]
    {
		if ($_.Exception.Message.Contains("Another object with the same key properties already exists.") -eq $true)
        {
			Write-Host "$hostName host instance can't be created because another object with the same key properties already exists." -Fore DarkRed
        }
		else{
        	write-Error "$hostName host instance on server $Server could not be created: $_.Exception.ToString()"
		}
    }
}

#############################################################
# This function will delete an existente host handlers 
# in the adapters.
# [direction]: 'Receive','Send'
#############################################################
function DeleteBizTalkAdapterHandler (
	[string]$adapterName,
	[string]$direction,
	[string]$hostName)
{
	try
    {
		if($direction -eq 'Receive')
		{
			[System.Management.ManagementObject]$objHandler = get-wmiobject 'MSBTS_ReceiveHandler' -namespace 'root\MicrosoftBizTalkServer' -filter "HostName='$hostName' AND AdapterName='$adapterName'"
	        $objHandler.Delete()
		}
		else
		{
			[System.Management.ManagementObject]$objHandler = get-wmiobject 'MSBTS_SendHandler2' -namespace 'root\MicrosoftBizTalkServer' -filter "HostName='$hostName' AND AdapterName='$adapterName'"
	        $objHandler.Delete()
		}
    
		Write-Host "$direction handler for $adapterName / $hostName was successfully deleted" -Fore DarkGreen
    }
    catch [System.Management.Automation.RuntimeException]
    {
        if ($_.Exception.Message -eq "You cannot call a method on a null-valued expression.")
        {
			Write-Host "$adapterName $direction Handler for $hostName does not exist" -Fore DarkRed
        }
        elseif ($_.Exception.Message.IndexOf("Cannot delete a receive handler that is used by") -ne -1)
        {
			Write-Host "$adapterName $direction Handler for $hostName is in use and can't be deleted." -Fore DarkRed
        }
		elseif ($_.Exception.Message.IndexOf("Cannot delete a send handler that is used by") -ne -1)
        {
			Write-Host "$adapterName $direction Handler for $hostName is in use and can't be deleted." -Fore DarkRed
        }
		elseif ($_.Exception.Message.IndexOf("Cannot delete this object since at least one receive location is associated with it") -ne -1)
        {
			Write-Host "$adapterName $direction Handler for $hostName is in use by at least one receive location and can't be deleted." -Fore DarkRed
        }
        else
        {
            write-Error "$adapterName $direction Handler for $hostName could not be deleted: $_.Exception.ToString()"
        }
    }
}

#############################################################
# This function will create a handler for a specific 
# adapter on the new host, so these get used for processing.
# [direction]: 'Receive','Send'
#############################################################
function CreateBizTalkAdapterHandler(
	[string]$adapterName,
	[string]$direction,
	[string]$hostName,
	[string]$originalDefaulHostName,
	[boolean]$isDefaultHandler,
	[boolean]$removeOriginalHostInstance)
{
	if($direction -eq 'Receive')
	{
		[System.Management.ManagementObject]$objAdapterHandler = ([WmiClass]"root/MicrosoftBizTalkServer:MSBTS_ReceiveHandler").CreateInstance()
		$objAdapterHandler["AdapterName"] = $adapterName
	    $objAdapterHandler["HostName"] = $hostName
	}
	else
	{
		[System.Management.ManagementObject]$objAdapterHandler = ([WmiClass]"root/MicrosoftBizTalkServer:MSBTS_SendHandler2").CreateInstance()
		$objAdapterHandler["AdapterName"] = $adapterName
	    $objAdapterHandler["HostName"] = $hostName
	    $objAdapterHandler["IsDefault"] = $isDefaultHandler
	}
		
    try
    {
        $putOptions = new-Object System.Management.PutOptions
        $putOptions.Type = [System.Management.PutType]::CreateOnly;

        [Type[]] $targetTypes = New-Object System.Type[] 1
        $targetTypes[0] = $putOptions.GetType()

        $sysMgmtAssemblyName = "System.Management"
        $sysMgmtAssembly = [System.Reflection.Assembly]::LoadWithPartialName($sysMgmtAssemblyName)
        $objAdapterHandlerType = $sysMgmtAssembly.GetType("System.Management.ManagementObject")

        [Reflection.MethodInfo] $methodInfo = $objAdapterHandlerType.GetMethod("Put", $targetTypes)
        $methodInfo.Invoke($objAdapterHandler, $putOptions)

        Write-Host "$adapterName $direction Handler for $hostName was successfully created" -Fore DarkGreen
    }
    catch [System.Management.Automation.RuntimeException]
    {
		if ($_.Exception.Message.Contains("The specified BizTalk Host is already a receive handler for this adapter.") -eq $true)
        {
			Write-Host "$hostName is already a $direction Handler for $adapterName adapter." -Fore DarkRed
        }
		elseif($_.Exception.Message.Contains("The specified BizTalk Host is already a send handler for this adapter.") -eq $true)
        {
			Write-Host "$hostName is already a $direction Handler for $adapterName adapter." -Fore DarkRed
        }
		else {
        	write-Error "$adapterName $direction Handler for $hostName could not be created: $_.Exception.ToString()"
		}
    }



    if($direction -eq 'Receive')
	{
        # Configure all Existing Receive Ports with the default adapter
        if($removeOriginalHostInstance)
        {
            $questionResultDAConf = $windowsShell.popup("Do you want to configure existing Receive locations handlers for $adapterName adapter?", 
						          0,"No, leave has is",4)
 	
            If ($questionResultDAConf -eq 6) {
	            ConfigureBizTalkAdapterReceiveHandlerInExistingReceiveLocations $adapterName $hostName
            }
        }
	}
	else
	{
        # Configure all Existing Receive Ports with the default adapter
        if($isDefaultHandler)
        {
            $questionResultDAConf = $windowsShell.popup("Do you want to configure existing Send Port handlers for $adapterName adapter?", 
						          0,"No, leave has is",4)
 	
            If ($questionResultDAConf -eq 6) {
	            ConfigureBizTalkAdapterSendHandlerInExistingSendPorts $adapterName $hostName
            }
        }
	}
	
	if($removeOriginalHostInstance)
	{
		DeleteBizTalkAdapterHandler $adapterName $direction $originalDefaulHostName
	}
}


#############################################################
# This function will create a handler for a specific 
# adapter on the new host, so these get used for processing.
# [direction]: 'Receive','Send'
#############################################################
function ConfigureBizTalkAdapterReceiveHandlerInExistingReceiveLocations(
	[string]$adapterName,
	[string]$defaulHostInstanceName)
{
    $catalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
    $catalog.ConnectionString = "SERVER=$bizTalkDbServer;DATABASE=$bizTalkDbName;Integrated Security=SSPI"

    # Let's look for receive handlers associated with the Adapter
    foreach ($handler in $catalog.ReceiveHandlers)
    {
         # if is a the correct Adapter Receive Handler
        if ($handler.TransportType.Name -eq $adapterName)
        {
            if($handler.Name -eq $defaulHostInstanceName)
            {
                foreach($receivePort in $catalog.ReceivePorts)
                {
                    # For each receive location in your environment
                    foreach($recLocation in $receivePort.ReceiveLocations)
                    {
                         # In this case I want only Receive location that are using SQL Adapter
                        if($recLocation.ReceiveHandler.TransportType.Name -eq $adapterName)
                        {
                            $recLocation.ReceiveHandler = $handler
                        }
                    }
                }
            }
        }
    }
    
    $catalog.SaveChanges()
}


function ConfigureBizTalkAdapterSendHandlerInExistingSendPorts(
	[string]$adapterName,
	[string]$defaulHostInstanceName)
{
    $catalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
    $catalog.ConnectionString = "SERVER=$bizTalkDbServer;DATABASE=$bizTalkDbName;Integrated Security=SSPI"


    # Let's look for send handlers associated with Adapter configured in the send port
    foreach ($handler in $catalog.SendHandlers)
    {
        # if the Send Handler is associated with the Adapter configured in the send port
        if ($handler.TransportType.Name -eq $adapterName)
        {
            if($handler.Name -eq $defaulHostInstanceName)
            {
                foreach($SendPort in $catalog.SendPorts)
                {
                    # For each receive location in your environment
                    if($sendPort.IsDynamic -eq $False)
                    {
                        if($sendPort.PrimaryTransport.TransportType.Name -eq $adapterName)
                        {
                            $sendPort.PrimaryTransport.SendHandler = $handler
                        }
                    }
                    if($sendPort.IsDynamic -eq 'True')
                    {
                        # Changing the default send handlers of the dynamic port
                        $sendPort.SetSendHandler($adapterName, $defaulHostInstanceName)
                    }
                }
            }
        }
    }

    $catalog.SaveChanges()
}


#############################################################
# This function will have the logic you want to implement
# to create the default hosts and host instances and add 
# configure the host instances to the various handlers.
# This logic is pre configured with some of the best 
# practices.
#############################################################
function ConfiguringBizTalkServerHostAndHostInstances
{
	# Separate sending, receiving, processing, and tracking functionality into multiple hosts. 
	# This provides flexibility when configuring the workload and enables you to stop one host without affecting other hosts.
	# you can use a common well use convention to define the name of the host:
	#  - <Job>_<bit support>_<seq>_<adapter/functionality>_<throughput>_<priority>_<clustered> 
	# Sample 'Rcv_x32_1_FTP_L_Critical_Clustered'
	# But I will use a more simple convencion
	# Defining the names of the hosts
	[string]$receiveHostName = 'BizTalkServerReceiveHost'  
	[string]$sendHostName = 'BizTalkServerSendHost'
	[string]$processingHostName = 'BizTalkServerApplication64Host' # use this to create another processing host
	[string]$trackingHostName = 'BizTalkServerTrackingHost'
	# Note: why we need to create 32bits hosts? FTP, POP3 and SQL doesn't support 64bits 
	[string]$receive32HostName = 'BizTalkServerReceive32Host'
	[string]$send32HostName = 'BizTalkServerSend32Host'
 
	# 'BizTalkServerApplication' is the default host instance created when you install the biztalk on your box.
	# This application will be running on "32-bit only". 
	[string]$defaultHostName = 'BizTalkServerApplication'
 
 	##############################
	# Creating hosts for receiving
	# HostType: Invalid: 0, In-process:	1, Isolated: 2
	CreateBizTalkHost $receiveHostName 1 $ntHostGroupName $false $false $false
	CreateBizTalkHost $receive32HostName 1 $ntHostGroupName $false $false $true
 
	# Create a host instances for receiving associated with the previous hosts created
	CreateBizTalkHostInstance $receiveHostName $bizTalkServerName $hostCredentials.UserName $hostCredentialsPassword
	CreateBizTalkHostInstance $receive32HostName $bizTalkServerName $hostCredentials.UserName $hostCredentialsPassword
 
	# Set adapters that should be handled by receiving host instance
	CreateBizTalkAdapterHandler 'FILE' 'Receive' $receiveHostName $defaultHostName $false $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'MQSeries' 'Receive' $receiveHostName $defaultHostName $false $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'MSMQ' 'Receive' $receiveHostName $defaultHostName $false $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'WCF-Custom' 'Receive' $receiveHostName $defaultHostName $false $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'WCF-NetMsmq' 'Receive' $receiveHostName $defaultHostName $false $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'WCF-NetNamedPipe' 'Receive' $receiveHostName $defaultHostName $false $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'WCF-NetTcp' 'Receive' $receiveHostName $defaultHostName $false $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'Windows SharePoint Services' 'Receive' $receiveHostName $defaultHostName $false $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'SB-Messaging' 'Receive' $receiveHostName $defaultHostName $false $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'SFTP' 'Receive' $receiveHostName $defaultHostName $false $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'WCF-BasicHttpRelay' 'Receive' $receiveHostName $defaultHostName $false $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'WCF-NetTcpRelay' 'Receive' $receiveHostName $defaultHostName $false $removeOriginalAdapterHandler
	##### Optional LOB Adapters
    CreateBizTalkAdapterHandler 'WCF-SQL' 'Receive' $receiveHostName $defaultHostName $false $removeOriginalAdapterHandler
    CreateBizTalkAdapterHandler 'WCF-SAP' 'Receive' $receiveHostName $defaultHostName $false $removeOriginalAdapterHandler
    CreateBizTalkAdapterHandler 'WCF-OracleDB' 'Receive' $receiveHostName $defaultHostName $false $removeOriginalAdapterHandler
    CreateBizTalkAdapterHandler 'WCF-OracleEBS' 'Receive' $receiveHostName $defaultHostName $false $removeOriginalAdapterHandler
	#####32 bits adapters
	CreateBizTalkAdapterHandler 'FTP' 'Receive' $receive32HostName $defaultHostName $false $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'POP3' 'Receive' $receive32HostName $defaultHostName $false $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'SQL' 'Receive' $receive32HostName $defaultHostName $false $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'WCF-SAP' 'Receive' $receive32HostName $defaultHostName $false $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'WCF-Custom' 'Receive' $receive32HostName $false $false $false
 
 	##############################
	# Creating hosts for sending
	# HostType: Invalid: 0, In-process:	1, Isolated: 2
	CreateBizTalkHost $sendHostName 1 $ntHostGroupName $false $false $false
	CreateBizTalkHost $send32HostName 1 $ntHostGroupName $false $false $true
 
	# Create a host instances for sending associated with the previous hosts created
	CreateBizTalkHostInstance $sendHostName $bizTalkServerName $hostCredentials.UserName $hostCredentialsPassword
	CreateBizTalkHostInstance $send32HostName $bizTalkServerName $hostCredentials.UserName $hostCredentialsPassword
 
	# Set adapters that should be handled by sending host instance
	CreateBizTalkAdapterHandler 'FILE' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'HTTP' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'MQSeries' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'MSMQ' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'SOAP' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'SMTP' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'WCF-BasicHttp' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'WCF-Custom' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'WCF-NetMsmq' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'WCF-NetNamedPipe' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'WCF-NetTcp' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'WCF-WSHttp' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'Windows SharePoint Services' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'SB-Messaging' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'SFTP' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'WCF-BasicHttpRelay' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'WCF-NetTcpRelay' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'WCF-WebHttp' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'WCF-WSHttp' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
    ##### Optional LOB Adapters
    CreateBizTalkAdapterHandler 'WCF-SQL' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
    CreateBizTalkAdapterHandler 'WCF-SAP' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
    CreateBizTalkAdapterHandler 'WCF-OracleDB' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
    CreateBizTalkAdapterHandler 'WCF-OracleEBS' 'Send' $sendHostName $defaultHostName $true $removeOriginalAdapterHandler
	##### 32 bits adapters
	CreateBizTalkAdapterHandler 'FTP' 'Send' $send32HostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'SQL' 'Send' $send32HostName $defaultHostName $true $removeOriginalAdapterHandler
	CreateBizTalkAdapterHandler 'WCF-Custom' 'Send' $send32HostName $false $true $false
	CreateBizTalkAdapterHandler 'WCF-SAP' 'Send' $send32HostName $defaultHostName $true $removeOriginalAdapterHandler
	
	# Create a host for tracking
	CreateBizTalkHost $trackingHostName 1 $ntHostGroupName $false $true $false
	
	# Create a host for orchestrations
	CreateBizTalkHost $processingHostName 1 $ntHostGroupName $false $false $false
 
	# Create a host instance for orchestrations
	CreateBizTalkHostInstance $processingHostName $bizTalkServerName $hostCredentials.UserName $hostCredentialsPassword
 
	# Create a host instance for tracking
	CreateBizTalkHostInstance $trackingHostName $bizTalkServerName $hostCredentials.UserName $hostCredentialsPassword
	
	# Remove "Allow Host Tracking" options from BizTalkServerApplication Host
	UpdateBizTalkHost $defaultHostName 1 $ntHostGroupName $false $false $true $true
	
	# Updating the processinh host to be the default host
	UpdateBizTalkHost $processingHostName 1 $ntHostGroupName $false $false $false $true
}

#############################################################
# Main script logic
#############################################################
Write-Host "Starting configure the BizTalk Server environment..." -Fore DarkGreen

# General variables
# Defining the BizTalk Server Name, this line will read the Server name on which the script is running
$bizTalkServerName = $(Get-WmiObject Win32_Computersystem).name

[string]$bizTalkDbServer = Read-Host -Prompt "Please enter SERVER where BizTalk Server Configuration Database resides (BTSSQL\INSTANCE)" 
$windowsShell = new-object -comobject wscript.shell
$questionResultDB = $windowsShell.popup("Does the BizTalk Server Configuration Database has the default name:  BizTalkMgmtDb?", 
						  0,"No, It has a different name",4)
 	
If ($questionResultDB -eq 6) {
	[string] $bizTalkDbName = "BizTalkMgmtDb"
}
else {
	string] $bizTalkDbName = Read-Host -Prompt "Please enter the name of the BizTalk Server Configuration Database (BizTalkMgmtDb)" 
}


# STEP 1 
# The Windows group is used to control access of a specif host and associated host instances to databases and other 
# resources. Each instance of this host must run under a user account that is a member of this group. 
# Note that you can change the Windows group only if no instances of this host exist. 
# Defining the name of the group the BizTalk hosts should run under
[string]$ntHostGroupName = Read-Host -Prompt "Please enter windows group to control access to Hosts and ssociated Host Instances" 

# STEP 2
# This account must have SQL Server permissions. The recommended way to grant these permissions is to add this account 
# to the BizTalk Server Host Windows group.
# BizTalk Server will add this account to the "Log on as a service" security policy.
# For domain accounts, use "domain\user" format
# Defining the credentials in witch the host instance should run under.
try
{
	$domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
	$domainName = $domain.name
}
catch
{
	$domainName = $(Get-WmiObject Win32_Computersystem).name
}
$hostCredentials = $Host.ui.PromptForCredential("Logon Credentials","This account must have SQL Server permissions. The recommended way to grant these permissions is to add this account to the BizTalk Server Host Windows group.

BizTalk Server will add this account to the 'Log on as a service' security policy", $domainName + "\", "");
[String]$hostCredentialsPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($hostCredentials.Password)); 

# STEP 3
# Defining the option if you want to automatically try to remove the BizTalkServerApplication Host Instance from 
# the Adapters handlers
$questionResult = $windowsShell.popup("Do you want to try to remove the BizTalkServerApplication Host Instance from the Adapters handlers?
	
Note: The script cannot remove the default host instances if there are any receiveports, sendports or orchestrations configured.", 
						  0,"BizTalk Applications, Receive and Send Ports",4)
 	
If ($questionResult -eq 6) {
	$removeOriginalAdapterHandler = $true
}
else {
	$removeOriginalAdapterHandler = $false
}

# STEP 4
# Create default hosts, host instances and handlers
Write-Host "Creating hosts and host instances..." -Fore DarkGreen
ConfiguringBizTalkServerHostAndHostInstances

# STEP 5
# This configurations changes requires host instances restart for the changes to take effect.
# Check if you want to restart the Host Instances
Write-Host "Host and Host Instance configuration is almost completed..." -Fore DarkGreen
$questionResult = $windowsShell.popup("This configurations changes requires host instances restart for the changes to take effect. 

Do you want to restart the Host Instances now?", 0,"Please restart Host Instances",4)
If ($questionResult -eq 6) {
	get-service BTS* | foreach-object -process {restart-service $_.Name}
	Write-Host "Restart Host Instance completed..." -Fore DarkGreen
}

# STEP 6
# Check if you want to properly configure BizTalk Services and Enterprise Single Sign-On Service 'Startup type' property 
# to Automatic (Delayed Start)
$questionResult = $windowsShell.popup("By default, the 'Startup type' propriety of BizTalk Services and Enterprise Single Sign-On Service are set as 'Automatic', however BizTalk Server services may not start automatically after a system restart, to avoid this behavior you must config the 'Startup type' to 'Automatic (Delayed Start)'. 

Do you want to configure BizTalk Services to 'Automatic (Delayed Start)'?", 0,"Configure BizTalk Services to Automatic (Delayed Start)",4)
If ($questionResult -eq 6) {
	#=== Name of the Enterprise Single Sign-On Service. ===#
	$entSSOServiceName = 'ENTSSO'

	#=== Change the startup type for BizTalk services to Automatic (Delayed Start) ===#
	get-service BTSSvc* | foreach-object -process { SC.EXE config $_.Name start= delayed-auto}

	#=== Change the startup type for Enterprise Single Sign-On Service to Automatic (Delayed Start) ===#
	SC.EXE config $entSSOServiceName start= delayed-auto
	
	Write-Host "BizTalk Services and SSO configured successfully..." -Fore DarkGreen
}

Write-Host "Your BizTalk Server environment is now properly configured" -Fore DarkGreen