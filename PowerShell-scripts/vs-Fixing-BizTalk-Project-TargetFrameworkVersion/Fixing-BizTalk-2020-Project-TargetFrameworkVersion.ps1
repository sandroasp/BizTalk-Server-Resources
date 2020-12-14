#Set Path of BizTalk Server Solution
cd 'C:\<BizTalk Solution Path'

#Set BizTalk Project Deployment Properties
$TargetFrameworkVersion= "v4.6";

#Control Properties (do not modify)
$addNewNodeFlag = $true

dir -Recurse *.btproj | ForEach-Object { 
    $path = $_.FullName;
    $xml = [xml](Get-Content $path)

    $allPropertyGroup = $xml.Project.PropertyGroup
    foreach($node in $allPropertyGroup)
    {
        if($node.TargetFrameworkVersion -ne $null)
        {
            #If the Deployment Setting already exists, then we just need to update them
            $node.TargetFrameworkVersion= $TargetFrameworkVersion;
        }
    }
    $xml.Save($path);
}

dir -Recurse *.csproj | ForEach-Object { 
    $path = $_.FullName;
    $xml = [xml](Get-Content $path)

    $allPropertyGroup = $xml.Project.PropertyGroup
    foreach($node in $allPropertyGroup)
    {
        if($node.TargetFrameworkVersion -ne $null)
        {
            #If the Deployment Setting already exists, then we just need to update them
            $node.TargetFrameworkVersion= $TargetFrameworkVersion;
        }
    }
    $xml.Save($path);
}