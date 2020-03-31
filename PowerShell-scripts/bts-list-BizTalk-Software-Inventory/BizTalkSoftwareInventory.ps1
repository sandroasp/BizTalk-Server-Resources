$strComputer = "."
$arrVersions = "3.0.4902.0", "3.0.6070.0", "3.0.7405.0", "3.5.1602.0", "3.6.1404.0", "3.8.368.0", "3.9.469.0" 
$location = get-location

$colItems = get-wmiobject -class "Win32_Product" -namespace "root\CIMV2" `
-computername $strComputer

foreach ($objItem in $colItems) {
  $Caption = $objItem.Caption

  if (($Caption -like "*BizTalk*") -and (($Caption -notlike "*BizTalk Server Setup*")))
  {
    write-host "Caption: " $objItem.Caption
    write-host "Description: " $objItem.Description
    write-host "Installation Date: " $objItem.InstallDate
    write-host "Installation Location: " $objItem.InstallLocation
    write-host "Name: " $objItem.Name
    write-host "Version: " $objItem.Version
    if( ($arrVersions -contains $objItem.Version) -like "True")
    {
      $bizTalkRegistryPath = "HKLM:\SOFTWARE\Microsoft\BizTalk Server"
      Set-Location $bizTalkRegistryPath
      $key = Get-ChildItem  
      write-host "Product Edition: " $key.GetValue("ProductEdition")
      Set-Location $location
    }
    write-host "Vendor: " $objItem.Vendor
    write-host
  }
}