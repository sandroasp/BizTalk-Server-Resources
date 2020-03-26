# Set Global Variables
# NT Group Name configure to run orchestrations, normally "BizTalk Application Users"
[string]$global:qaNTGroupName = 'DOMAIN\BizTalk QA Application Users'
[string]$global:prdNTGroupName = 'DOMAIN\BizTalk PRD Application Users'

function bts-list-resource-exportbindings-by-assembly-fqname([string]$bindingFilePath, [string]$appName, [string]$listAssemblyFQName, [boolean]$generateDiffEnvBindings)
{
    $finalBinding = [xml](Get-Content "C:\Temp\BTS\TemplateBindingInfo.xml")
    $moduleRefNode = $finalBinding.SelectSingleNode("BindingInfo/ModuleRefCollection")
    $sendPortNode = $finalBinding.SelectSingleNode("BindingInfo/SendPortCollection")
    $receivePortNode = $finalBinding.SelectSingleNode("BindingInfo/ReceivePortCollection")

    $list = $listAssemblyFQName.Split("|")

    foreach($element in $list)
    {
        $dllName = $element.Substring(0, $element.IndexOf(','))
        $taskParams = ” ExportBindings /Destination:$bindingfilePath$appName.$dllName.BindingInfo.xml /AssemblyName:""$element"" ”
        Start-Process "BTSTask.exe" $taskParams -Wait

        $xml = [xml](Get-Content "$bindingfilePath$appName.$dllName.BindingInfo.xml")

        foreach($moduleRef in $xml.BindingInfo.ModuleRefCollection.ModuleRef)
        {
            $node = $finalBinding.ImportNode(($moduleRef), $true);
            $moduleRefNode.AppendChild($node);
        }
        foreach($sendPort in $xml.BindingInfo.SendPortCollection.SendPort)
        {
            $node = $finalBinding.ImportNode(($sendPort), $true);
            $sendPortNode.AppendChild($node);
        }
        foreach($receivePort in $xml.BindingInfo.ReceivePortCollection.ReceivePort)
        {
            $node = $finalBinding.ImportNode(($receivePort), $true);
            $receivePortNode.AppendChild($node);
        }
    }

    $finalBinding.Save("$bindingfilePath$appName.BindingInfo.xml")

    if($generateDiffEnvBindings)
    {
        $xml = [xml](Get-Content "$bindingfilePath$appName.BindingInfo.xml")
    
        # QA Binding Info Generation
        $xml.SelectNodes("//Host") | % { 
            $_.NtGroupName = $global:qaNTGroupName
        }
        $xml.Save("$bindingfilePath$appName.QA.BindingInfo.xml")

        # PRD Binding Info Generation
        $xml.SelectNodes("//Host") | % { 
            $_.NtGroupName = $global:prdNTGroupName
        }
        $xml.Save("$bindingfilePath$appName.PRD.BindingInfo.xml")
    }
}

bts-list-resource-exportbindings-by-assembly-fqname 'C:\temp\BTS\' 'BizTalk Application 1' 'Demo, Version=1.0.0.0, Culture=neutral, PublicKeyToken=2c1d70bd6e7838d6|WorkingWithCorrelations, Version=1.0.0.0, Culture=neutral, PublicKeyToken=b85c641a8cbf55cb' $True