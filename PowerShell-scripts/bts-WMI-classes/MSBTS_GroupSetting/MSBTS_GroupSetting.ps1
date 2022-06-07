########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: USe of the MSBTS_GroupSetting WMI Class.                                                #
#                                                                                                      #
#                                                                                                      #
########################################################################################################

# Get BizTalk Server DB info
# Set name of MgmtDbServer
$global:mgmtDbServer = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbServerName

# Set via WMI name of MgmtDb
$global:mgmtDbName = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbName



function Connect-BTSCatalog {
    [CmdletBinding()]
    [OutputType([Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer])]
    Param (
        [Parameter()]
        [string]$Server = $env:COMPUTERNAME,
        [Parameter()]
        [string]$SQLInstance,
        [Parameter()]
        [string]$ManagementDB
    )
    Process {        
        #Calculate BizTalk connection string
        $wmi = Get-WmiObject -Class MSBTS_GroupSetting -Namespace root\MicrosoftBizTalkServer -computer $server -ErrorAction Stop
        if (-not $SQLInstance) {
            $SQLInstance = $wmi.MgmtDbServerName
        }
        if (-not $ManagementDB) {
            $ManagementDB = $wmi.MgmtDbName
        }

        $btsCatalog = New-Object "Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer"
        $btsCatalog.ConnectionString = "SERVER=$SQLInstance;DATABASE=$ManagementDB;Integrated Security=SSPI"

        return $btsCatalog
    }
}