# ===================== EDIT THESE =====================
$XmlPath    = "C:\Users\ADM_SPEREIRA\Desktop\PS\Applications_Assemblies.xml"
$ExportRoot = "C:\temp\Export"
$Overwrite  = $true
# ======================================================

$ErrorActionPreference = 'Stop'

# Ensure export root
if (-not (Test-Path -LiteralPath $ExportRoot)) {
    New-Item -ItemType Directory -Path $ExportRoot | Out-Null
}

# Load XML
[xml]$xml = Get-Content -LiteralPath $XmlPath -Raw

# GAC roots to probe
$gacRoot    = Join-Path $env:WINDIR 'Microsoft.NET\assembly'
$gacBuckets = @('GAC_MSIL','GAC_32','GAC_64')

# Helper regexes (inline)
$verFolderPattern = '^(?<ver>\d+(?:\.\d+){1,3})__(?<pkt>[0-9a-fA-F]+)$'

$summary = @()

# Iterate Applications
$apps = $xml.SelectNodes('/Applications/Application')
if (-not $apps -or $apps.Count -eq 0) {
    throw "No <Application> nodes found in XML: $XmlPath"
}

foreach ($app in $apps) {
    $appName = [string]$app.GetAttribute('name')
    if ([string]::IsNullOrWhiteSpace($appName)) { continue }

    # Sanitize folder name (Windows forbids these chars)
    $safeApp = ($appName -replace '[\\/:*?"<>|]', '_').Trim()
    $appFolder = Join-Path $ExportRoot $safeApp

    if (-not (Test-Path -LiteralPath $appFolder)) {
        New-Item -ItemType Directory -Path $appFolder | Out-Null
    }

    Write-Host "`n== Application: $appName ==" -ForegroundColor Cyan

    # Assemblies for this application
    $asmNodes = $app.SelectNodes('./Assembly')
    if (-not $asmNodes -or $asmNodes.Count -eq 0) {
        Write-Warning "No <Assembly> items for application '$appName'."
        continue
    }

    foreach ($node in $asmNodes) {
        $asmName = [string]$node.InnerText
        if ([string]::IsNullOrWhiteSpace($asmName)) { continue }

        $dllPath = $null
        $hitsAll = @()

        foreach ($bucket in $gacBuckets) {
            $nameDir = Join-Path (Join-Path $gacRoot $bucket) $asmName
            if (-not (Test-Path -LiteralPath $nameDir)) { continue }

            # Gather any <asmName>.dll under version folders
            $hits = @(Get-ChildItem -LiteralPath $nameDir -Recurse -Filter ("{0}.dll" -f $asmName) -ErrorAction SilentlyContinue)
            if ($hits.Count -gt 0) {
                $hitsAll += $hits
            }
        }

        if ($hitsAll.Count -eq 0) {
            Write-Warning "GAC dll not found for '$asmName'."
            $summary += [pscustomobject]@{ Application=$appName; Assembly=$asmName; Source=''; Dest=''; Result='NotFound' }
            continue
        }

        # Prefer highest version by parsing parent folder name "<version>__<pkt>"
        $best = $hitsAll |
            Sort-Object -Descending -Property @{
                Expression = {
                    # Try to extract version from parent dir name
                    $parent = Split-Path $_.DirectoryName -Leaf
                    $ver = $null
                    if ($parent -match $verFolderPattern) {
                        try { [version]$matches['ver'] } catch { [version]'0.0.0.0' }
                    } else { [version]'0.0.0.0' }
                }
            } |
            Select-Object -First 1

        $dllPath = $best.FullName

        try {
            $dest = Join-Path $appFolder ("{0}.dll" -f $asmName)
            Copy-Item -LiteralPath $dllPath -Destination $dest -Force:$Overwrite
            Write-Host ("Copied: {0}  ->  {1}" -f $asmName, $dest) -ForegroundColor Green
            $summary += [pscustomobject]@{ Application=$appName; Assembly=$asmName; Source=$dllPath; Dest=$dest; Result='Copied' }
        }
        catch {
            Write-Warning ("Failed to copy {0}: {1}" -f $asmName, $_.Exception.Message)
            $summary += [pscustomobject]@{ Application=$appName; Assembly=$asmName; Source=$dllPath; Dest=''; Result="Error: $($_.Exception.Message)" }
        }
    }
}

"`n===== SUMMARY ====="
$summary | Format-Table -AutoSize