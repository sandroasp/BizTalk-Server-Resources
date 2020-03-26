#Get DB info
[STRING]$SQLInstance = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbServerName
[STRING]$BizTalkManagementDb = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbName
[STRING]$BizTalkGroup = "$SQLInstance" + ":" + "$BizTalkManagementDb"
 
#Get all Suspended (not resumable) Routing Failure Report Instances
[ARRAY]$suspendedMessages = get-wmiobject MSBTS_ServiceInstance -namespace 'root\MicrosoftBizTalkServer' -filter '(ServiceStatus=32 and ServiceClass=64)'
 
foreach ($msgSuspended in $suspendedMessages)
{
    $msgSuspended.InvokeMethod("Terminate",$null)
}
