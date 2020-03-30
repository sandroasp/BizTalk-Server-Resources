#Set mail variables
[STRING]$PSEmailServer = "smtp"
[STRING]$Subject = "PROD: BizTalk Job Monitor"
[STRING]$From = "biztalk@monitor.com"
[array]$EmailTo = ("support@biztalk.com")

$sqlQuery = 'C:\Users\Administrator\Desktop\SQL\check_jobs.sql';
$server = 'SQLSERVER';

$mydata = invoke-sqlcmd -inputfile $sqlQuery -serverinstance $server

[INT]$i = 1

#Create mail content
$mailBody = ""

Foreach ($log in $mydata)
{

    $mailBody += "<th><b>Suspended message $i</b></th>"
    $mailBody += "<table style='boder:0px 0px 0px 0px;'>"
    
    $mailBody += "<TR style='background-color:white;'><TD>Job Name</TD>"
    $mailBody += "<TD>" + $log.'Job Name' + "</TD></TR>"
    
    $mailBody += "<TR style='background-color:rgb(245,245,245);';><TD>Last Scheduled Run Date</TD>"
    $mailBody += "<TD>" + $log.'Last Scheduled Run Date' + "</TD></TR>"
    
    $mailBody += "<TR style='background-color:white;'><TD>Minutes Delayed</TD>"
    $mailBody += "<TD>" + $log.'Minutes Delayed' + "</TD></TR>"
    
    $mailBody += "<TR style='background-color:rgb(245,245,245);'><TD>Job Status</TD>"
    $mailBody += "<TD>" + $log.'Job Status' + "</TD></TR>"

    $mailBody += "</table>"
    $mailBody += "<BR><BR>"
    
    $i ++
}

$count = $i - 1;
$mailTextReport = "This report was generated because there are "+ $count  + " Jobs in non-compliance that require your attention." 

    # HTML Format for Output 
$HTMLmessage = @"
<font color=""black"" face=""Arial"" size=""3"">
<h1 style='font-family:arial;'><b>BizTalk Jobs Report</b></h1>
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

