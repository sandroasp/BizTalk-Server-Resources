# LogName - Name of the Windows Custom Event Log that you want to create
$LogName = 'CustomAdapters'
# LogSource - Source Name that you want to create to be associated with the Custom Event Log you are creating or that already exists.
$LogSource = 'Void Adapter'
# GpOrUsers - List of users or groups that will have permissions to write in the Windows Custom Event Log
$GpOrUsers = @('Administrator')

$logFileExists = Get-EventLog -list | Where-Object {$_.logdisplayname -eq $LogName} 
if (! $logFileExists) {
    New-EventLog -LogName $LogName -Source $LogSource

	# Compose Key:
	$LogPath = 'HKLM:\SYSTEM\CurrentControlSet\services\eventlog\'+$LogName;
	if(Test-Path $LogPath)
	{
	    $acl = Get-Acl $LogPath
		$GpOrUsers | %{
		    $ace = New-Object System.Security.AccessControl.RegistryAccessRule $_,'WriteKey, ReadKey','allow'
		    $acl.AddAccessRule($ace)
		}
	}
    else
    {
        Write-Error "Cannot acesss log $LogName"
    }
}
else 
{
	New-EventLog -LogName $LogName -Source $LogSource
}

# STEP 2
# Restarting Windows Event Log Service
$windowsShell = new-object -comobject wscript.shell
$questionResult = $windowsShell.popup("For these setting to take effect you need to restart Windows Event Log Service, however this will have impact on BizTalk Server services, all of them will also have to be restarted. 
Do you want to restart Windows Event Log Service?", 0,"Restart Windows Event Log Service",4)
If ($questionResult -eq 6) {
    Write-Host "Restarting services... please wait." -Fore DarkGreen
	restart-service 'EventLog' -Force
	Write-Host "Windows Event Log Service restarted successfully..." -Fore DarkGreen
}

Write-Host "Event Source successfully created" -Fore DarkGreen