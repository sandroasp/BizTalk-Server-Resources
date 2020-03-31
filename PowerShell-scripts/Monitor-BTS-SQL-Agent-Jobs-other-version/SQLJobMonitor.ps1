#########################################################
#                                                       #
# Monitoring JQL Jobs                                   #
#                                                       #
#########################################################

######################################################### 
# Load SMO extension DLL de SQL
######################################################### 
cls
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null;
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo.Agent") | Out-Null;

######################################################### 
# List of SQL Servers to be monitored 
#########################################################
$sqlservers = Get-Content ".\SQL.txt";

######################################################### 
# List of SQL Job that will not be subject to monitoring
#########################################################
$jobsToIgnore=@{
	"DTA Purge and Archive (BizTalkDTADb)" = "IGNORE"
}

#########################################################
# Monitoring Process
#########################################################
$report = foreach($sqlserver in $sqlservers) {
    # Create an SMO Server object
    $srv = New-Object "Microsoft.SqlServer.Management.Smo.Server" $sqlserver;  # srv vai ficar com o nome do servidor na lista sqlservers
    # total jobs and start the counters to 0.
    $totalJobCount = $srv.JobServer.Jobs.Count;
    $failedCount = 0;
    $successCount = 0;
    $Day = Get-Date ;
      
	$tmp = foreach($job in $srv.JobServer.Jobs) 
	{
    	$colour = "Green";
        $jobName = $job.Name;
        $jobEnabled = $job.IsEnabled;
        $jobLastRunOutcome = $job.LastRunOutcome;
        $jobLastRunDate= $job.LastRunDate;
        $detail = $job.EnumHistory();
        $timerows = $job.EnumHistory().Rows
                
        [string]$runDetails=""
        if($job.EnumHistory().Rows[0] -ne $null){
            [string]$runDetails=""+ $job.EnumHistory().Rows[0].Message
            if($job.EnumHistory().Rows[1] -ne $null){
                [string]$runDetails+="<br><br>"+ $job.EnumHistory().Rows[1].Message
            }
        }
        else{
			[string]$runDetails="-" 
		}
                        
        $executions = foreach ($row in $timerows) {
            if(-not $row.HasErrors){
                New-Object PSObject -Property @{Duration = $row.RunDuratio}
            }
        }
                
	    $media =  $executions | Measure-Object -Property Duration -Average | select -expand Average
	    if($timerows -ne $null) {
	        $lastRun =  $timerows[0]['RunDuration']
	    } 
		else
	    {
	        $lastRun = -1
	    }
                
        if($jobLastRunOutcome -eq "Failed")
        {
            #$colour = "Red";
            $failedCount += 1;
        }
        elseif ($jobLastRunOutcome -eq "Succeeded")
        {
            $successCount += 1;
        }
        New-Object PSObject -Property @{
           	Server = $sqlserver
           	JobName = $jobName
           	Enabled = $jobEnabled
           	OK = $successCount
           	Failed = $failedCount
           	LastRun = $jobLastRunOutcome 
           	StartTime = $jobLastRunDate
           	Duration = $lastRun
           	ExpectedDuration = $media
           	RunDetails=$runDetails
        }
                          
		##############################################################
		# Convert Seconds to Hours:Minutes:Seconds Table Duration    #
		##############################################################
		if ($lastRun -gt 9999) {
          	$hh = [int][Math]::Truncate($lastRun/10000);
          	$lastRun = $lastRun - ($hh*10000)
		}
		else {
		    $hh = 0
		}
	    if ($lastRun -gt 99) {
	    	$mm = [int][Math]::Truncate($lastRun/100); 
	     	$lastRun = $lastRun - ($mm*100)
	    }
	    else {
	        $mm = 0
	    }
		$dur = ("{0:D2}" -f $hh) + ':' + "{0:D2}" -f $mm + ':' + "{0:D2}" -f $lastRun
		     
		######################################################################
		# Convert Seconds to Hours:Minutes:Seconds Table ExpectedDuration    #
		######################################################################
	    [system.Double] $media
	    [Int32] $imedia = [System.Convert]::ToInt32($media);
     
    	if ($imedia -gt 9999) {
          	$h = [System.Double][Math]::Truncate($imedia/10000);
          	$imedia = $imedia - ($h*10000)
        }
        else {
          	$h = 0
        }
	    if ($imedia -gt 99) {
	     	$m = [System.Double][Math]::Truncate($media/100); 
	     	$imedia = $imedia - ($m*100)
	    }
        else {
          	$m = 0
        }
     	$expDura = ("{0:D2}" -f $h) + ':' + "{0:D2}" -f $m + ':' + "{0:D2}" -f $imedia 
	} 
}

$allLines=""

#########################################################
# Formating result
#########################################################
$tmp | ?{ $jobsToIgnore[$job.Name] -eq $null -and ($_.Enabled -eq $false -or $_.LastRun -ne "Succeeded")} |%{
     
    if($_ -ne 0){   
        $bodyEl ="<tr> <td> " + $sqlservers+ " </td>" 
        $bodyEl+="<td style='text-align:center;'> " + $_.JobName+ " </td>"  
        $bodyEl+="<td style='text-align:center;'> " + $_.Enabled  + " </td>"
        $bodyEl+="<td style='text-align:center;'> " + $_.LastRun  + " </td>"
        $bodyEl+="<td style='text-align:center;'> " + $_.Duration + " </td>"
        $bodyEl+="<td style='text-align:center;'> " + $_.StartTime + " </td>"
        $bodyEl+="<td style='text-align:justify;'> " + $_.RunDetails + " </td>"
    	 
        $end="</tr>"
        $allLines+=$bodyEl+$end        
    }
}

# Formating email result
$table="<table style='boder:0px 0px 0px 0px;'><tr><th>Server Name</th><th>Job Name</th>        
        <th>Enabled</th><th>Run Status</th><th>Duration</th><th>Run Date</th><th>Details</th>"
$tableBody=$allLines
$tableEnd="</table>"
$tableHtml=$table+$tableBody+$tableEnd

# HTML Format for Output
$HTMLmessage = @"
<font color=""black"" face=""Arial"" size=""3"">
<h1 style='font-family:arial;'><b>SQL Jobs Report</b></h1>
<p style='font: .8em ""Lucida Grande"", Tahoma, Arial, Helvetica, sans-serif;'>This report was generated because the jobs listed below have problems that need your atention. SQL Jobs that are functioning properly will not be listed.
</p>
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
$tableHtml
</body>
"@

######################################################### 
# Preparation of sending the email 
######################################################### 
$msg = New-Object Net.Mail.MailMessage    
if($tmp -ne $null) { 
    $smtpServer="mySMTPServer"
    $smtp = New-Object Net.Mail.SmtpClient -arg $smtpServer
    $fromemail = "suport@mail.net"
    $msg.From = $fromemail
    $users = "mail1@mail.net, mail2@mail.net"
    $msg.To.Add($users)
    $msg.Subject = "SQL Job Report "
    $msg.IsBodyHTML = $true
    $msg.Body = $HTMLmessage
    $smtp.Send($msg)   
}