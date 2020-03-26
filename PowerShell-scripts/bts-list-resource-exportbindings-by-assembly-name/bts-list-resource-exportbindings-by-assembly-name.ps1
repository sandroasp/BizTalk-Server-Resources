# Set Global Variables
# NT Group Name configure to run orchestrations, normally "BizTalk Application Users"
[string]$global:qaNTGroupName = 'DOMAIN\BizTalk QA Application Users'
[string]$global:prdNTGroupName = 'DOMAIN\BizTalk PRD Application Users'

function bts-list-resource-exportbindings-by-assembly-name([string]$bindingFilePath, [string]$appName, [string]$listAssemblyName, [boolean]$generateDiffEnvBindings) 
{ 
    #splits all the assemblies by | 
    $list = $listAssemblyName.Split("|")  
    $finalBinding = [xml](Get-Content "C:\Temp\TemplateBindingInfo.xml") 
    $moduleRefNode = $finalBinding.SelectSingleNode("BindingInfo/ModuleRefCollection") 
    $sendPortNode = $finalBinding.SelectSingleNode("BindingInfo/SendPortCollection") 
    $receivePortNode = $finalBinding.SelectSingleNode("BindingInfo/ReceivePortCollection") 
    $displayName = 'assemblyName' 
    $appsList=New-Object System.Collections.ArrayList 
    $assemblyListFQN = New-Object System.Collections.ArrayList      
    $appsList = BTSTask.exe ListApp /ApplicationName:$appName 
    #region Add FQN to list 
    foreach($string in $appsList) 
    {          
        #region Get Assembly Fully Qualified Name 
        $list = $listAssemblyName.Split("|") 
                     
        foreach($element in $list) 
        {  
            if($string.Contains('-')) 
            { 
                if($string.Split('-')[1].Split('"')[1] -eq "System.BizTalk:BizTalkAssembly") 
                { 
                    foreach($element in $list){       
                        if($string.Split('-')[2].Split('"')[1].StartsWith($element)) 
                        { 
                            if(!$assemblyListFQN.Contains($string.Split('-')[2].Split('"')[1])){ 
                                $assemblyListFQN.Add($string.Split('-')[2].Split('"')[1]); 
                                #display name Set 
                            } 
                        } 
                    } 
                } 
            } 
        } 
        #endregion    
    } 
    #endregion 
     
    #loop assemblies 
    foreach($string in $assemblyListFQN) 
    {         
        $dllName = $string.Substring(0, $string.IndexOf(',')) 
        $taskParams = ” ExportBindings /Destination:$bindingfilePath$appName.$dllName.BindingInfo.xml /AssemblyName:""$string"" ” 
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
 
    #generate different Environments Bindings 
    if($generateDiffEnvBindings) 
    { 
        $xml = [xml](Get-Content "$bindingfilePath$appName.BindingInfo.xml") 
     
        # QA Binding Info Generation 
        $xml.SelectNodes("//Host") | % {  
            if(!$_.Attributes['xsi:nil'].Value) 
            { 
                $_.NtGroupName = $global:qaNTGroupName 
            } 
        } 
        $xml.Save("$bindingfilePath$appName.QA.BindingInfo.xml") 
 
        # PRD Binding Info Generation 
        $xml.SelectNodes("//Host") | % {  
            if(!$_.Attributes['xsi:nil'].Value) 
            { 
                $_.NtGroupName = $global:prdNTGroupName 
            } 
        } 
        $xml.Save("$bindingfilePath$appName.PRD.BindingInfo.xml") 
    } 
}

bts-list-resource-exportbindings-by-assembly-name 'C:\temp\BTS\' 'BizTalk Application 1' 'Demo' $True