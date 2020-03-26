$registryPath = "HKLM:\Software\Microsoft\ENTSSO"
if(Test-Path $registryPath)
{
    Set-ItemProperty -Path $registryPath -Name InstallPath -Value "C:\Program Files\Common Files\Enterprise Single Sign-On\"
    Set-ItemProperty -Path $registryPath -Name ProductCode -Value "{F89B22BC-2768-4237-B300-5CFA52D9AC84}"
    Set-ItemProperty -Path $registryPath -Name ProductLanguage -Value "1033"
    Set-ItemProperty -Path $registryPath -Name ProductName -Value "Microsoft Enterprise Single Sign-On"
    Set-ItemProperty -Path $registryPath -Name ProductVersion -Value "10.0.2242.0"
}
else 
{
    write-Error "Registry path: $registryPath not found!"
}