$Now = Get-Date
$Hours = "12"
$LastWrite = $Now.AddHours(-$Days)

$Directories = Get-ChildItem "D:\BizTalkApplications\Archive" -Recurse | ?{ $_.PSIsContainer } | Select-Object FullName

foreach ($directory in $Directories) 
{
    $zipFile = "E:\BackupFileWarehouse\" + $directory.FullName.Substring($directory.FullName.LastIndexOf(":")+2).Replace("\","_") + "_" +  (get-date -f yyyyMMdd_hhss).ToString() + ".zip"
    
    $filelist = get-childitem $directory.FullName |  
                                where-object {$_.LastWriteTime -le (get-date).AddHours(-$Hours)} | 
                                where-object {-not $_.PSIsContainer}
    
    if($filelist.Count -gt 0)
    { 
        $filelist | format-table -hideTableHeaders FullName | out-file -encoding utf8 -filepath lastmonthsfiles.txt
                    & 'C:\Program Files (x86)\7-Zip\7z.exe' a $zipFile `@lastmonthsfiles.txt

        $filelist | %{Remove-Item $_.FullName }
        rm lastmonthsfiles.txt
    }
}




