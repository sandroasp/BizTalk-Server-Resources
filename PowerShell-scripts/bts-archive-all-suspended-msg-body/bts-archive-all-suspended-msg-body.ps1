﻿########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: This script archives the payload/body of all BizTalk Server suspended messages to files.#
#                                                                                                      #
#                                                                                                      #
########################################################################################################

function archive-all-suspended-msg-body () 
{
	try 
    {
		# retrive BizTalk database server name
		$global:mgmtDbServer = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbServerName
		# retrive BizTalk managment database name
		$global:mgmtDbName = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbName
 
		# load Microsoft.BizTalk.Operations
		[void] [System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.Operations")
 
		# create instanse of BizTalkOperations
		$getBodyOperation = New-Object Microsoft.BizTalk.Operations.BizTalkOperations($mgmtDbServer, $mgmtDbName)
 
		# write confirmation message to console
		Write-Host "Start looking for suspended messages" -foregroundcolor "Green"
 
		# look for suspended messages
		$msgs = $getBodyOperation.GetMessages() | where-object {$_.MessageStatus -like "Suspended"} 
 
		# Check if any suspended message were found
		If ($msgs) 
        {
			$i = 0
			$currentDate = Get-Date
 
			# format current timestamp so it may be used to create folder(s) and file(s) with 
			[string]$currentTimeStamp = $currentDate.Year.ToString() + "-" + $currentDate.Month.ToString() + "-" + $currentDate.Day.ToString() + "_" + $currentDate.Hour.ToString() + "." + $currentDate.Minute.ToString() + "." + $currentDate.Second.ToString()
 
			# for each suspended message found
            Foreach ($msg in $msgs)
            {
                $i++

                [string]$shortServiceName = $msg.ServiceType
                if($msg.ServiceType -match ",")
                {
                    $shortServiceName = $msg.ServiceType.Substring(0, $msg.ServiceType.IndexOf(','))          
                }
 
				# store the current suspended message body
				$bodyPartData = $msg.BodyPart.Data
 
				# if current message body not empty
				If ($bodyPartData)
                {
					# streamreader is needed to convert the msgbody to a string
					$streamReader = new-object System.IO.StreamReader($bodyPartData)
 
					# converting msgbody to string
					[string]$msgBodyString = $null
 
					# allow streamreader to read and store it to string $msgBodyString
					$msgBodyString = $streamReader.ReadToEnd()
 
					# path to store suspended message body
					[string]$archiveToPath = "C:\ArchiveSuspended\$shortServiceName\$currentTimeStamp"
 
					# check if folder in $archiveToPath exist
					if ((Test-Path -path $archiveToPath) -ne $True)
                    {
						# folder does not exist, so we need to create it
						New-Item $archiveToPath -type directory | out-null
						Write-Host "Creating folder: $archiveToPath`r`n" -foregroundcolor "Green"
					}
 
					# final path and filename for the current message being processed
					$archiveToPath = $archiveToPath + "\" + $msg.MessageID + ".xml"
 
					# confirmation message written to console
					Write-Host "Exporting message to path: $archiveToPath`r`n" -foregroundcolor "Green"
 
					# body written to file
					[io.file]::WriteAllText($archiveToPath, $msgBodyString)
				}
			}
		} 
        else 
        {
			# write confirmation to console
			Write-Host "No BizTalk suspended messages were founded" -foregroundcolor "Yellow"
		}
 
		# final confirmation message written to console
		Write-Host "Search and archive process finallized" -foregroundcolor "Green"
	}
	# simple fault handler
	catch 
    {
		$errorMsg = "Unable to retrive msgbody from BizTalk Server"
		$errorMsg += "Script report the following reason(s):`r`n"
		$errorMsg += [string]$error[0] + "`r`n`r`n"
		$errorMsg += [string]$error[0].InvocationInfo.PositionMessage + "`r`n`r`n"
		Write-Host $errorMsg -foregroundcolor "Red"
	}
}
 
# trigger function archive-all-suspended-msg-body 
archive-all-suspended-msg-body 