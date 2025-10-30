
$src = 'APIKeyPromoter'
(Get-WinEvent -ListProvider $src).LogLinks |
  Select-Object -ExpandProperty LogName -Unique