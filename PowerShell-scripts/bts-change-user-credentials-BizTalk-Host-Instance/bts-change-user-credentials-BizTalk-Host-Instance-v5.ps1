########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: This script will allow you to change the user credentials of a specific Host Instance   #
#                                                                                                      #
########################################################################################################


# Run PowerShell as Administrator

# Get all BizTalk Host Instance services (service NAME starts with BTSSvc$)
$bizTalkServices = Get-Service | Where-Object { $_.Name -like 'BTSSvc$*' }

if (-not $bizTalkServices) {
    Write-Warning "No services found starting with 'BTSSvc$' on this machine."
    return
}

$results = foreach ($svc in $bizTalkServices) {

    $name = $svc.Name

    try {
        # Set startup type to Automatic (Delayed Start)
        # (SC requires the space after 'start=')
        $scOutput = sc.exe config $name start= delayed-auto 2>&1

        # Refresh current status
        $svc.Refresh()

        # Start service if not running
        if ($svc.Status -ne 'Running') {
            Start-Service -Name $name -ErrorAction Stop
            (Get-Service -Name $name).WaitForStatus('Running','00:02:00')
        }

        [pscustomobject]@{
            Service = $name
            Startup = "Automatic (Delayed Start)"
            Status  = (Get-Service -Name $name).Status
            Result  = "OK"
        }
    }
    catch {
        [pscustomobject]@{
            Service = $name
            Startup = "Automatic (Delayed Start)"
            Status  = $svc.Status
            Result  = "FAILED: $($_.Exception.Message)"
        }
    }
}

$results | Sort-Object Result, Service | Format-Table -AutoSize
