#Author: Sandro Pereira
#Date: 2016-02-14

#Set mail variables
[STRING]$PSEmailServer = "mySMTPServer" #SMTP Server.
[STRING]$SubjectPrefix = "Host instances not running - "
[STRING]$From = "biztalksupport@mail.pt"
[array]$EmailTo = ("sandro.pereira@devscope.net")

#Get DB info
[STRING]$SQLInstance = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbServerName
[STRING]$BizTalkManagementDb = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbName
[STRING]$BizTalkGroup = "$SQLInstance" + ":" + "$BizTalkManagementDb"

# Get Host instances not running
[ARRAY]$hostInstances = get-wmiobject MSBTS_HostInstance  -namespace 'root\MicrosoftBizTalkServer' -filter '(HostType = 1 and ServiceState != 4)'

#Cancel if all host instances are running
if ($hostInstances -eq $null) {exit}

#Create mail content
$mailBodyHI = ""
$mailTextReportHI = "There are "+ $hostInstances.Count  + " Host Instances not running in the BizTalk group " + $BizTalkGroup + "."
[STRING]$Subject = $SubjectPrefix + $BizTalkGroup

foreach ($hostInstance in $hostInstances)
{
    #Add mail content
    $mailBodyHI += "<th><b><font color='blue'>" + $hostInstance.Name + "</font></b></th>"
    $mailBodyHI += "<table style='boder:0px 0px 0px 0px;'>"

    $mailBodyHI += "<TR style='background-color:white;'><TD>Host Name</TD>"
    $mailBodyHI += "<TD><b><font color='red'>" + $hostInstance.HostName + "</font></b></TD></TR>"

    $mailBodyHI += "<TR style='background-color:rgb(245,245,245);';><TD>Host Type</TD>"
    $mailBodyHI += "<TD>In-process</TD></TR>"

    $mailBodyHI += "<TR style='background-color:white;'><TD>Running Server</TD>"
    $mailBodyHI += "<TD><b><font color='red'>" + $hostInstance.RunningServer + "</font></b></TD></TR>"

    # Stopped: 1
    # Start pending: 2
    # Stop pending: 3
    # Running: 4
    # Continue pending: 5
    # Pause pending: 6
    # Paused: 7
    # Unknown: 8

    $statusHI = ""
    if ($hostInstance.ServiceState -eq 1)
    {
        $statusHI = "Stopped" 
    }
    if ($hostInstance.ServiceState -eq 2)
    {
        $statusHI = "Start pending" 
    }
    if ($hostInstance.ServiceState -eq 3)
    {
        $statusHI = "Stop pending" 
    }
    if ($hostInstance.ServiceState -eq 5)
    {
        $statusHI = "Continue pending" 
    }
    if ($hostInstance.ServiceState -eq 6)
    {
        $statusHI = "Pause pending" 
    }
    if ($hostInstance.ServiceState -eq 7)
    {
        $statusHI = "Paused" 
    }
    if ($hostInstance.ServiceState -eq 8)
    {
        $statusHI = "Unknown" 
    }

    $mailBodyHI += "<TR style='background-color:rgb(245,245,245);';><TD>Service State</TD>"
    $mailBodyHI += "<TD><b><font color='red'>" + $statusHI + "</font></b></TD></TR>"

    #0: UnClusteredInstance
    #1: ClusteredInstance
    #2: ClusteredVirtualInstance
    if ($hostInstance.ClusterInstanceType -eq 0)
    {
        $statusHI = "UnClustered Instance" 
    }
    if ($hostInstance.ClusterInstanceType -eq 1)
    {
        $statusHI = "Clustered Instance" 
    }
    if ($hostInstance.ClusterInstanceType -eq 2)
    {
        $statusHI = "Clustered Virtual Instance" 
    }

    $mailBodyHI += "<TR style='background-color:white;'><TD>Cluster Instance Type</TD>"
    $mailBodyHI += "<TD>" + $statusHI + "</TD></TR>"

    $mailBodyHI += "<TR style='background-color:rgb(245,245,245);';><TD>Is Disabled</TD>"
    $mailBodyHI += "<TD>" + $hostInstance.IsDisabled + "</TD></TR>"

    $mailBodyHI += "<TR style='background-color:white;'><TD>NT Group Name</TD>"
    $mailBodyHI += "<TD>" + $hostInstance.NTGroupName + "</TD></TR>"

    $mailBodyHI += "<TR style='background-color:rgb(245,245,245);';><TD>Logon</TD>"
    $mailBodyHI += "<TD>" + $hostInstance.Logon + "</TD></TR>"
    
    #Auto-Healing feature
    if($hostInstance.IsDisabled = "False")
    {
        $hostInstance.InvokeMethod("Start",$null)

        $mailBodyHI += "<TR style='background-color:white;'><TD><font color='green'>Note</font></TD>"
        $mailBodyHI += "<TD><font color='green'>The Host Instance was started automatically by this script! Please access the environment to validate if all host instances are running.</font></TD></TR>"
    }

    $mailBodyHI += "</table>"
    $mailBodyHI += "<BR><BR>"
}

# HTML Format for Output 
$HTMLmessage = @"
<font color=""black"" face=""Arial"" size=""3"">
<h1 style='font-family:arial;'><b>Host Instances Report</b></h1>
<p style='font: .8em ""Lucida Grande"", Tahoma, Arial, Helvetica, sans-serif;'>$mailTextReportHI</p>
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
$mailBodyHI
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