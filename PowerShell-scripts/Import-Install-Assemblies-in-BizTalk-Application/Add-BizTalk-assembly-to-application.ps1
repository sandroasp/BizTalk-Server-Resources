# === EDIT THESE VALUES ===
$AppName   = "My-App"                    # BizTalk Application name
$SourceDir = "D:\BiztalkApps\My-App"     # DLLs Folder Name
$BTSTask   = "C:\Program Files (x86)\Microsoft BizTalk Server\BTSTask.exe"
# ==================

$ErrorActionPreference = 'Stop'

# Basic verifications
if (-not (Test-Path -LiteralPath $SourceDir)) { throw "Folder not found: $SourceDir" }
if (-not (Test-Path -LiteralPath $BTSTask -PathType Leaf)) {
  # try to auto-detect BTSTask if the provider location fails
  $found = Get-ChildItem 'C:\Program Files*' -Filter BTSTask.exe -Recurse -ErrorAction SilentlyContinue |
           Select-Object -First 1 -ExpandProperty FullName
  if ($found) { $BTSTask = $found } else { throw "BTSTask.exe not found." }
}

$dlls = Get-ChildItem -LiteralPath $SourceDir -Filter *.dll -File
if (-not $dlls -or $dlls.Count -eq 0) { Write-Warning "Without DLLs in $SourceDir"; return }

Write-Host "Using BTSTask: $BTSTask" -ForegroundColor Cyan
Write-Host "Application: $AppName" -ForegroundColor Cyan

$results = @()

foreach ($dll in $dlls) {
  $args1 = @(
    'AddResource',
    "/ApplicationName:$AppName",
    '/Type:System.BizTalk:BizTalkAssembly',
    '/Overwrite',
    "/Source:`"$($dll.FullName)`"",
    '/Options:GacOnAdd,GacOnInstall,GacOnImport'
  )
  $r1 = Start-Process -FilePath $BTSTask -ArgumentList $args1 -NoNewWindow -PassThru -Wait
  
  if ($r1.ExitCode -eq 0) {
    $results += [pscustomobject]@{ File=$dll.Name; Path=$dll.FullName; Result='Added+GAC' }
    Write-Host ("OK  -> {0}" -f $dll.Name) -ForegroundColor Green
  } else {
	  # 2) Retry as plain .NET Assembly (helper libraries)
	  $args2 = @(
		'AddResource',
		"/ApplicationName:$ApplicationName",
		'/Type:System.BizTalk:Assembly',
		'/Overwrite',
		"/Source:`"$($dll.FullName)`"",
		'/Options:GacOnAdd,GacOnInstall,GacOnImport'
	  )
	  $r2 = Start-Process -FilePath $BTSTask -ArgumentList $args2 -NoNewWindow -PassThru -Wait
	  
	  if ($r2.ExitCode -eq 0) {
		$results += [pscustomobject]@{ File=$dll.Name; Path=$dll.FullName; Result='Added+GAC' }
		Write-Host ("OK  -> {0}" -f $dll.Name) -ForegroundColor Green
	  } else {
		$results += [pscustomobject]@{ File=$dll.Name; Path=$dll.FullName; Result="ERROR ExitCode $($p.ExitCode)" }
		Write-Warning ("FAIL -> {0} (ExitCode {1})" -f $dll.Name,$r2.ExitCode)
	  }
  }
}

"`n===== SUMMARY ====="
$results | Format-Table -AutoSize