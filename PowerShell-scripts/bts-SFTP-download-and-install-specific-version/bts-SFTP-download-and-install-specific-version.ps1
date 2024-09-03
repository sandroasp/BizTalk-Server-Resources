########################################################################################################
#                                                                                                      #
# Author: Sandro Pereira                                                                               #
#                                                                                                      #
# Description: PowerShell script to download a specific version of WinSCF to be uses in                #
#              BizTalk Server 2016 or 2020.                                                            #
#                                                                                                      #
# Credits: Thomas E. Canter, Michael Stephenson, Nicolas Blatter and Niclas Öberg for the              #
#          participation in the original script.                                                       #
########################################################################################################

[cmdletbinding(SupportsShouldProcess)]
#Parameters
Param(
    [Parameter(
        Mandatory = $false
    )]
    [ValidateNotNullOrEmpty()]
    [string]$nugetDownloadFolder = (Get-Item Env:TEMP).Value + "\nuget",
    [Parameter(
        Mandatory = $false
    )]
    [switch]$ForceInstall
)

#####################################################################
function Write-Error {
    Param([string] $ErrorMessage)
    Write-Success -ForegroundColor Red "$ErrorMessage";
}
#####################################################################
# Function to write success
#####################################################################
function Write-Success {
    Param([string] $SuccessMessage)
    Write-Host -ForegroundColor Green "$SuccessMessage";
}

#Download folder
[string]$nugetDownloadFolder = (Get-Item Env:TEMP).Value + "\nuget"

if(Test-Path $nugetDownloadFolder)
{
    Write-Success "Storing folder exists";
    Write-Success "`t`'$nugetDownloadFolder`'"
}
else
{
    New-Item $nugetDownloadFolder -ItemType Directory
    Write-Success "Storing folder created";
    Write-Success "`t`'$nugetDownloadFolder`'"
}

#Support variables
$winSCPVersion = "6.1.2"
$winSCPexeFile = "WinSCP.exe";
$winSCPdllFile = "WinSCPnet.dll";
$targetNugetExe = "$nugetDownloadFolder\nuget.exe"
$winSCPdll = "WinSCP.$winSCPVersion\lib\"
$WinSCPDllDownload = "$nugetDownloadFolder\$winSCPdll"


$getWinSCP = "'$targetNugetExe' Install WinSCP -Version $winSCPVersion -NonInteractive -OutputDirectory '$nugetDownloadFolder'"
$sourceNugetExe = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe";
    
Write-Success "Downloading Nuget from:"
Write-Success "`t`'$sourceNugetExe`'"
Write-Success "Storing it in the folder";
Write-Success "`t`'$nugetDownloadFolder`'"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Default $Continue flag to true, set to false to end the process
$Continue = $true;

$checkExeExists = Test-Path $targetNugetExe
if(-not $checkExeExists)
{
    if ($PSCmdlet.ShouldProcess("$sourceNugetExe -OutFile $targetNugetExe", "Run Invoke-WebRequest ")) {
        Invoke-WebRequest $sourceNugetExe -OutFile $targetNugetExe
        $targetNugetExeExists = Test-Path $targetNugetExe
        if (-not $targetNugetExeExists) {
            $Continue = $false
            Write-Error "`n$bangString";
            Write-Error "The download of the Nuget EXE from";
            Write-Error $sourceNugetExe;
            Write-Error "did not succeed";
            Write-Error "$bangString";
        }
        else{
            Write-Success "nuget.exe download successfully."
        }
    }
}

if ($Continue) {
    if ($PSCmdlet.ShouldProcess("$getWinSCP", "Run Command")) {
        Invoke-Expression "& $getWinSCP";
        $WinSCPEXEExists = Test-Path $WinSCPEXEDownload
        $WinSCPDLLExists = Test-Path $WinSCPDllDownload
        if (-not $WinSCPDLLExists) {
            $Continue = $false
            Write-Error "`n$bangString";
            Write-Error "WinSCP $winSCPVersion was not properly downloaded.";
            Write-Error "Check the folder and error messages above:";
            Write-Error "$nugetDownloadFolder";
            Write-Error "And determine what files did download or did not download.";
            Write-Error "$bangString";
        }
        else{
            Write-Success "WinSCP $winSCPVersion was properly downloaded."
        }
    }
}

if ($Continue) {
    $bizTalkInstallFolder = (Get-Item Env:BTSINSTALLPATH).Value;
    $bizTalkInstallFolderExists = Test-Path $bizTalkInstallFolder
    if (-not $bizTalkInstallFolder) {
        Write-Error ('The Env:BTSINSTALLPATH doesn`t exist, checking to see if the path is in the registry HKLM:\SOFTWARE\Microsoft\BizTalk Server\3.0@InstallPath');
        $bizTalkInstallFolder = (get-itemPropertyValue 'HKLM:\SOFTWARE\Microsoft\BizTalk Server\3.0' -Name 'InstallPath')
          
        if (-not $bizTalkInstallFolder) {
            $Continue = false;
            Write-Error "Microsoft BizTalk Server was not located by checking the environment variable BTSINSTALLPATH and the Registry key for BizTalk, exiting the process";
            Write-Error "Please confirm that Microsoft BizTalk Server is installed on this system";
        }
    }

    $btsTargetWinSCPExe = $bizTalkInstallFolder + $winSCPexeFile;
    $btsTargetWinSCPDll = $bizTalkInstallFolder + $winSCPdllFile;

    $winSCPexe = "WinSCP.$winSCPVersion\tools\$winSCPexeFile"
    $winSCPdll = "WinSCP.$winSCPVersion\lib\netstandard2.0\$winSCPdllFile"

    $WinSCPEXEDownload = "$nugetDownloadFolder\$winSCPexe"
    $WinSCPDllDownload = "$nugetDownloadFolder\$winSCPdll"

    Copy-Item $WinSCPEXEDownload $bizTalkInstallFolder
    Copy-Item $WinSCPDllDownload $bizTalkInstallFolder

    $WinSCPTargetEXEExists = Test-Path $btsTargetWinSCPExe
    $WinSCPDLLTargetExists = Test-Path $btsTargetWinSCPDll

    if ($WinSCPTargetEXEExists -and $WinSCPDLLTargetExists) {
        Write-Verbose "WinSCP was properly copied to the target folder `'$bizTalkInstallFolder`'.";
    }
    else {
        Write-Error "WinSCP was not properly copied to the target folder `'$bizTalkInstallFolder`'.";
    }
}