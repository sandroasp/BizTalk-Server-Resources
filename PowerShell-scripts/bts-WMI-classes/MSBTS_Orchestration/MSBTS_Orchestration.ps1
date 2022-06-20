########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: Use of the MSBTS_Orchestration WMI Class.                                               #
#                                                                                                      #
#                                                                                                      #
########################################################################################################

# Get and Display Orchstrations not started
[ARRAY]$orchs = Get-WmiObject MSBTS_Orchestration -namespace 'root\MicrosoftBizTalkServer' | Where-Object {$_.OrchestrationStatus -ne 4 }
Write-Host "`nNot Started Orchestrations (" $orchs.Count ")" -fore DarkGray

Foreach($orc in $orchs)
{
    Write-Host " - " $orc.Name
}


Function Start-Orchestration([string]$name)
{
    $orch_filter = "Name='$name'"
    $orch = Get-WmiObject MSBTS_Orchestration -namespace 'root\MicrosoftBizTalkServer' -filter $orch_filter

    $orch | ?{ $_.OrchestrationStatus -eq $bound } | %{
        write-host "Enlisting $($_.Name)..."
        [void]$_.Enlist()

    }

    $orch | ?{ $_.OrchestrationStatus -ne $started } | %{
        write-host "Starting $($_.Name)..."
        [void]$_.Start($controlRecvLoc, $controlInst)
    }
}

Function Stop-Orchestration([string]$name, [switch]$unenlist = $false)
{
    $orch_filter = "Name='$name'"
    $orch = $orch = Get-WmiObject MSBTS_Orchestration -namespace 'root\MicrosoftBizTalkServer' -filter $orch_filter

    $orch | ?{ $_.OrchestrationStatus -eq $started } | %{
        write-host "Stopping $($_.Name)..."
        [void]$_.Stop($controlRecvLoc, $controlInst)
        if ($unenlist){
            [void]$_.Unenlist()
        }
    }
}

Function Unenlist-Orchestration([string]$name)
{
	$orch_filter = "Name='$name'"

	try
	{
		$orchestration = get-wmiobject MSBTS_Orchestration -namespace 'root\MicrosoftBizTalkServer' -filter $orch_filter
		
		if($orchestration)
		{
			if ($orchestration.OrchestrationStatus -gt "2")
			{
				[void]$orchestration.Unenlist()
			}
		}
		else
		{
			write-Host ""
			write-host -foregroundcolor "yellow" "Could not find orchestration $name"
			write-Host ""
		}
	}
	catch
	{
		write-host -foregroundcolor "red" "$_.Exception.Message"
		return $FALSE
	}
	return $TRUE	
}