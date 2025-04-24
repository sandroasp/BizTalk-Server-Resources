$startPath = "C:\Path\To\Your\Solution"  # <<< CHANGE THIS to Your base folder

$allDirs = Get-ChildItem -Path $startPath -Recurse -Directory

foreach ($dir in $allDirs) {
    $inventoryFile = Join-Path $dir.FullName "BizTalkServerInventory.json"
    if (Test-Path $inventoryFile) {
        $btaprojFiles = Get-ChildItem -Path $dir.FullName -Filter *.btaproj -File
        foreach ($file in $btaprojFiles) {
            Write-Host "Processing: $($file.FullName)"
            
            [xml]$xml = Get-Content $file.FullName

            # Define namespace manager
            $nsm = New-Object System.Xml.XmlNamespaceManager($xml.NameTable)
            $nsm.AddNamespace("ns", "http://schemas.microsoft.com/developer/msbuild/2003")

            # 1. Update CustomProjectExtensionsPath value
            $extensions = $xml.SelectNodes("//ns:CustomProjectExtensionsPath", $nsm)
            foreach ($ext in $extensions) {
                if ($ext.InnerText -eq '$(BTSINSTALLPATH)\Developer Tools\BuildSystem\') {
                    $ext.InnerText = '$(MSBuildExtensionsPath)\Microsoft\BizTalk\BuildSystem\'
                }
            }

            # 2. Update TargetFrameworkMoniker from v4.7 to v4.8
            $monikers = $xml.SelectNodes("//ns:TargetFrameworkMoniker", $nsm)
            foreach ($moniker in $monikers) {
                if ($moniker.InnerText -eq '.NETFramework,Version=v4.7') {
                    $moniker.InnerText = '.NETFramework,Version=v4.8'
                }
            }

            # 3. Update Import project if it uses CustomProjectCs.targets
            $imports = $xml.SelectNodes("//ns:Import", $nsm)
            foreach ($import in $imports) {
                if ($import.Project -eq '$(CustomProjectExtensionsPath)CustomProjectCs.targets') {
                    $import.Project = '$(CustomProjectExtensionsPath)CustomProject.targets'
                }
            }

            # Save changes
            $xml.Save($file.FullName)
            Write-Host "✔ Updated: $($file.Name)"
        }
    }
}
