#Name template for BizTalk Server CU's for BizTalk Server 2016 (normally they are "Microsoft BizTalk Server 2016 CU#")
$CUNameTemplate = 'BizTalk Server 2016 CU'

#The Wow6432 registry entry indicates that you're running a 64-bit version of Windows. 
#It will use this key for 32-bit applications that run on a 64-bit version of Windows. 
$keyResults = Get-ChildItem -path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\ -Recurse -ErrorAction SilentlyContinue | where { $_.Name -match $CUNameTemplate}

if($keyResults.Count -gt 0)
{
    write-host "This is the list of BizTalk Cumulative Update installed in this machine: $env:computername"
}
else
{
    write-host "There is the no BizTalk Cumulative Update installed in this machine: $env:computername"
}    

foreach($keyItem in $keyResults)
{
    if ($keyItem.GetValue("DisplayName") -like "*$CUNameTemplate*")
    {
        write-host "-" $keyItem.GetValue("DisplayName").ToString().Substring(0,$keyItem.GetValue("DisplayName").ToString().IndexOf(" CU")+4)
    }
}