# Set Global Variables
# NT Group Name configure to run orchestrations, normally "BizTalk Application Users"
[string]$global:qaNTGroupName = 'DOMAIN\BizTalk QA Application Users'
[string]$global:prdNTGroupName = 'DOMAIN\BizTalk PRD Application Users'

function bts-application-exportbindings([string]$bindingFilePath, [string]$appName, [boolean]$generateDiffEnvBindings)
{
    $taskParams = ” ExportBindings /Destination:$bindingfilePath$appName.BindingInfo.xml /ApplicationName:$appName ”
    #First version: $p = [diagnostics.process]::start(“BTSTask.exe”, $taskParams)
    Start-Process "BTSTask.exe" $taskParams -Wait

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

bts-application-exportbindings 'C:\temp\BTS\' 'BizTalk Application 1' $True