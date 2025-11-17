# === EDIT THESE VALUES ===
$AppName   = "My-App"                    # BizTalk Application name
$SourceDir = "D:\BiztalkApps\My-App"     # DLLs Folder Name
$BTSTask   = "C:\Program Files (x86)\Microsoft BizTalk Server\BTSTask.exe"
# ==================
 
$ErrorActionPreference = 'Stop'
 
if (-not (Test-Path -LiteralPath $SourceDir)) { throw "Folder not found: $SourceDir" }
if (-not (Test-Path -LiteralPath $BTSTask -PathType Leaf)) {
  $found = Get-ChildItem 'C:\Program Files*' -Filter BTSTask.exe -Recurse -ErrorAction SilentlyContinue |
           Select-Object -First 1 -ExpandProperty FullName
  if ($found) { $BTSTask = $found } else { throw "BTSTask.exe not found." }
}
 
Write-Host "BTSTask: $BTSTask" -ForegroundColor Cyan
Write-Host "Application: $AppName" -ForegroundColor Cyan
Write-Host "SourceDir: $SourceDir" -ForegroundColor Cyan
 
# Load DLLs (add -Recurse if needed)
$dlls = Get-ChildItem -LiteralPath $SourceDir -Filter *.dll -File -ErrorAction SilentlyContinue
if (-not $dlls) { Write-Warning "No DLLs found in $SourceDir"; return }
 
$termsInOrder = @('Helper','Common','Staging','Messaging','Processing')
 
# Build the install queue by filename (case-insensitive)
$installQueue = @()
$remaining = $dlls
foreach ($t in $termsInOrder) {
  $pattern = [regex]::Escape($t)
  $matched = $remaining | Where-Object { $_.Name -match $pattern } | Sort-Object Name
  if ($matched) {
    $installQueue += $matched
    $remaining = $remaining | Where-Object { $matched.FullName -notcontains $_.FullName }
  } else {
    Write-Host "No DLL filenames containing '$t'." -ForegroundColor DarkGray
  }
}
 
if (-not $installQueue) { Write-Warning "No DLLs match: $($termsInOrder -join ', ')"; return }
 
function Get-AssemblyStrongNameInfo {
  param([Parameter(Mandatory=$true)][string]$Path)
  try {
    $an = [System.Reflection.AssemblyName]::GetAssemblyName($Path)
    $pkt = $an.GetPublicKeyToken()
    [pscustomobject]@{
      IsStrongNamed = ($pkt -and $pkt.Length -gt 0)
      Name          = $an.Name
      Version       = $an.Version
    }
  } catch {
    [pscustomobject]@{
      IsStrongNamed = $false
      Name          = (Split-Path $Path -Leaf)
      Version       = $null
    }
  }
}
 
function Invoke-BTSTask {
  param(
    [Parameter(Mandatory=$true)][string]$BTSTaskPath,
    [Parameter(Mandatory=$true)][string[]]$Arguments
  )
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = $BTSTaskPath
  $psi.Arguments = ($Arguments -join ' ')
  $psi.UseShellExecute = $false
  $psi.RedirectStandardOutput = $true
  $psi.RedirectStandardError  = $true
 
  $p = New-Object System.Diagnostics.Process
  $p.StartInfo = $psi | Out-Null
  [void]$p.Start()
  $stdout = $p.StandardOutput.ReadToEnd()
  $stderr = $p.StandardError.ReadToEnd()
  $p.WaitForExit()
 
  [pscustomobject]@{
    ExitCode = $p.ExitCode
    StdOut   = $stdout
    StdErr   = $stderr
  }
}
 
function Install-DllAuto {
  param(
    [Parameter(Mandatory=$true)][string]$DllPath,
    [Parameter(Mandatory=$true)][string]$ApplicationName,
    [Parameter(Mandatory=$true)][string]$BTSTaskPath
  )
 
  $info = Get-AssemblyStrongNameInfo -Path $DllPath
  if (-not $info.IsStrongNamed) {
    Write-Warning "DLL is not strong-named (GAC will fail): $DllPath"
  }
 
  # 1) Try as BizTalkAssembly (schemas/maps/orchestrations)
  $args1 = @(
    'AddResource',
    "/ApplicationName:$ApplicationName",
    '/Type:System.BizTalk:BizTalkAssembly',
    '/Overwrite',
    "/Source:`"$DllPath`"",
    '/Options:GacOnAdd,GacOnInstall,GacOnImport'
  )
  $r1 = Invoke-BTSTask -BTSTaskPath $BTSTaskPath -Arguments $args1
 
  if ($r1.ExitCode -eq 0) {
    return [pscustomobject]@{ ExitCode=0; Type='BizTalkAssembly'; Output=$r1.StdOut; Error=$r1.StdErr }
  }
 
  # 2) Retry as plain .NET Assembly (helper libraries)
  $args2 = @(
    'AddResource',
    "/ApplicationName:$ApplicationName",
    '/Type:System.BizTalk:Assembly',
    '/Overwrite',
    "/Source:`"$DllPath`"",
    '/Options:GacOnAdd,GacOnInstall,GacOnImport'
  )
  $r2 = Invoke-BTSTask -BTSTaskPath $BTSTaskPath -Arguments $args2
 
  if ($r2.ExitCode -eq 0) {
    return [pscustomobject]@{ ExitCode=0; Type='Assembly'; Output=$r2.StdOut; Error=$r2.StdErr }
  }
 
  # 3) If still failing and not strong-named, last resort: add as File (no GAC)
  if (-not $info.IsStrongNamed) {
    Write-Warning "Falling back to File resource (no GAC): $DllPath"
    $args3 = @(
      'AddResource',
      "/ApplicationName:$ApplicationName",
      '/Type:System.BizTalk:File',
      '/Overwrite',
      "/Source:`"$DllPath`""
    )
    $r3 = Invoke-BTSTask -BTSTaskPath $BTSTaskPath -Arguments $args3
    if ($r3.ExitCode -eq 0) {
      return [pscustomobject]@{ ExitCode=0; Type='File'; Output=$r3.StdOut; Error=$r3.StdErr }
    } else {
      return [pscustomobject]@{ ExitCode=$r3.ExitCode; Type='File'; Output=$r3.StdOut; Error=$r3.StdErr }
    }
  }
 
  # Failed both typed installs
  return [pscustomobject]@{ ExitCode=$r2.ExitCode; Type='Assembly'; Output=$r2.StdOut; Error=$r2.StdErr }
}
 
$results = @()
foreach ($dll in $installQueue) {
  Write-Host ("Installing -> {0}" -f $dll.Name) -ForegroundColor Yellow
  $res = Install-DllAuto -DllPath $dll.FullName -ApplicationName $AppName -BTSTaskPath $BTSTask
  if ($res.ExitCode -eq 0) {
    Write-Host ("OK  [{0}] -> {1}" -f $res.Type, $dll.Name) -ForegroundColor Green
    $results += [pscustomobject]@{
      File = $dll.Name; Path = $dll.FullName; Type = $res.Type; Result='Added'
    }
  } else {
    Write-Warning ("FAIL [{0}] -> {1} (ExitCode {2})" -f $res.Type, $dll.Name, $res.ExitCode)
    if ($res.Error) { Write-Host $res.Error -ForegroundColor DarkRed }
    $results += [pscustomobject]@{
      File = $dll.Name; Path = $dll.FullName; Type = $res.Type; Result="ERROR $($res.ExitCode)"
    }
  }
}
 
"`n===== SUMMARY ====="
$results | Sort-Object Type, File | Format-Table -AutoSize