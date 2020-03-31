#########################################################
#                                                       #
# Monitoring Disk Space                                 #
#                                                       #
#########################################################

#########################################################
# List of computers to be monitored
#########################################################
param (
      $serverList =  "C:\\Machine.txt"
)
$computers = Get-Content $serverList

#########################################################
# List of users who will receive the report
#########################################################
$mailto = "mail1@mail.net, mail2@mail.net" 

#########################################################
# SMTP properties
#########################################################
$emailFrom = "suport@mail.net"
$smtpServer = "myAnonymousSmtpServer" #SMTP Server.

#########################################################
# Configuration of alarmists
#########################################################
[decimal]$warningThresholdSpace = 20 # Percentage of free disk space - Warning (orange).
[decimal]$criticalThresholdSpace = 10 # Percentage of free disk space - critical (red)

#########################################################
# Monitoring Process
#########################################################
[System.Array]$results = foreach ($cmp in $computers) { 
 Get-WMIObject  -ComputerName $cmp Win32_LogicalDisk |
where{($_.DriveType -eq 3) -and (($_.freespace/$_.size*100) -lt $warningThresholdSpace) }|
select @{n='Server Name' ;e={"{0:n0}" -f ($cmp)}},
@{n='Volume Name' ;e={"{0:n0}" -f ($_.volumename)}},
@{n='Driver' ;e={"{0:n0}" -f ($_.name)}},
@{n='Capacity (Gb)' ;e={"{0:n2}" -f ($_.size/1gb)}},
@{n='Free Space (Gb)';e={"{0:n2}" -f ($_.freespace/1gb)}},
@{n='Percentage Free';e={"{0:n2}%" -f ($_.freespace/$_.size*100)}}
}


#########################################################
# Formating result
#########################################################
$tableFragment = $results | ConvertTo-HTML -fragment

# HTML Format for Output 
$HTMLmessage = @"
<font color=""black"" face=""Arial"" size=""3"">
<h1 style='font-family:arial;'><b>Disk Space Storage Report</b></h1>
<p style='font: .8em ""Lucida Grande"", Tahoma, Arial, Helvetica, sans-serif;'>This report was generated because the drive(s) listed below have less than $warningThresholdSpace % free space. Drives above this threshold will not be listed.</p>
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
$tableFragment
</body>
"@


#########################################################
# Validation and sending email
#########################################################
# Regular expression to get what's inside of <td>'s
$regexsubject = $HTMLmessage
$regex = [regex] '(?im)<td>'

# If you have data between <td>'s then you need to send the email
if ($regex.IsMatch($regexsubject)) {
     send-mailmessage -from $emailFrom -to $mailto -subject "Disk Space Alert for $computer" -BodyAsHTML -body $HTMLmessage -priority High -smtpServer $smtpServer
}