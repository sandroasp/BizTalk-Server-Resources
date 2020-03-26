function bts-list-ports-exportbindings([string]$bindingFilePath, [string]$bindingNamePrefix, [string]$appName, [string]$rcvPortNames, [string]$sndPortNames, [boolean]$generateDiffEnvBindings)
{
    $finalBinding = [xml](Get-Content "C:\Temp\BTS\TemplateBindingInfo.xml")
    $moduleRefNode = $finalBinding.SelectSingleNode("BindingInfo/ModuleRefCollection")
    $sendPortNode = $finalBinding.SelectSingleNode("BindingInfo/SendPortCollection")
    $receivePortNode = $finalBinding.SelectSingleNode("BindingInfo/ReceivePortCollection")

    $listRcvPorts = $rcvPortNames.Split("|")
    $listSndPorts = $sndPortNames.Split("|")

    $taskParams = ” ExportBindings /Destination:$bindingfilePath$appName.BindingInfo.xml /ApplicationName:$appName ”
    Start-Process "BTSTask.exe" $taskParams -Wait

    $xml = [xml](Get-Content "$bindingfilePath$appName.BindingInfo.xml")

    foreach($receivePortBinding in $xml.BindingInfo.ReceivePortCollection.ReceivePort)
    {
        if($listRcvPorts -Contains $receivePortBinding.Name)
        {
            $node = $finalBinding.ImportNode(($receivePortBinding), $true);
            $receivePortNode.AppendChild($node);
        }
    }

    foreach($sendPortBinding in $xml.BindingInfo.SendPortCollection.SendPort)
    {
        if($listSndPorts -Contains $sendPortBinding.Name)
        {
            $node = $finalBinding.ImportNode(($sendPortBinding), $true);
            $sendPortNode.AppendChild($node);
        }
    }

    $finalBinding.Save("$bindingfilePath$bindingNamePrefix.BindingInfo.xml")

    if($generateDiffEnvBindings)
    {
        $finalBinding.Save("$bindingfilePath$bindingNamePrefix.QA.BindingInfo.xml")
        $finalBinding.Save("$bindingfilePath$bindingNamePrefix.PRD.BindingInfo.xml")
    }
}

bts-list-ports-exportbindings 'C:\temp\BTS\' 'CBR' 'CBRwithLOBOperations' 'WCF_IN_CBRwithLOB|DEL' 'WcfSendPort_SqlAdapterBinding_TableOp_dbo_Person_Custom' $True