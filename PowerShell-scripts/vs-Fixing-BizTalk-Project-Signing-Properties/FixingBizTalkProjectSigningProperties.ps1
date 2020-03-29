$keyPath = 'C:\<BizTalk Solution Path>\<keyname>.snk';
$keyName = '<keyname>.snk';

cd 'C:\<BizTalk Solution Path>';

dir -Recurse *btproj | ForEach-Object { 
    $path = $_.FullName;
    $xml = [xml](Get-Content $path);
    $xdNS = $xml.DocumentElement.NamespaceURI;
    
    $keyDestinationPath = $_.Directory.FullName + '\' + $keyName;
    Copy-Item -Path $keyPath -Destination $keyDestinationPath;

    $addNewSignNodeFlag = $true;
    $addNewKeyNodeFlag = $true;
    $allPropertyGroup = $xml.Project.PropertyGroup
    foreach($node in $allPropertyGroup)
    {
        if($node.AssemblyOriginatorKeyFile -ne $null)
        {
            $addNewKeyNodeFlag = $false;
            $node.AssemblyOriginatorKeyFile= $keyName;
        }

        if($node.SignAssembly -ne $null)
        {
            $addNewSignNodeFlag = $false;
            $node.SignAssembly= $true;
        }
    }

    if($addNewKeyNodeFlag -eq $true)
    {
        $childItemGroup = $xml.CreateElement("PropertyGroup",$xdNS)
        $childNone = $xml.CreateElement("AssemblyOriginatorKeyFile",$xdNS)
        $childNone.AppendChild($xml.CreateTextNode($keyName));
        $childItemGroup.AppendChild($childNone)
        $xml.Project.InsertBefore($childItemGroup, $xml.Project.ItemGroup[0])
    }

    if($addNewSignNodeFlag -eq $true)
    {
        $childItemGroup = $xml.CreateElement("PropertyGroup",$xdNS)
        $childNone = $xml.CreateElement("SignAssembly",$xdNS)
        $childNone.AppendChild($xml.CreateTextNode($true));
        $childItemGroup.AppendChild($childNone)
        $xml.Project.InsertBefore($childItemGroup, $xml.Project.ItemGroup[0])
    }

    $addKeyToSolutionFlag = $true;
    $allItemGroup = $xml.Project.ItemGroup.None;
    foreach($node in $allItemGroup)
    {
        if($node.Include -eq $keyName)
        {
            $addKeyToSolutionFlag = $false;
        }
    }

    if($addKeyToSolutionFlag -eq $true)
    {
        $childItemGroup = $xml.CreateElement("ItemGroup",$xdNS)
        $childNone = $xml.CreateElement("None",$xdNS)
        $childNone.SetAttribute("Include", $keyName)
        $childItemGroup.AppendChild($childNone)
        $xml.Project.InsertBefore($childItemGroup, $xml.Project.Import[0])
    }

    $xml.Save($path);
}