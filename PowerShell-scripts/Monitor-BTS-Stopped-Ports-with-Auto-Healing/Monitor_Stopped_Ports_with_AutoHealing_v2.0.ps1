#Author: Sandro Pereira
#Date: 2016-10-11

#Save reports to disk
[bool]$saveReportToHardDrive = $false

#Get Send ports
[ARRAY]$SendPorts = get-wmiobject MSBTS_SendPort -namespace 'root\MicrosoftBizTalkServer' -filter '(Status != 3)'

#Get Receive locations
[ARRAY]$ReceiveLocations = get-wmiobject MSBTS_ReceiveLocation -namespace 'root\MicrosoftBizTalkServer' -filter '(IsDisabled = True)'

#Exit the script if there are no disabled receive locations and stopped/unelisted send ports
If (($SendPorts.Count -eq 0) -and ($ReceiveLocations.Count -eq 0))
{
    exit
}

#Set mail variables
[STRING]$PSEmailServer = "mySMTPServer"
[STRING]$SubjectPrefix = "Port status - "
[STRING]$From = "biztalksupport@mail.pt"
[array]$EmailTo = ("sandro.pereira@devscope.net")

#Get DB info
[STRING]$SQLInstance = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbServerName
[STRING]$BizTalkManagementDb = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer | select-object -expand MgmtDbName
[STRING]$BizTalkGroup = "$SQLInstance" + ":" + "$BizTalkManagementDb"

