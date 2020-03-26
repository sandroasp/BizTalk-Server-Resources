$keys = Get-ChildItem -Path Registry::'HKEY_LOCAL_MACHINE\SOFTWARE\WOW6432Node\Microsoft\E-Business Servers Updates\'

$findF1 = 0

foreach ($key in $keys) 
{
    if($findF1 -eq $true)
    {
        break
    }

    foreach ($Property in $key.Property) 
    {
        if ($Property -like '*Microsoft BizTalk Server 2016 Feature Pack 1*') 
        { 
            $findF1 = 1
            Write-Host 'Microsoft BizTalk Server 2016 Feature Pack 1 is installed'
            break
        }
    }
}

$findF2 = 0

foreach ($key in $keys) 
{
    if($findF2 -eq $true)
    {
        break
    }

    foreach ($Property in $key.Property) 
    {
        if ($Property -like '*Microsoft BizTalk Server 2016 Feature Update *') 
        { 
            $findF2 = 1
            Write-Host "$($Property) is installed"
        }
    }
}

if(($findF1 -eq $false) -And ($findF2 -eq $false)) 
{
    Write-Host 'Microsoft BizTalk Server 2016 Feature Pack is not installed'
}