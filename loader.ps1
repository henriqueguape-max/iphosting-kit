# Este é o loader.ps1 que ficará hospedado no GitHub
$scriptUrl = "https://raw.githubusercontent.com/henriqueguape-max/iphosting-kit/main/ipHosting-Manutencao.ps1"
$rand = [Guid]::NewGuid().Guid
$isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
$tempPath = if ($isAdmin) { "$env:SystemRoot\Temp\IPH_$rand.ps1" } else { "$env:USERPROFILE\AppData\Local\Temp\IPH_$rand.ps1" }

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Write-Host "Baixando e preparando ambiente da ipHosting..." -ForegroundColor Cyan
    Invoke-RestMethod -Uri $scriptUrl -OutFile $tempPath

    if ($isAdmin) {
        Write-Host "Iniciando execucao em modo Administrador..." -ForegroundColor Green
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $tempPath
    } else {
        Write-Host "Solicitando elevacao de privilegio (UAC)..." -ForegroundColor Yellow
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempPath`"" -Verb RunAs -Wait
    }
} finally {
    if (Test-Path $tempPath) { Remove-Item $tempPath -Force }
}
