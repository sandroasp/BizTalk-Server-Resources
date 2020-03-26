# Set Global Variables
# NT Group Name configure to run orchestrations, normally "BizTalk Application Users"
[string]$global:qaNTGroupName = 'DOMAIN\BizTalk QA Application Users'
[string]$global:prdNTGroupName = 'DOMAIN\BizTalk PRD Application Users'

function bts-resource-exportbindings-by-assembly-name([string]$bindingFilePath, [string]$appName, [string]$assemblyName, [boolean]$generateDiffEnvBindings)
{
    $list= BTSTask.exe ListApp /ApplicationName:$appName 

    $list |foreach {
	    if ($_ -like '*Resource:*')
        {
            if($_.Split('-')[1].Split('"')[1] -eq "System.BizTalk:BizTalkAssembly")
            {
                $varAssemblyFQName = $_.Split('-')[2].Split('"')[1]
                $verison = $_.Split('-')[2].Split('"')[1].Split("=")[1].Split(",")[0]
                if($varAssemblyFQName -like "*"+ $assemblyName + "*")
                {
                    $taskParams = ” ExportBindings /Destination:$bindingfilePath$appName.$assemblyName.$verison.BindingInfo.xml /AssemblyName:""$varAssemblyFQName"" ”
                    Start-Process "BTSTask.exe" $taskParams -Wait

                    if($generateDiffEnvBindings)
                    {
                        $xml = [xml](Get-Content "$bindingfilePath$appName.$assemblyName.$verison.BindingInfo.xml")
    
                        # QA Binding Info Generation
                        $xml.SelectNodes("//Host") | % { 
                            $_.NtGroupName = $global:qaNTGroupName
                        }
                        $xml.Save("$bindingfilePath$appName.$assemblyName.$verison.QA.BindingInfo.xml")

                        # PRD Binding Info Generation
                        $xml.SelectNodes("//Host") | % { 
                            $_.NtGroupName = $global:prdNTGroupName
                        }
                        $xml.Save("$bindingfilePath$appName.$assemblyName.$verison.PRD.BindingInfo.xml")
                    }
                }
            }
        }
    }
}

bts-resource-exportbindings-by-assembly-name 'C:\temp\BTS\' 'BizTalk Application 1' 'Assembly1' $True