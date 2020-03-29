#Author: Sandro Pereira
#Date: 2016-02-14

#Set mail variables
[STRING]$PSEmailServer = "mySMTPServer" #SMTP Server.
[STRING]$SubjectPrefix = "Suspended Messages - "
[STRING]$From = "biztalksupport@mail.pt"
[array]$EmailTo = ("sandro.pereira@devscope.net")

#Get DB info
[STRING]$SQLInstance = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbServerName
[STRING]$BizTalkManagementDb = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbName
[STRING]$BizTalkGroup = "$SQLInstance" + ":" + "$BizTalkManagementDb"
 
#Get suspended messages
[ARRAY]$suspendedMessages = get-wmiobject MSBTS_ServiceInstance -namespace 'root\MicrosoftBizTalkServer' -filter '(ServiceStatus = 4 or ServiceStatus = 16 or ServiceStatus = 32 or ServiceStatus = 64)'
 
#Cancel if there are no suspended messages
if ($suspendedMessages -eq $null) {exit}

Add-Type -AssemblyName ('Microsoft.BizTalk.Operations, Version=3.0.1.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35, processorArchitecture=MSIL')
$dbServer = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\BizTalk Server\3.0\Administration' 'MgmtDBServer').MgmtDBServer
$dbName = (Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\BizTalk Server\3.0\Administration' 'MgmtDBName').MgmtDBName
$bo = New-Object Microsoft.BizTalk.Operations.BizTalkOperations $dbServer, $dbName

#This variable sets the amount of hours a suspended message can be resumed automatically
[INT]$AutomaticResume = 8
 
#Create mail content
$mailBodySM = ""
$mailTextReportSM = "There are "+ $suspendedMessages.Count  + " suspended messages in the BizTalk group " + $BizTalkGroup + "."
[STRING]$Subject = $SubjectPrefix + $BizTalkGroup

#Get the current date
$currentdateSI = get-date

foreach ($msgSuspended in $suspendedMessages)
{
    $msg = $bo.GetServiceInstance($msgSuspended.InstanceID)

    #Add mail content
    $mailBodySM += "<th>Message Instance ID: <b><font color='blue'>" + $msgSuspended.InstanceID + "</font></b></th>"
    $mailBodySM += "<table style='boder:0px 0px 0px 0px;'>"

    $mailBodySM += "<TR style='background-color:white;'><TD>Application</TD>"
    $mailBodySM += "<TD>" + $msg.Application + "</TD></TR>"

    $mailBodySM += "<TR style='background-color:rgb(245,245,245);';><TD>Service Name</TD>"
    $mailBodySM += "<TD><b><font color='red'>" + $msgSuspended.ServiceName + "</font></b></TD></TR>"

    $mailBodySM += "<TR style='background-color:white;'><TD>Class</TD>"
    $mailBodySM += "<TD>" + $msg.Class + "</TD></TR>"

    $mailBodySM += "<TR style='background-color:rgb(245,245,245);';><TD>Assembly Name</TD>"
    $mailBodySM += "<TD>" + $msgSuspended.AssemblyName + ", Version=" + $msgSuspended.AssemblyVersion + ", Culture=" + $msgSuspended.AssemblyCulture +", PublicKeyToken=" + $msgSuspended.AssemblyPublicKeyToken + "</TD></TR>"

    $spActivationTime= [datetime]::ParseExact($msgSuspended.ActivationTime.Substring(0,14),'yyyyMMddHHmmss',[Globalization.CultureInfo]::InvariantCulture )
    $mailBodySM += "<TR style='background-color:white;'><TD>Activation Time</TD>"
    $mailBodySM += "<TD>" + $spActivationTime.ToString("dd-MM-yyyy HH:mm:ss") + "</TD></TR>"

    $myDate= [datetime]::ParseExact($msgSuspended.SuspendTime.Substring(0,14),'yyyyMMddHHmmss',[Globalization.CultureInfo]::InvariantCulture )
    $mailBodySM += "<TR style='background-color:rgb(245,245,245);';><TD>Suspend Time</TD>"
    $mailBodySM += "<TD>" + $myDate.ToString("dd-MM-yyyy HH:mm:ss") + "</TD></TR>"

    #ServiceStatus = 1 - Ready To Run
    #ServiceStatus = 2 - Active
    #ServiceStatus = 4 - Suspended (Resumable)
    #ServiceStatus = 8 - Dehydrated
    #ServiceStatus = 16 - Completed With Discarded Messages' in BizTalk Server 2004
    #ServiceStatus = 32 - Suspended (Not Resumable) 
    #ServiceStatus = 64 - In Breakpoint 
    $statusMsg = ""
    if ($msgSuspended.ServiceStatus -eq 4)
    {
        $statusMsg = "Suspended (Resumable)" 
    }
    if ($msgSuspended.ServiceStatus -eq 16)
    {
        $statusMsg = "Completed With Discarded Messages" 
    }
    if ($msgSuspended.ServiceStatus -eq 32)
    {
        $statusMsg = "Suspended (Not Resumable)" 
    }
    if ($msgSuspended.ServiceStatus -eq 64)
    {
        $statusMsg = "In Breakpoint" 
    }

    $mailBodySM += "<TR style='background-color:white;'><TD>Service Name</TD>"
    $mailBodySM += "<TD><b><font color='red'>" + $statusMsg + "</font></b></TD></TR>"
        
    $mailBodySM += "<TR style='background-color:rgb(245,245,245);';><TD>HostName</TD>"
    $mailBodySM += "<TD>" + $msgSuspended.HostName + " (" + $msgSuspended.PSComputerName + ")</TD></TR>"

    $mailBodySM += "<TR style='background-color:white;'><TD>Error Code</TD>"
    $mailBodySM += "<TD>" + $msgSuspended.ErrorId + "</TD></TR>"

    $mailBodySM += "<TR style='background-color:rgb(245,245,245);';><TD>Error Description</TD>"
    $mailBodySM += "<TD>" + $msgSuspended.ErrorDescription + "</TD></TR>"

    $mailBodySM += "<TR style='background-color:white;'><TD>Error Category</TD>"
    $mailBodySM += "<TD>" + $msgSuspended.ErrorCategory + "</TD></TR>"

    $mailBodySM += "<TR style='background-color:rgb(245,245,245);';><TD>In Breakpoint</TD>"
    $mailBodySM += "<TD>" + $msg.InBreakpoint + "</TD></TR>"

    $mailBodySM += "<TR style='background-color:white;'><TD>Pending Operation</TD>"
    $mailBodySM += "<TD>" + $msg.PendingOperation + "</TD></TR>"


    If (($spActivationTime -ge $currentdateSI.AddHours(-$AutomaticResume)) -and ($msg.Class -like "Orchestration") -and ($msgSuspended.ServiceStatus -eq 4))
    {
        $msgSuspended.InvokeMethod("Resume",$null)

        $mailBodySM += "<TR style='background-color:rgb(245,245,245);';><TD><font color='green'>Note</font></TD>"
        $mailBodySM += "<TD><font color='green'>The suspended message was resumed automatically by this script! Please access the environment to check if the processes are running or completed.</font></TD></TR>"
    }

    $mailBodySM += "</table>"
    $mailBodySM += "<BR><BR>"
}

# HTML Format for Output 
$HTMLmessage = @"
<font color=""black"" face=""Arial"" size=""3"">
<h1 style='font-family:arial;'><b>Suspended Instances Report</b></h1>
<p style='font: .8em ""Lucida Grande"", Tahoma, Arial, Helvetica, sans-serif;'>$mailTextReportSM</p>
<br><br>
<style type=""text/css"">body{font: .8em ""Lucida Grande"", Tahoma, Arial, Helvetica, sans-serif;}
ol{margin:0;}
table{width:80%;}
thead{}
thead th{font-size:120%;text-align:left;}
th{border-bottom:2px solid rgb(79,129,189);border-top:2px solid rgb(79,129,189);padding-bottom:10px;padding-top:10px;}
tr{padding:10px 10px 10px 10px;border:none;}
#middle{background-color:#900;}
</style>
<body BGCOLOR=""white"">
$mailBodySM
</body>
"@

#Send mail
foreach ($to in $EmailTo) 
{
    $Body = $HTMLmessage
    $SMTPClient = New-Object Net.Mail.SmtpClient($PSEmailServer) 
    $message = New-Object Net.Mail.MailMessage($from, $to, $Subject, $Body)
    $message.IsBodyHtml = $true;
    $SMTPClient.Send($message)
}
