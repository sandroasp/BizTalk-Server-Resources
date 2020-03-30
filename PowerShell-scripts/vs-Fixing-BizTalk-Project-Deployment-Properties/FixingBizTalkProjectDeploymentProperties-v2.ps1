#Set Path of BizTalk Server Solution
cd 'C:\<BizTalk Solution Path'

#Set BizTalk Project Deployment Properties
$ServerName= "<BizTalkServer>";
$DatabaseName= "BizTalkMgmtDb";
$ApplicationName= "<BTSApplicationName>";
$RedeployFlag= "True";
$RegisterFlag= "True";
$RestartHostInstancesFlag= "False";

#Control Properties (do not modify)
$addNewNodeFlag = $true

dir -Recurse *btproj.user | ForEach-Object { 
    $path = $_.FullName;
    $xml = [xml](Get-Content $path)

    $allPropertyGroup = $xml.Project.PropertyGroup
    foreach($node in $allPropertyGroup)
    {
        if($node.Server -ne $null)
        {
            #If the Deployment Setting already exists, then we just need to update them
            $addNewNodeFlag = $false
            $node.Server= $ServerName;
            $node.ConfigurationDatabase= $DatabaseName;
            $node.ApplicationName= $ApplicationName;
            $node.Redeploy= $RedeployFlag;
            $node.Register= $RegisterFlag;
            $node.RestartHostInstances= $RestartHostInstancesFlag;
        }
    }

    if($addNewNodeFlag -eq $true)
    {
        #Add a PropertyGroup node if the Deployment Setting doesn't exist
        $newXmlPropertyGroup = $xml.CreateElement("PropertyGroup", "http://schemas.microsoft.com/developer/msbuild/2003")
        $newXmlPropertyGroup.SetAttribute(“Condition”,”'`$(Configuration)|`$(Platform)' == 'Debug|AnyCPU'”);

        $newXmlElement = $newXmlPropertyGroup.AppendChild($xml.CreateElement("Server", "http://schemas.microsoft.com/developer/msbuild/2003"));
        $newXmlTextNode = $newXmlElement.AppendChild($xml.CreateTextNode($ServerName));
 
        $newXmlElement = $newXmlPropertyGroup.AppendChild($xml.CreateElement("ConfigurationDatabase", "http://schemas.microsoft.com/developer/msbuild/2003"));
        $newXmlTextNode = $newXmlElement.AppendChild($xml.CreateTextNode($DatabaseName));

        $newXmlElement = $newXmlPropertyGroup.AppendChild($xml.CreateElement("ApplicationName", "http://schemas.microsoft.com/developer/msbuild/2003"));
        $newXmlTextNode = $newXmlElement.AppendChild($xml.CreateTextNode($ApplicationName));

        $newXmlElement = $newXmlPropertyGroup.AppendChild($xml.CreateElement("Redeploy", "http://schemas.microsoft.com/developer/msbuild/2003"));
        $newXmlTextNode = $newXmlElement.AppendChild($xml.CreateTextNode($RedeployFlag));

        $newXmlElement = $newXmlPropertyGroup.AppendChild($xml.CreateElement("Register", "http://schemas.microsoft.com/developer/msbuild/2003"));
        $newXmlTextNode = $newXmlElement.AppendChild($xml.CreateTextNode($RegisterFlag));

        $newXmlElement = $newXmlPropertyGroup.AppendChild($xml.CreateElement("RestartHostInstances", "http://schemas.microsoft.com/developer/msbuild/2003"));
        $newXmlTextNode = $newXmlElement.AppendChild($xml.CreateTextNode($RestartHostInstancesFlag));

        $xml.Project.InsertAfter($newXmlPropertyGroup, $xml.Project.PropertyGroup[1])
    }
    $xml.Save($path);
}