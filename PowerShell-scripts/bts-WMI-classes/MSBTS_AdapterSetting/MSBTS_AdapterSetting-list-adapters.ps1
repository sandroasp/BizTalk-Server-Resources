function get-adapter (
    [string]$adapter) 
{
    # Get the Send Port Group by name
    $adapterInfo = get-wmiobject MSBTS_AdapterSetting -Namespace 'root\MicrosoftBizTalkServer' -Filter "name='$adapter'"
}

function list-biztalk-server-adapters()
{
    $adapters = get-wmiobject MSBTS_AdapterSetting -Namespace 'root\MicrosoftBizTalkServer'

    foreach ($adapterInfo in $adapters)
    {
        Write-Output "Adapter name: $($adapterInfo.Name)" 
    }
    Write-Output "Total No. of Adapters in $($adapters.Length)"
}

list-biztalk-server-adaptars

get-adapter 'WCF-WSHttp'