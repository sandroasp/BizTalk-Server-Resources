########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: This script will allow you to change the user credentials of a specific Host Instance   #
#                                                                                                      #
########################################################################################################

# Run as Administrator

$Services = @(
    "BTSSvc$DistributedSend",
    "BTSSvc$DistributedSend_CC",
    "BTSSvc$DistributedSend_DA",
    "BTSSvc$DistributedSend_SAPInQueue",
    "BTSSvc$DistributedSend_SO",
    "BTSSvc$DistributedSend_SO_Pivot",
    "BTSSvc$SingleSend",
    "BTSSvc$SingleSend_Magic",
    "BTSSvc$BizTalkServerApplication",
    "BTSSvc$DistributedReceive",
    "BTSSvc$DistributedReceive_AX",
    "BTSSvc$DistributedReceive_INFOWARE",
    "BTSSvc$DistributedReceive_TA_BRAND",
    "BTSSvc$SingleReceive",
    "BTSSvc$SingleReceiveOrderedFILE",
    "BTSSvc$SingleReceiveOrderedFILE_ANAP",
    "BTSSvc$SingleReceiveOrderedFILE_BC_INF",
    "BTSSvc$SingleReceiveOrderedFILE_Bc_SB",
    "BTSSvc$SingleReceiveOrderedFILE_Cc_Cylande",
    "BTSSvc$SingleReceiveOrderedFILE_CC_INF",
    "BTSSvc$SingleReceiveOrderedFILE_Cc_SB",
    "BTSSvc$SingleReceiveOrderedFILE_Inventory",
    "BTSSvc$SingleReceiveOrderedFILE_Os_ECC",
    "BTSSvc$SingleReceiveOrderedFILE_PR",
    "BTSSvc$SingleReceiveOrderedFILE_PR_ECC",
    "BTSSvc$SingleReceiveOrderedFILE_PR_ECC_GSA",
    "BTSSvc$SingleReceiveOrderedFILE_PR_ECC_OTHERS",
    "BTSSvc$SingleReceiveOrderedFILE_PR_ECC_PCD",
    "BTSSvc$SingleReceiveOrderedFILE_Resubmit",
    "BTSSvc$SingleReceiveOrderedFILE_So_INF",
    "BTSSvc$SingleReceiveOrderedFILE_So_SB",
    "BTSSvc$SingleReceiveOrderedFILE_TA_BRAND",
    "BTSSvc$SingleReceiveOrderedFILE_Tracking",
    "BTSSvc$SingleReceiveOrderedFILE_Y2"
)

# === NEW credentials to set ===
$NewUser = "LVMH-PC\SVC_BizHInstance_PRO"
$NewPassword = "tV=GR9!yLBH$mT!ozCYgOyjeOChj"


# Build a lookup of existing BTSSvc$ services on this machine (avoids 'cannot find service')
$existing = Get-CimInstance Win32_Service | Where-Object { $_.Name -like 'BTSSvc$*' }
$existingByName = @{}
foreach ($e in $existing) { $existingByName[$e.Name] = $e }

$results = foreach ($svcName in $Services) {

    if (-not $existingByName.ContainsKey($svcName)) {
        [pscustomobject]@{
            Service    = $svcName
            Result     = "NOT FOUND"
            BeforeUser = $null
            AfterUser  = $null
            Details    = "Service not present on this machine"
        }
        continue
    }

    $svc = $existingByName[$svcName]
    $beforeUser = $svc.StartName

    try {
        # Change ONLY StartName + StartPassword (no stop/start)
        $r = Invoke-CimMethod -InputObject $svc -MethodName Change -Arguments @{
            StartName     = $NewUser
            StartPassword = $NewPassword
        }

        if ($r.ReturnValue -ne 0) {
            [pscustomobject]@{
                Service    = $svcName
                Result     = "FAILED"
                BeforeUser = $beforeUser
                AfterUser  = $beforeUser
                Details    = "Win32_Service.Change ReturnValue=$($r.ReturnValue)"
            }
            continue
        }

        $afterUser = (Get-CimInstance Win32_Service -Filter "Name='$svcName'").StartName

        [pscustomobject]@{
            Service    = $svcName
            Result     = "OK"
            BeforeUser = $beforeUser
            AfterUser  = $afterUser
            Details    = "Credentials updated (effective on next start)"
        }
    }
    catch {
        [pscustomobject]@{
            Service    = $svcName
            Result     = "FAILED"
            BeforeUser = $beforeUser
            AfterUser  = $beforeUser
            Details    = $_.Exception.Message
        }
    }
}

$results | Sort-Object Result, Service | Format-Table -AutoSize

# Optional export
# $results | Export-Csv ".\BizTalk_ServiceCredentialUpdate.csv" -NoTypeInformation