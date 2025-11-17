# --- EDIT THESE ---
$SourceFolder = "D:\BiztalkApps\My-App"
$Recurse      = $false   # $true to include subfolders
# ------------------

$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath $SourceFolder)) {
    throw "Folder not found: $SourceFolder"
}

# Collect DLLs
$files = Get-ChildItem -LiteralPath $SourceFolder -Filter *.dll -File -Recurse:$Recurse
if (-not $files -or $files.Count -eq 0) {
    Write-Warning "No DLLs found in: $SourceFolder"
    return
}

$results = @()

# Detect edition (Desktop == Windows PowerShell/.NET Framework)
$onDesktop = ($PSVersionTable.PSEdition -eq 'Desktop' -or $PSVersionTable.PSVersion.Major -le 5)

# Try .NET Framework Publish API first when on Desktop
$publisher = $null
if ($onDesktop) {
    try {
        [void][Reflection.Assembly]::Load("System.EnterpriseServices")
        $publisher = New-Object System.EnterpriseServices.Internal.Publish
    } catch {
        Write-Warning "Could not create System.EnterpriseServices.Internal.Publish in this session. Will try gacutil.exe."
    }
}

if ($publisher) {
    foreach ($f in $files) {
        try {
            $publisher.GacInstall($f.FullName)
            $results += [pscustomobject]@{ File=$f.FullName; Method="Publish.GacInstall"; Result="GACed" }
            Write-Host "GACed: $($f.Name)" -ForegroundColor Green
        } catch {
            $results += [pscustomobject]@{ File=$f.FullName; Method="Publish.GacInstall"; Result="ERROR: $($_.Exception.Message)" }
            Write-Warning "Failed: $($f.Name) -> $($_.Exception.Message)"
        }
    }
    "`n===== SUMMARY ====="; $results | Format-Table -AutoSize
    return
}

# Fallback: locate gacutil.exe
$gacutil = $null
$probeRoots = @(
  'C:\Program Files (x86)\Microsoft SDKs\Windows',
  'C:\Program Files (x86)\Microsoft Visual Studio',
  'C:\Program Files\Microsoft SDKs\Windows'
)

foreach ($root in $probeRoots) {
    if (Test-Path $root) {
        $found = Get-ChildItem -Path $root -Filter gacutil.exe -Recurse -ErrorAction SilentlyContinue |
                 Sort-Object FullName -Unique |
                 Select-Object -First 1 -ExpandProperty FullName
        if ($found) { $gacutil = $found; break }
    }
}

if (-not $gacutil) {
    throw @"
No valid GAC installer found:
 - System.EnterpriseServices.Internal.Publish unavailable (likely PowerShell 7+ or missing .NET Framework)
 - gacutil.exe not found in common SDK/VS locations

Fixes:
 - Run in **Windows PowerShell 5.1** (x64) as Administrator; or
 - Install Windows SDK / VS Build Tools to get **gacutil.exe**.
"@
}

Write-Host "Using gacutil: $gacutil" -ForegroundColor Cyan

foreach ($f in $files) {
    try {
        # Use Start-Process; do NOT pipe a null path (pre-validated above)
        $p = Start-Process -FilePath $gacutil -ArgumentList @('/if', $f.FullName) -NoNewWindow -Wait -PassThru
        if ($p.ExitCode -eq 0) {
            $results += [pscustomobject]@{ File=$f.FullName; Method="gacutil /if"; Result="GACed" }
            Write-Host "GACed: $($f.Name)" -ForegroundColor Green
        } else {
            $results += [pscustomobject]@{ File=$f.FullName; Method="gacutil /if"; Result="ERROR: ExitCode $($p.ExitCode)" }
            Write-Warning "Failed: $($f.Name) -> ExitCode $($p.ExitCode)"
        }
    } catch {
        $results += [pscustomobject]@{ File=$f.FullName; Method="gacutil /if"; Result="ERROR: $($_.Exception.Message)" }
        Write-Warning "Failed: $($f.Name) -> $($_.Exception.Message)"
    }
}

"`n===== SUMMARY ====="
$results | Format-Table -AutoSize