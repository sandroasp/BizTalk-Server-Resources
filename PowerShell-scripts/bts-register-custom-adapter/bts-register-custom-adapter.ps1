########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: This script register a custom adapter to run under 32-bit and/or 64-bit Host Instances. #
#                                                                                                      #
########################################################################################################

function Register-BizTalk-Adapter(
	[string]$adapterRegFolder,
	[string]$regFile)
{
    [string]$regFilePath = $adapterRegFolder + "\" + $regFile

    #If the file does not exist, create it.
    if (-not(Test-Path -Path $regFilePath -PathType Leaf)) {
        Write-Host "The file [$regFilePath] does not exist." -Fore Red
        return $false
    }
    
    #Test for 64 bit
    $questionResult = $windowsShell.popup("Do you want to install this adapter to run under 64-bit Host Instances?", 0,"64-bit Host Instances installation",4)

    If ($questionResult -eq 6) {
        # c:\windows\regedit.exe /S $regFilePath
        reg import $regFilePath /reg:64
        Write-Host "Adapter installed as 64-bit." -Fore DarkGreen
    }

    $questionResult = $windowsShell.popup("Do you want to install this adapter to run under 32-bit Host Instances?", 0,"32-bit Host Instances installation",4)

    If ($questionResult -eq 6) {
        # c:\Windows\syswow64\regedit /S $regFilePath
        reg import $regFilePath /reg:32
        Write-Host "Adapter installed as 32-bit." -Fore DarkGreen
    }
}

#############################################################
# Main script logic
#############################################################
Write-Host "Starting registring a new adapter into BizTalk Server environment..." -Fore DarkGreen

# STEP 1 
# Ask for the path on the hard drive where the adapter and the .ref file for that adapter are installed 
[string]$pathReg = Read-Host -Prompt "Please enter path where the adapter and .reg file is intalled (C:\Program Files (x86)\adapter)" 

# STEP 2 
# Ask for the name of the adapter .ref file  
[string]$regFile = Read-Host -Prompt "Please enter name of the adapter .reg file (StaticAdapterManagement.reg)"

# STEP 3
# trigger function Register-BizTalk-Adapter
Register-BizTalk-Adapter $pathReg $regFile

# STEP 4
# Finish
Write-Host "Adapter registration completed" -Fore DarkGreen