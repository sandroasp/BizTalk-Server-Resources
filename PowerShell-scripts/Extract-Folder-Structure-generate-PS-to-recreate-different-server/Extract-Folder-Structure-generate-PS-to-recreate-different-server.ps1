##############################################################################################
# Script to extract a list all subfolders under a target path and generate a PowerShell file
# containing all the PowerShell commands to recreate the folder structure in a diffent Server.
#
# Author: Sandro Pereira
##############################################################################################

#############################################################
# Global Variables
#############################################################
[string] $path = "d:\BiztalkFilePorts"
[string] $scriptPath = "c:\temp\CreateFoderStructure.ps1"

New-Item $scriptPath

$folderList = Get-ChildItem -Path $path -Recurse -Directory -Force -ErrorAction SilentlyContinue | Select-Object FullName

foreach ($folder in $folderList)
{
    $powerShellCommand = 'New-Item -ItemType Directory -Path "'+$folder.FullName+'"' 
    Add-Content -Path $scriptPath -Value $powerShellCommand 
}