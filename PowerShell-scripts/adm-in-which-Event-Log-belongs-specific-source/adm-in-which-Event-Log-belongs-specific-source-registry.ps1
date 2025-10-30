$src = 'BizTalk Server'
Get-ChildItem 'HKLM:\SYSTEM\CurrentControlSet\Services\EventLog' -Recurse -ErrorAction SilentlyContinue |
Where-Object {
  $_.PSChildName -eq $src -or
  ((Get-ItemProperty $_.PsPath -ErrorAction SilentlyContinue).Sources -contains $src)
} |
Select-Object @{n='LogName';e={ Split-Path $_.PSParentPath -Leaf }} -Unique