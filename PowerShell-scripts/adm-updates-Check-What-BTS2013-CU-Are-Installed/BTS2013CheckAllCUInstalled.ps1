#Name template for BizTalk Server CU's for BizTalk Server 2013 (normally they are "Microsoft BizTalk Server 2013 CU#")
$CUNameTemplate = 'Microsoft BizTalk Server 2013 CU'

#The Wow6432 registry entry indicates that you're running a 64-bit version of Windows. 
#It will use this key for 32-bit applications that run on a 64-bit version of Windows. 
$keyResults = Get-ChildItem -path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ -Recurse -ErrorAction SilentlyContinue | where { $_.Name -match $CUNameTemplate}

if($keyResults.Count -gt 0)
{
    write-host "This is the list of BizTalk Server 2013 Cumulative Update installed in this machine: $env:computername"
}
else
{
    write-host "There is the no BizTalk Server 2013 Cumulative Update installed in this machine: $env:computername"
}    

foreach($keyItem in $keyResults)
{
    if ($keyItem.GetValue("DisplayName") -like "*$CUNameTemplate*")
    {
        write-host "-" $keyItem.GetValue("DisplayName").ToString().Substring(0,$keyItem.GetValue("DisplayName").ToString().IndexOf(" CU")+4)
    }
}

write-host ""

#Name template for BizTalk Server Adapter Pack CU's for BizTalk Server 2013 (normally they are "BizTalk Adapter Pack 2013 CU#")
$CUNameTemplate = 'BizTalk Adapter Pack 2013 CU'

#The Wow6432 registry entry indicates that you're running a 64-bit version of Windows. 
#It will use this key for 32-bit applications that run on a 64-bit version of Windows. 
$keyResults = Get-ChildItem -path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ -Recurse -ErrorAction SilentlyContinue | where { $_.Name -match $CUNameTemplate}

if($keyResults.Count -gt 0)
{
    write-host "This is the list of BizTalk Server 2013 Adapter Pack Cumulative Update installed in this machine: $env:computername"
}
else
{
    write-host "There is the no BizTalk Server 2013 Adapter Pack Cumulative Update installed in this machine: $env:computername"
}    

foreach($keyItem in $keyResults)
{
    if ($keyItem.GetValue("DisplayName") -like "*$CUNameTemplate*")
    {
        write-host "-" $keyItem.GetValue("DisplayName").ToString().Substring(0,$keyItem.GetValue("DisplayName").ToString().IndexOf(" CU")+4)
    }
}