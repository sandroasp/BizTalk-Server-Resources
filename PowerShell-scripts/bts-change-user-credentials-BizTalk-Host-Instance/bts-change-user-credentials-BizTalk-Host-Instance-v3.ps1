########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: This script will allow you to change the user credentials of a specific Host Instance   #
#                                                                                                      #
########################################################################################################

# BizTalk WMI namespace
$namespace = "root/MicrosoftBizTalkServer"

# Credentials
$username = "LVMH-PC\SVC_BizHInstance_PRO"
$password = "tV=GR9!yLBH$mT!ozCYgOyjeOChj"

# List of BizTalk Host Names
$hostNames = @(
    "DistributedSend",
    "DistributedSend_CC",
    "DistributedSend_DA",
    "DistributedSend_SAPInQueue",
    "DistributedSend_SO",
    "DistributedSend_SO_Pivot",
    "SingleSend",
    "SingleSend_Magic",
    "BizTalkServerApplication",
    "DistributedReceive",
    "DistributedReceive_AX",
    "DistributedReceive_INFOWARE",
    "DistributedReceive_TA_BRAND",
    "SingleReceive",
    "SingleReceiveOrderedFILE",
    "SingleReceiveOrderedFILE_ANAP",
    "SingleReceiveOrderedFILE_BC_INF",
    "SingleReceiveOrderedFILE_Bc_SB",
    "SingleReceiveOrderedFILE_Cc_Cylande",
    "SingleReceiveOrderedFILE_CC_INF",
    "SingleReceiveOrderedFILE_Cc_SB",
    "SingleReceiveOrderedFILE_Inventory",
    "SingleReceiveOrderedFILE_Os_ECC",
    "SingleReceiveOrderedFILE_PR",
    "SingleReceiveOrderedFILE_PR_ECC",
    "SingleReceiveOrderedFILE_PR_ECC_GSA",
    "SingleReceiveOrderedFILE_PR_ECC_OTHERS",
    "SingleReceiveOrderedFILE_PR_ECC_PCD",
    "SingleReceiveOrderedFILE_Resubmit",
    "SingleReceiveOrderedFILE_So_INF",
    "SingleReceiveOrderedFILE_So_SB",
    "SingleReceiveOrderedFILE_TA_BRAND",
    "SingleReceiveOrderedFILE_Tracking",
    "SingleReceiveOrderedFILE_Y2"
)

foreach ($hostName in $hostNames) {
    Write-Host "Installing Host Instance for: $hostName"

    $hostInstance = Get-WmiObject `
        -Namespace $namespace `
        -Query "SELECT * FROM MSBTS_HostInstance WHERE HostName='$hostName'"

    if ($hostInstance) {
        $hostInstance.Install($username, $password, $true)
        Write-Host "✔ Installed: $hostName"
    }
    else {
        Write-Warning "⚠ Host instance not found: $hostName"
    }
}