# ================== EDIT THESE ==================
$SqlServer         = "SQL-SERVER"   # e.g. "SQL01\BTSQL"
$DbName            = "BizTalkMgmtDb"
$AppName           = "My-Application"             # application filter used in the SQL (LIKE)
$DestinationFolder = "C:\BizTalkApplications\DLLs\My-Application"
$Overwrite         = $true
# ================================================

# Ensure destination
if (-not (Test-Path -LiteralPath $DestinationFolder)) {
    New-Item -ItemType Directory -Path $DestinationFolder | Out-Null
}

# Run the SQL (returns XML) using .NET client
$cn = New-Object System.Data.SqlClient.SqlConnection
$cn.ConnectionString = "Server=$SqlServer;Database=$DbName;Trusted_Connection=True;MultipleActiveResultSets=False;"
$cn.Open()

# Your SQL (parametrized). It returns XML with <Assemblies><Assemby><nvcName>...</nvcName>...</Assemblies>
$q = @"
SELECT [nvcName]
FROM [dbo].[bts_assembly]
WHERE nApplicationID LIKE (
    SELECT [nID]
    FROM [dbo].[bts_application]
    WHERE nvcName LIKE @app
)
FOR XML PATH('Assemby'), ROOT('Assemblies');
"@

$cmd = $cn.CreateCommand()
$cmd.CommandText = $q
$null = $cmd.Parameters.Add("@app",[System.Data.SqlDbType]::NVarChar,256)
$cmd.Parameters["@app"].Value = $AppName

# Use ExecuteXmlReader to get the XML cleanly
$xmlReader = $cmd.ExecuteXmlReader()

# Load into [xml]
$xml = New-Object System.Xml.XmlDocument
$xml.Load($xmlReader)

$xmlReader.Close()
$cn.Close()

# Extract assembly simple names (from <Assemby><nvcName>...)
$asmNames = @()
$nodes = $xml.SelectNodes("//Assemblies/Assemby/nvcName")
foreach ($n in $nodes) {
    $val = [string]$n.InnerText
    if ([string]::IsNullOrWhiteSpace($val)) { continue }
    # In BizTalk, nvcName is the simple assembly name (no version/PKT). Keep as-is.
    $asmNames += $val.Trim()
}

if (-not $asmNames -or $asmNames.Count -eq 0) {
    Write-Warning "No assemblies found in SQL for application LIKE '$AppName'."
    exit 1
}

# Locate each DLL in the GAC and copy it
$gacRoot    = Join-Path $env:WINDIR 'Microsoft.NET\assembly'
$gacBuckets = @('GAC_MSIL','GAC_32','GAC_64')
$report = @()
$errors = @()

foreach ($name in $asmNames | Select-Object -Unique) {
    $dllPath = $null

    foreach ($bucket in $gacBuckets) {
        $nameDir = Join-Path (Join-Path $gacRoot $bucket) $name
        if (-not (Test-Path -LiteralPath $nameDir)) { continue }

        # Search for <Name>.dll under the assembly folder; we don't know version/PKT from this query
        $hits = @(Get-ChildItem -LiteralPath $nameDir -Recurse -Filter ("{0}.dll" -f $name) -ErrorAction SilentlyContinue)
        if ($hits.Count -gt 0) {
            # If multiple versions exist, pick the newest folder by LastWriteTime
            $dllPath = ($hits | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
            break
        }
    }

    if (-not $dllPath) {
        $msg = "GAC path not found for $name."
        Write-Warning $msg
        $errors += $msg
        continue
    }

    try {
        $dest = Join-Path $DestinationFolder ("{0}.dll" -f $name)
        Copy-Item -LiteralPath $dllPath -Destination $dest -Force:$Overwrite
        $report += [pscustomobject]@{
            AssemblyName  = $name
            SourceGacPath = $dllPath
            CopiedTo      = $dest
            Result        = 'Copied'
        }
        Write-Host "Copied: $name  ->  $dest" -ForegroundColor Green
    }
    catch {
        $msg = "Failed to copy $name from '$dllPath' -> '$DestinationFolder'. Error: $($_.Exception.Message)"
        Write-Warning $msg
        $errors += $msg
        $report += [pscustomobject]@{
            AssemblyName  = $name
            SourceGacPath = $dllPath
            CopiedTo      = $null
            Result        = 'Error'
        }
    }
}

"`n===== SUMMARY ====="
$report | Format-Table -AutoSize

if ($errors.Count -gt 0) {
    "`nWarnings/Errors:"
    $errors | ForEach-Object { " - $_" }
}

"`nDone."