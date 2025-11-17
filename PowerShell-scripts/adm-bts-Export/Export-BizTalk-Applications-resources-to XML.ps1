$app     = 'my-app'
$spec    = 'C:\BizTalkApplications\app\MyArtifacts.xml'

# Find BTSTask.exe in a dynamic way
$btstask = Get-ChildItem `
  'C:\Program Files*' `
  -Filter 'BTSTask.exe' -Recurse -ErrorAction SilentlyContinue `
  | Select-Object -First 1 -ExpandProperty FullName

if (-not $btstask) { throw "BTSTask.exe not found. Is BizTalk Server installed in this machine?" }
$btstask


# Run and show output in console
& $btstask 'ListApp' "/ApplicationName:$app" "/ResourceSpec:$spec"
if ($LASTEXITCODE -ne 0) { throw "BTSTask failed with exit code $LASTEXITCODE" }