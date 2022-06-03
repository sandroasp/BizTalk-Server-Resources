########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: This script allow you to stop or/and start a specific BizTalk Server Application.       #
#                                                                                                      #
#                                                                                                      #
########################################################################################################
$BizTalkManagementDb ="BizTalkmgmtdb"
[void] [System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.ExplorerOM")
$catalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
$catalog.ConnectionString = "SERVER=BTS2020LAB01;DATABASE=$BizTalkManagementDb;Integrated Security=SSPI"

function stop-bts-application (
    [string]$appName,
    [Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer]$btsCataloglog) 
{
    # Get the BizTalk Application
    $application = $Catalog.Applications[$appName]

    # Going to check if the application status is stopped or not
    if ($application.Status -ne "Stopped")
    {
         # Force a full stop to the application
         $application.Stop("StopAll")
         $btsCataloglog.SaveChanges()
    }
}

function start-bts-application (
    [string]$appName,
    [Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer]$btsCataloglog) 
{
    # Get the BizTalk Application
    $application = $Catalog.Applications[$appName]

    # Going to check if the application status is stopped or not
    if ($application.Status -ne "Started")
    {
         # Force a full stop to the application
         $application.Start("StartAll")
         $btsCataloglog.SaveChanges()
    }
}
 
# trigger function stop-bts-application
stop-bts-application BTSCourse $catalog

# trigger function start-bts-application
start-bts-application BTSCourse $catalog