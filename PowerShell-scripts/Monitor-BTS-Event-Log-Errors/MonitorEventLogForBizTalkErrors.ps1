#Set mail variables
[STRING]$PSEmailServer = "smtp"
[STRING]$Subject = "BizTalk Event Viewer Monitor"
[STRING]$From = "biztalk@support.com"
[array]$EmailTo = ("support@biztalk.com")

$getEventLog = Get-Eventlog -log application -after ((get-date).AddHours(-4)) -EntryType Error | Where-Object {($_.Source -eq 'BizTalk Server')} 

[INT]$i = 1

#Create mail content
$mailBody = ""

Foreach ($log in $getEventLog)
{

    $mailBody += "<th><b>Event log error message: " + $getEventLog.Index + "</b></th>"
    $mailBody += "<table style='boder:0px 0px 0px 0px;'>"
    
    $mailBody += "<TR style='background-color:white;'><TD>Time</TD>"
    $mailBody += "<TD>" + $getEventLog.TimeWritten + "</TD></TR>"
    
    $mailBody += "<TR style='background-color:rgb(245,245,245);';><TD>Source</TD>"
    $mailBody += "<TD>" + $getEventLog.Source + "</TD></TR>"
    
    $mailBody += "<TR style='background-color:white;'><TD>Message</TD>"
    $mailBody += "<TD>" + $getEventLog.Message + "</TD></TR>"
    
    $mailBody += "<TR style='background-color:rgb(245,245,245);'><TD>Machine Name</TD>"
    $mailBody += "<TD>" + $getEventLog.MachineName + "</TD></TR>"

    $mailBody += "</table>"
    $mailBody += "<BR><BR>"
    
    $i ++
}

$count = $i - 1;
$mailTextReport = "This report was generated because there are "+ $count  + " error messages in the Event Viewer that require your attention." 

    # HTML Format for Output 
$HTMLmessage = @"
<font color=""black"" face=""Arial"" size=""3"">
<h1 style='font-family:arial;'><b>BizTalk Event Viewer Report</b></h1>
<p style='font: .8em ""Lucida Grande"", Tahoma, Arial, Helvetica, sans-serif;'>$mailTextReport</p>
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
$mailBody
</body>
"@

if($count -gt 0)
{
    #Send mail
    foreach ($to in $EmailTo) 
    {
        $Body = $HTMLmessage
        $SMTPClient = New-Object Net.Mail.SmtpClient($PSEmailServer) 
        $message = New-Object Net.Mail.MailMessage($from, $to, $Subject, $Body)
        $message.IsBodyHtml = $true;
        $SMTPClient.Send($message)
    }
}

