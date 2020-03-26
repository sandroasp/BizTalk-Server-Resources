# Set Global Variables
# NT Group Name configure to run orchestrations, normally "BizTalk Application Users"
[string]$global:qaNTGroupName = 'DOMAIN\BizTalk QA Application Users'
[string]$global:prdNTGroupName = 'DOMAIN\BizTalk PRD Application Users'

function bts-receive-port-exportbindings([string]$bindingFilePath, [string]$appName, [string]$portName, [boolean]$generateDiffEnvBindings)
{
    $portRen = $portName.Replace(" ", "")

    $taskParams = ” ExportBindings /Destination:$bindingfilePath$appName.$portRen.BindingInfo.xml /ApplicationName:$appName ”
    #First version: $p = [diagnostics.process]::start(“BTSTask.exe”, $taskParams)
    Start-Process "BTSTask.exe" $taskParams -Wait

    $xml = [xml](Get-Content "$bindingfilePath$appName.$portRen.BindingInfo.xml")
    foreach($RemoveModuleRef in $xml.BindingInfo.ModuleRefCollection.ModuleRef)
    {
        $xml.BindingInfo.ModuleRefCollection.RemoveChild($RemoveModuleRef)
    }
    foreach($RemoveSendPort in $xml.BindingInfo.SendPortCollection.SendPort)
    {
        $xml.BindingInfo.SendPortCollection.RemoveChild($RemoveSendPort)
    }
    foreach($RemoveReceivePort in $xml.BindingInfo.ReceivePortCollection.ReceivePort)
    {
        if($RemoveReceivePort.Name -ne $portName)
        {
            $xml.BindingInfo.ReceivePortCollection.RemoveChild($RemoveReceivePort)
        }
    }
    $xml.Save("$bindingfilePath$appName.$portRen.BindingInfo.xml")

    if($generateDiffEnvBindings)
    {
        $xml.Save("$bindingfilePath$appName.$portRen.QA.BindingInfo.xml")
        $xml.Save("$bindingfilePath$appName.$portRen.PRD.BindingInfo.xml")
    }
}

bts-receive-port-exportbindings 'C:\temp\BTS\' 'BizTalk Application 1' 'MY_SCH_PORT' $True