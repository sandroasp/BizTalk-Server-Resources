# Set Global Variables
# NT Group Name configure to run orchestrations, normally "BizTalk Application Users"
[string]$global:qaNTGroupName = 'DOMAIN\BizTalk QA Application Users'
[string]$global:prdNTGroupName = 'DOMAIN\BizTalk PRD Application Users'

function bts-resource-exportbindings-by-assembly-fqname([string]$bindingFilePath, [string]$appName, [string]$assemblyFQName, [boolean]$generateDiffEnvBindings)
{
    $dllName = $assemblyFQName.Substring(0, $assemblyFQName.IndexOf(','))
    $taskParams = ” ExportBindings /Destination:$bindingfilePath$appName.$dllName.BindingInfo.xml /AssemblyName:""$assemblyFQName"" ”
    Start-Process "BTSTask.exe" $taskParams -Wait

    if($generateDiffEnvBindings)
    {
        $xml = [xml](Get-Content "$bindingfilePath$appName.$dllName.BindingInfo.xml")
    
        # QA Binding Info Generation
        $xml.SelectNodes("//Host") | % { 
            $_.NtGroupName = $global:qaNTGroupName
        }
        $xml.Save("$bindingfilePath$appName.$dllName.QA.BindingInfo.xml")

        # PRD Binding Info Generation
        $xml.SelectNodes("//Host") | % { 
            $_.NtGroupName = $global:prdNTGroupName
        }
        $xml.Save("$bindingfilePath$appName.$dllName.PRD.BindingInfo.xml")
    }
}

bts-resource-exportbindings-by-assembly-fqname 'C:\temp\BTS\' 'Pmc.Feiserver' 'TriggerPollingPOC, Version=1.0.0.0, Culture=neutral, PublicKeyToken=eebb1a3d8ea686f3' $True