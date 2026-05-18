########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: This script will allow you to change the user credentials of a specific Host Instance   #
#                                                                                                      #
########################################################################################################


# Create/Install a single BizTalk Host Instance on a specific server
# Requires rights on BizTalk + local admin on target server (typical for host instance operations)

$BizTalkServer = "BIZTALKSERVER01"          # <<< target machine where the host instance will be created
$HostName      = "DistributedSend"          # <<< BizTalk Host name (NOT service name)
$ServiceUser   = "DOMAIN\ServiceAccount"    # <<< account to run the host instance service
$ServicePass   = "P@ssw0rd!"                # <<< password (see secure variant below)
$IsGmsa        = $false                      # set $true if using gMSA (then password must be empty)

# Connect to BizTalk WMI on the target server and locate the host instance for that host+server
# Note: In WMI, host instances are identified by HostName and RunningServer
$query = "SELECT * FROM MSBTS_HostInstance WHERE HostName='$HostName' AND RunningServer='$BizTalkServer'"

$hostInstance = Get-WmiObject -ComputerName $BizTalkServer `
                              -Namespace "root\MicrosoftBizTalkServer" `
                              -Query $query

if (-not $hostInstance) {
    throw "Host instance object not found for HostName='$HostName' on server '$BizTalkServer'. Make sure the Host exists and is mapped to this server."
}

# Install (create) the Windows service for the host instance
# Install(UserName, Password, IsGmsa) signature is commonly used from PowerShell samples. [5](https://devscopewp.azurewebsites.net/events/biztalk-to-azure/)
if ($IsGmsa) {
    $result = $hostInstance.Install($ServiceUser, "", "true")
} else {
    $result = $hostInstance.Install($ServiceUser, $ServicePass, "false")
}

"Install() returned: $result"


$results | Sort-Object Result, Service | Format-Table -AutoSize
