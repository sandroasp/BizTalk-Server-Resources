#Set Path of BizTalk Server Solution
cd 'C:\<BizTalk Solution Path'

#Set BizTalk Project Deployment Properties
$ServerName= "<BizTalkServer>";
$DatabaseName= "BizTalkMgmtDb";
$ApplicationName= "<BTSApplicationName>";
$RedeployFlag= "True";
$RegisterFlag= "True";
$RestartHostInstancesFlag= "False";

# Iterate all *.btproj.user files
Get-ChildItem -Recurse -Filter *btproj.user | ForEach-Object { 
    $path = $_.FullName
    $xml = [xml](Get-Content $path)

    $namespaceUri = "http://schemas.microsoft.com/developer/msbuild/2003"
    $nsmgr = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
    $nsmgr.AddNamespace("ns", $namespaceUri)

    # Find any existing PropertyGroup
    $propertyGroup = $xml.SelectSingleNode("//ns:PropertyGroup", $nsmgr)

    if ($propertyGroup -ne $null) {
        # PropertyGroup exists → update or add the necessary elements
        $properties = @{
            "Server" = $ServerName
            "ConfigurationDatabase" = $DatabaseName
            "ApplicationName" = $ApplicationName
            "Redeploy" = $RedeployFlag
            "Register" = $RegisterFlag
            "RestartHostInstances" = $RestartHostInstancesFlag
        }

        foreach ($key in $properties.Keys) {
            $element = $propertyGroup.SelectSingleNode("ns:$key", $nsmgr)
            if ($element -ne $null) {
                # Update existing element
                $element.InnerText = $properties[$key]
            }
            else {
                # Create new element if missing
                $newElement = $xml.CreateElement($key, $namespaceUri)
                $newElement.InnerText = $properties[$key]
                $propertyGroup.AppendChild($newElement) | Out-Null
            }
        }
    }
    else {
        # No PropertyGroup exists → create one and add all properties
        $newPropertyGroup = $xml.CreateElement("PropertyGroup", $namespaceUri)

        $properties = @{
            "Server" = $ServerName
            "ConfigurationDatabase" = $DatabaseName
            "ApplicationName" = $ApplicationName
            "Redeploy" = $RedeployFlag
            "Register" = $RegisterFlag
            "RestartHostInstances" = $RestartHostInstancesFlag
        }

        foreach ($key in $properties.Keys) {
            $element = $xml.CreateElement($key, $namespaceUri)
            $element.InnerText = $properties[$key]
            $newPropertyGroup.AppendChild($element) | Out-Null
        }

        $xml.Project.AppendChild($newPropertyGroup) | Out-Null
    }

    # Save the modified XML
    $xml.Save($path)
}