#=== Make sure the ExplorerOM assembly is loaded ===#
[void] [System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.ExplorerOM")

#=== Connect to the BizTalk Management database ===#
$Catalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
$Catalog.ConnectionString = "SERVER="+ "$SQLInstance" +";DATABASE=BizTalkMgmtDb;Integrated Security=SSPI"

#Create mail content
$mailBodyPT = ""

#Create mail content
$mailTextReportPT = "There are: "
[STRING]$Subject = $SubjectPrefix + $BizTalkGroup

if($SendPorts.Count -gt 0)
{
    [INT]$counter = 0;
    $mailTextReportPT += "" + $SendPorts.Count + " send ports stopped; "
    $mailBodyPT += "<h3>Send ports Stopped</h3>"

    $mailBodyPT += "<table style='boder:0px 0px 0px 0px;'>"
    $mailBodyPT += "<TR style='background-color:rgb(68,114,196);';><TD><font color='white'><b>S.No</b></font></TD><TD><font color='white'><b>Application</b></font></TD>"
    $mailBodyPT += "<TD><font color='white'><b>Send Port</b></font></TD><TD><font color='white'><b>Status</b></font></TD>"
    $mailBodyPT += "<TD><font color='white'><b>Transport type</b></font></TD><TD><font color='white'><b>URI</b></font></TD>"
    $mailBodyPT += "<TD><font color='white'><b>Is Dynamic</b></font></TD><TD><font color='white'><b>Is Two Way</b></font></TD>"
    $mailBodyPT += "<TD><font color='white'><b>Has Filters</b></font></TD><TD><font color='white'><b>Has Outbound Transformations</b></font></TD></TR>"

    #Add mail content for stopped send ports - only stopped or Unelisted Send Ports are added to the mail
    Foreach ($SendPort in $SendPorts)
    {
        #Set status to a user friendly name
        if ($SendPort.status -eq 2)
        {
            $SendPortStatus = "Stopped"
        }
        elseif ($SendPort.status -eq 1)
        {
            $SendPortStatus = "Unelisted"
        }
    
        #Add mail content
        if ($counter % 2)
        {
            $mailBodyPT += "<TR style='background-color:white;'>";
        }
        else{
            $mailBodyPT += "<TR style='background-color:rgb(217,226,243);';>";
        }
        $mailBodyPT += "<TD>" + (++$counter) + "</TD>"
        $mailBodyPT += "<TD>" + $Catalog.SendPorts[$SendPort.name].Application.Name + "</TD>"
        $mailBodyPT += "<TD><b><font color='red'>" + $SendPort.name + "</font><b></TD>"
        $mailBodyPT += "<TD><b><font color='red'>" + $SendPortStatus + "</font><b></TD>"
        $mailBodyPT += "<TD>" + $SendPort.PTTransportType + "</TD>"
        $mailBodyPT += "<TD>" + $SendPort.PTAddress + "</TD>"
        $mailBodyPT += "<TD>" + $SendPort.IsDynamic + "</TD>"
        $mailBodyPT += "<TD>" + $SendPort.IsTwoWay + "</TD>"
        if (![string]::IsNullOrEmpty(!$SendPort.Filter))
        {
            $mailBodyPT += "<TD>False</TD>"
        }
        else
        {
            $mailBodyPT += "<TD>True</TD>"
        }
        if($Catalog.SendPorts[$SendPort.name].OutboundTransforms.Count -eq 0)
        {
            $mailBodyPT += "<TD>False</TD>"
        }
        else
        {
            $mailBodyPT += "<TD>True</TD>"
        }

        $mailBodyPT += "</TR>"

        if ($SendPort.status -eq 2)
        {
            #Auto-Healing feature
            $SendPort.InvokeMethod("Start",$null)
        }
    }

    $mailBodyPT += "</table>"
    $mailBodyPT += "<BR><font color='green'>The Stopped ports were automatically Started by this script! Please access the environment to check if ports are running correctly.</font><BR>"
}

if($ReceiveLocations.Count -gt 0)
{
    [INT]$counter = 0;
    $mailTextReportPT += "" + $countReceivePorts + " receive locations disabled; "
    $mailBodyPT += "<h3>Receive locations Disabled</h3>"

    $mailBodyPT += "<table style='boder:0px 0px 0px 0px;'>"
    $mailBodyPT += "<TR style='background-color:rgb(68,114,196);';><TD><font color='white'><b>S.No</b></font></TD><TD><font color='white'><b>Application</b></font></TD>"
    $mailBodyPT += "<TD><font color='white'><b>Receive Port</b></font></TD><TD><font color='white'><b>Receive Location</b></font></TD>"
    $mailBodyPT += "<TD><font color='white'><b>Status</b></font></TD><TD><font color='white'><b>Transport type</b></font></TD><TD><font color='white'><b>URL</b></font></TD>"
    $mailBodyPT += "<TD><font color='white'><b>Is Primary</b></font></TD><TD><font color='white'><b>Is Two Way</b></font></TD>"
    $mailBodyPT += "<TD><font color='white'><b>Has Inbound Transformations</b></font></TD></TR>"

    #Add mail content for stopped receive locations - only Disabled receive locations are added to the mail
    Foreach ($ReceiveLocation in $ReceiveLocations)
    {
        #Set status to a user friendly name
        $ReceiveLocationStatus = "Disabled"

        #Add mail content
        if ($counter % 2)
        {
            $mailBodyPT += "<TR style='background-color:white;'>";
        }
        else{
            $mailBodyPT += "<TR style='background-color:rgb(217,226,243);';>";
        }        
        $mailBodyPT += "<TD>" + (++$counter) + "</TD>"
        $mailBodyPT += "<TD>" + $Catalog.ReceivePorts[$ReceiveLocation.ReceivePortName].Application.Name + "</TD>"
        $mailBodyPT += "<TD>" + $ReceiveLocation.ReceivePortName + "</TD>"
        $mailBodyPT += "<TD><b><font color='red'>" + $ReceiveLocation.name + "</font><b></TD>"
        $mailBodyPT += "<TD><b><font color='red'>" + $ReceiveLocationStatus + "</font><b></TD>"
        $mailBodyPT += "<TD>" + $ReceiveLocation.AdapterName + "</TD>"
        $mailBodyPT += "<TD>" + $ReceiveLocation.InboundTransportURL + "</TD>"
        $mailBodyPT += "<TD>" + $ReceiveLocation.IsPrimary + "</TD>"
        $mailBodyPT += "<TD>" + $Catalog.ReceivePorts[$ReceiveLocation.ReceivePortName].IsTwoWay + "</TD>"
        if($Catalog.ReceivePorts[$ReceiveLocation.ReceivePortName].InboundTransforms.Count -eq 0)
        {
            $mailBodyPT += "<TD>False</TD>"
        }
        else
        {
            $mailBodyPT += "<TD>True</TD>"
        }
            
        $mailBodyPT += "</TR>"

        #Auto-Healing feature
        $ReceiveLocation.InvokeMethod("Enable",$null)
    }

    $mailBodyPT += "</table>"
    $mailBodyPT += "<BR><font color='green'>The Disabled ports were automatically Enable by this script! Please access the environment to check if ports are running correctly.</font><BR>"
}


$mailTextReportPT += "in the BizTalk group: " + $BizTalkGroup + "." 

# HTML Format for Output 
$HTMLmessage = @"
<font color=""black"" face=""Arial"" size=""3"">
<h1 style='font-family:arial;'><b>BizTalk Port Status Report</b></h1>
<p style='font: .8em ""Lucida Grande"", Tahoma, Arial, Helvetica, sans-serif;'>$mailTextReportPT</p>
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
$mailBodyPT
</body>
"@

#Write Report to a folder
if($saveReportToHardDrive -eq $true)
{
    ConvertTo-HTML -Body $HTMLmessage | Out-File C:\Users\Administrator\Desktop\powerShell\report.html
}

#Send mail
foreach ($to in $EmailTo) 
{
    $Body = $HTMLmessage
    $SMTPClient = New-Object Net.Mail.SmtpClient($PSEmailServer) 
    $message = New-Object Net.Mail.MailMessage($from, $to, $Subject, $Body)
    $message.IsBodyHtml = $true;
    $SMTPClient.Send($message)
}