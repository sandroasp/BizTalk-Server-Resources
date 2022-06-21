########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: Use of the MSBTS_ServerHost WMI Class.                                                  #
#                                                                                                      #
#                                                                                                      #
########################################################################################################

function Create-BizTalk-Host-Instance([string]$hostName, [string]$serverName, [string]$username, [string]$password)
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

$host = Get-WmiObject -class MSBTS_ServerHost -Namespace 'root\MicrosoftBizTalkServer' 

[ARRAY]$HostInfo = Get-WmiObject MSBTS_ServerHost -namespace 'root\MicrosoftBizTalkServer' -Filter 'ServerName="Server1"'