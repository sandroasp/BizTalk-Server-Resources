$machineName = hostname
$query = "root\MicrosoftBizTalkServer", "Select * from MSBTS_HostInstance where HostType = 1 and ServiceState = 4 and RunningServer = '$machineName'"
$hostInstanceSearch = new-object system.management.managementObjectsearcher($query)

$hostInstanceList = $hostInstanceSearch.get()

foreach ($hostInstanceItem in $hostInstanceList) {

    $processName = $hostInstanceItem.HostName
    $perfCounter = New-Object System.Diagnostics.PerformanceCounter("BizTalk:Messaging", "ID Process", $processName)
    $processID  = $perfCounter.NextValue()

 
    Write-Host 
    Write-Host "HostName: " -foregroundcolor yellow -NoNewLine 
    Write-Host $hostInstanceItem.HostName -foregroundcolor white 
    Write-Host "Process Id: " -foregroundcolor yellow -NoNewLine
    Write-Host $processID   -foregroundcolor white
    Write-Host 	
	
}