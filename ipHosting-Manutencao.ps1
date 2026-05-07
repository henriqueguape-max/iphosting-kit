
# ==============================================================================
# CONSOLE
# ==============================================================================
$OutputEncoding            = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding  = [System.Text.Encoding]::UTF8
try {
    $host.UI.RawUI.BufferSize = New-Object System.Management.Automation.Host.Size(84, 3000)
    $host.UI.RawUI.WindowSize = New-Object System.Management.Automation.Host.Size(84, 42)
} catch { }

# ==============================================================================
# CHARS UNICODE (gerados em runtime -- sem BOM no arquivo)
# ==============================================================================
$bk = [char]0x2588  # FULL BLOCK
$cv = [char]0x2551  # BOX V double
$ch = [char]0x2550  # BOX H double
$tl = [char]0x2554  # corner top-left
$tr = [char]0x2557  # corner top-right
$bl = [char]0x255A  # corner bottom-left
$br = [char]0x255D  # corner bottom-right
$ml = [char]0x2560  # mid left T
$mr = [char]0x2563  # mid right T
$H71 = "$ch" * 71

# ==============================================================================
# LOG DE EXECUCAO
# ==============================================================================
$desktop = [Environment]::GetFolderPath("Desktop")
$logDir  = "$desktop\ipHosting-Logs"
$logFile = "$logDir\$(Get-Date -Format 'yyyy-MM-dd').log"
try { if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null } } catch { }

function Write-Log {
    param([string]$Nivel, [string]$Msg)
    try { Add-Content -Path $logFile -Value "$(Get-Date -Format 'HH:mm:ss') [$Nivel] $Msg" -Encoding UTF8 -ErrorAction SilentlyContinue } catch { }
}

# ==============================================================================
# HELPERS DE OUTPUT
# ==============================================================================
function Write-Success { param([string]$M) Write-Host "  [OK] $M" -ForegroundColor Green;   Write-Log "OK"    $M }
function Write-Erro    { param([string]$M) Write-Host "  [ERRO] $M" -ForegroundColor Red;   Write-Log "ERRO"  $M }
function Write-Aviso   { param([string]$M) Write-Host "  [AVISO] $M" -ForegroundColor Yellow; Write-Log "AVISO" $M }
function Write-Info    { param([string]$M) Write-Host "  [INFO] $M" -ForegroundColor Cyan;  Write-Log "INFO"  $M }

function Pause-Script {
    param([string]$Msg = "  Pressione ENTER para continuar...")
    Write-Host "`n$Msg" -ForegroundColor DarkGray
    Read-Host | Out-Null
}

function Show-Resumo {
    param([string]$Modulo, [int]$Seg, [string]$Extra = "")
    $msg = "  ==> $Modulo concluido em ${Seg}s"
    if ($Extra) { $msg += " | $Extra" }
    Write-Host "`n$msg" -ForegroundColor Green
    Write-Log "RESUMO" ($msg.Trim())
}

function Show-Separador {
    param([string]$Titulo = "")
    $HW = "$ch" * 73
    if ($Titulo) {
        Write-Host ""
        Write-Host "  $tl$HW$tr" -ForegroundColor DarkCyan
        Write-Host "  $cv  >> $Titulo" -ForegroundColor White
        Write-Host "  $bl$HW$br" -ForegroundColor DarkCyan
        Write-Host ""
    }
}

# ==============================================================================
# ==============================================================================
# ADMIN
# ==============================================================================
$IPHST_URL = "https://raw.githubusercontent.com/SEU_USUARIO/SEU_REPO/main/ipHosting-Manutencao.ps1"

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "`n  [ERRO] Requer privilegios de Administrador." -ForegroundColor Red
    Write-Host "  Reiniciando com elevacao..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    if ($PSCommandPath) {
        # Execucao local: relanca o proprio arquivo
        Start-Process PowerShell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    } else {
        # Execucao via irm | iex: re-baixa e roda elevado
        Start-Process PowerShell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"irm '$IPHST_URL' | iex`"" -Verb RunAs
    }
    exit
}

# ==============================================================================
# BANNER
# ==============================================================================
function Show-Banner {
    Clear-Host
    # Caracteres construidos em runtime via char codes (sem unicode no arquivo fonte)
    # Cada linha da arte tem exatamente $W chars internos entre os dois $cv
    $W = 73  # largura interna da caixa
    $HW = "$ch" * $W

    function ArtRow {
        param([string]$inner)
        # Garante que $inner tem exatamente $W chars, truncando ou completando com espaco
        if ($inner.Length -lt $W) { $inner = $inner + (' ' * ($W - $inner.Length)) }
        elseif ($inner.Length -gt $W) { $inner = $inner.Substring(0, $W) }
        Write-Host "  $cv$inner$cv" -ForegroundColor Cyan
    }

    function CenterRow {
        param([string]$text, [string]$Color = "White")
        $p = [math]::Floor(($W - $text.Length) / 2)
        $r = $W - $p - $text.Length
        Write-Host "  $cv$(' ' * $p)$text$(' ' * $r)$cv" -ForegroundColor $Color
    }

    Write-Host ""
    Write-Host "  $tl$HW$tr" -ForegroundColor Cyan
    ArtRow ""

    # Arte ipHosting construida com char codes — sem Unicode no arquivo
    ArtRow ("   "+$bk+$bk+$tr+$bk+$bk+$bk+$bk+$bk+$bk+$tr+" "+$bk+$bk+$tr+"  "+$bk+$bk+$tr+" "+$bk+$bk+$bk+$bk+$bk+$bk+$tr+" "+$bk+$bk+$bk+$bk+$bk+$bk+$bk+$tr+$bk+$bk+$bk+$bk+$bk+$bk+$bk+$bk+$tr+$bk+$bk+$tr+$bk+$bk+$bk+$tr+"   "+$bk+$bk+$tr+" "+$bk+$bk+$bk+$bk+$bk+$bk+$tr+" ")
    ArtRow ("   "+$bk+$bk+$cv+$bk+$bk+$tl+$ch+$ch+$bk+$bk+$tr+$bk+$bk+$cv+"  "+$bk+$bk+$cv+$bk+$bk+$tl+$ch+$ch+$ch+$bk+$bk+$tr+$bk+$bk+$tl+$ch+$ch+$ch+$ch+$br+$bl+$ch+$ch+$bk+$bk+$tl+$ch+$ch+$br+$bk+$bk+$cv+$bk+$bk+$bk+$bk+$tr+"  "+$bk+$bk+$cv+$bk+$bk+$tl+$ch+$ch+$ch+$ch+$br+" ")
    ArtRow ("   "+$bk+$bk+$cv+$bk+$bk+$bk+$bk+$bk+$bk+$tl+$br+$bk+$bk+$bk+$bk+$bk+$bk+$bk+$cv+$bk+$bk+$cv+"   "+$bk+$bk+$cv+$bk+$bk+$bk+$bk+$bk+$bk+$bk+$tr+"   "+$bk+$bk+$cv+"   "+$bk+$bk+$cv+$bk+$bk+$tl+$bk+$bk+$tr+" "+$bk+$bk+$cv+$bk+$bk+$cv+"  "+$bk+$bk+$bk+$tr)
    ArtRow ("   "+$bk+$bk+$cv+$bk+$bk+$tl+$ch+$ch+$ch+$br+" "+$bk+$bk+$tl+$ch+$ch+$bk+$bk+$cv+$bk+$bk+$cv+"   "+$bk+$bk+$cv+$bl+$ch+$ch+$ch+$ch+$bk+$bk+$cv+"   "+$bk+$bk+$cv+"   "+$bk+$bk+$cv+$bk+$bk+$cv+$bl+$bk+$bk+$tr+$bk+$bk+$cv+$bk+$bk+$cv+"   "+$bk+$bk+$cv)
    ArtRow ("   "+$bk+$bk+$cv+$bk+$bk+$cv+"     "+$bk+$bk+$cv+"  "+$bk+$bk+$cv+$bl+$bk+$bk+$bk+$bk+$bk+$bk+$tl+$br+$bk+$bk+$bk+$bk+$bk+$bk+$bk+$cv+"   "+$bk+$bk+$cv+"   "+$bk+$bk+$cv+$bk+$bk+$cv+" "+$bl+$bk+$bk+$bk+$bk+$cv+$bl+$bk+$bk+$bk+$bk+$bk+$bk+$tl+$br)
    ArtRow ("   "+$bl+$ch+$ch+$br+$bl+$ch+$ch+$br+"     "+$bl+$ch+$ch+$br+"  "+$bl+$ch+$ch+$br+" "+$bl+$ch+$ch+$ch+$ch+$ch+$br+" "+$bl+$ch+$ch+$ch+$ch+$ch+$ch+$br+"   "+$bl+$ch+$ch+$br+"   "+$bl+$ch+$ch+$br+$bl+$ch+$ch+$br+"  "+$bl+$ch+$ch+$ch+$br+" "+$bl+$ch+$ch+$ch+$ch+$ch+$br+" ")

    ArtRow ""
    CenterRow "KIT DE MANUTENCAO TECNICA  |  ipHosting v3.0"
    Write-Host "  $bl$HW$br" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  Maquina : $env:COMPUTERNAME     Usuario : $env:USERNAME     $(Get-Date -Format 'dd/MM/yyyy HH:mm')" -ForegroundColor DarkGray
    Write-Host "  Log     : $logFile" -ForegroundColor DarkGray
    Write-Host ""
}

# ==============================================================================
# MENU
# ==============================================================================
function Show-Menu {
    $W  = 73
    $HW = "$ch" * $W
    $hr = [string][char]0x2500  # linha fina horizontal

    function Row {
        param([string]$T, [string]$C = "Cyan")
        $pad = $W - 2 - $T.Length; if ($pad -lt 0) { $pad = 0 }
        Write-Host "  $cv  $T$(' ' * $pad)$cv" -ForegroundColor $C
    }
    function MenuSec {
        param([string]$Label, [string]$C = "DarkCyan")
        $dashes = "$hr" * ($W - 6 - $Label.Length)
        Row " $hr$hr $Label $dashes" $C
    }

    # --- Stats ao vivo ---
    $s1 = ""; $s2 = ""; $ramPct = 0; $diskPct = 0
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
        $cs = Get-CimInstance Win32_ComputerSystem  -ErrorAction SilentlyContinue
        $dk = Get-PSDrive C                         -ErrorAction SilentlyContinue
        if ($os -and $cs) {
            $rTot  = [math]::Round($cs.TotalPhysicalMemory / 1GB, 1)
            $rFree = [math]::Round($os.FreePhysicalMemory  / 1MB, 1)
            $ramPct = [math]::Round((($rTot - $rFree) / $rTot) * 100)
            $up    = (Get-Date) - $os.LastBootUpTime
            $s1 = "  RAM: ${rFree}/${rTot} GB (${ramPct}% usado)   Uptime: $($up.Days)d $($up.Hours)h $($up.Minutes)min"
        }
        if ($dk) {
            $dFree = [math]::Round($dk.Free  / 1GB, 0)
            $dTot  = [math]::Round(($dk.Used + $dk.Free) / 1GB, 0)
            $diskPct = [math]::Round(($dk.Used / ($dk.Used + $dk.Free)) * 100)
            $s2 = "  Disco C: ${dFree}/${dTot} GB  (${diskPct}% usado)"
        }
    } catch {}

    function StatRow {
        param([string]$T, [int]$Pct)
        $cor = if ($Pct -ge 90) { "Red" } elseif ($Pct -ge 75) { "Yellow" } else { "DarkGray" }
        $pad = $W - 2 - $T.Length; if ($pad -lt 0) { $pad = 0 }
        Write-Host "  $cv$T$(' ' * $pad)$cv" -ForegroundColor $cor
    }

    # --- Desenho ---
    Write-Host "  $tl$HW$tr" -ForegroundColor Cyan
    Row "MENU PRINCIPAL" "White"
    Write-Host "  $ml$HW$mr" -ForegroundColor Cyan
    if ($s1) { StatRow $s1 $ramPct }
    if ($s2) { StatRow $s2 $diskPct }
    if ($s1 -or $s2) { Write-Host "  $ml$HW$mr" -ForegroundColor Cyan }

    Row ""
    MenuSec "Reparo e Manutencao" "Yellow"
    Row "  [1]  Kit Reparo        - SFC + DISM (repara arquivos do Windows)" "Yellow"
    Row "  [2]  Limpeza           - Temp, Prefetch, Lixeira, Event Logs" "Yellow"
    Row "  [3]  Reparo Spooler    - Para/limpa/reinicia servico de impressao" "Yellow"
    Row "  [4]  Rede Safe Mode    - Flush DNS + Winsock Reset" "Yellow"
    Row ""
    MenuSec "Ferramentas" "Cyan"
    Row "  [5]  Diagnostico Rapido - IP, Disco, Ativacao, Defender, Uptime" "Cyan"
    Row "  [6]  Atualizar Apps     - Winget upgrade em todos os aplicativos" "Cyan"
    Row "  [7]  Backup de Drivers  - Exporta todos os drivers instalados" "Cyan"
    Row ""
    MenuSec "Avancado" "Magenta"
    Row "  [8]  Manutencao Completa - Limpeza + Rede + Diagnostico (auto)" "Magenta"
    Row "  [9]  Coleta de Logs Profundos para Analise" "Green"
    Row ""
    MenuSec "Sistema" "DarkGray"
    Row "  [R]  Reiniciar Computador" "DarkGray"
    Row "  [0]  Sair" "Red"
    Row ""
    Write-Host "  $bl$HW$br" -ForegroundColor Cyan
    Write-Host ""
}

# ==============================================================================
# MODULO 1 - KIT REPARO
# ==============================================================================
function Invoke-KitReparo {
    Show-Separador "MODULO 1 - KIT REPARO DO SISTEMA"
    $t0 = Get-Date; Write-Log "INICIO" "Kit Reparo"

    Write-Info "Iniciando SFC..."; Write-Aviso "Pode levar varios minutos."
    Write-Progress -Activity "Kit Reparo" -Status "SFC /scannow..." -PercentComplete 10
    try {
        $j = Start-Process sfc.exe -ArgumentList "/scannow" -Wait -PassThru -NoNewWindow
        Write-Progress -Activity "Kit Reparo" -Status "SFC concluido" -PercentComplete 50
        if ($j.ExitCode -eq 0) { Write-Success "SFC OK. Log: C:\Windows\Logs\CBS\CBS.log" }
        else { Write-Aviso "SFC codigo $($j.ExitCode). Verifique CBS.log" }
    } catch { Write-Erro "SFC falhou: $_" }

    Pause-Script "  SFC finalizado. ENTER para iniciar DISM..."

    Write-Info "Iniciando DISM RestoreHealth..."; Write-Aviso "10 a 30 minutos, dependendo da conexao."
    Write-Progress -Activity "Kit Reparo" -Status "DISM /RestoreHealth..." -PercentComplete 60
    try {
        $j = Start-Process DISM.exe -ArgumentList "/Online /Cleanup-Image /RestoreHealth" -Wait -PassThru -NoNewWindow
        Write-Progress -Activity "Kit Reparo" -Completed
        switch ($j.ExitCode) {
            0           { Write-Success "DISM OK." }
            -2146498554 { Write-Aviso  "DISM: nenhuma corrupcao encontrada." }
            default     { Write-Aviso  "DISM codigo $($j.ExitCode). Verifique C:\Windows\Logs\DISM\dism.log" }
        }
    } catch { Write-Erro "DISM falhou: $_" }

    Show-Resumo "Kit Reparo" ([int]((Get-Date)-$t0).TotalSeconds) "Recomenda-se reiniciar"
    Pause-Script
}

# ==============================================================================
# MODULO 2 - LIMPEZA
# ==============================================================================
function Invoke-Limpeza {
    Show-Separador "MODULO 2 - LIMPEZA E OTIMIZACAO"
    $t0 = Get-Date; $total = 0; Write-Log "INICIO" "Limpeza"

    function LimparPasta {
        param([string]$Path, [string]$Nome)
        Write-Info "Limpando $Nome..."
        try {
            $a = (Get-ChildItem $Path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
            Get-ChildItem $Path -Recurse -Force -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
            $d = (Get-ChildItem $Path -Recurse -Force -ErrorAction SilentlyContinue | Measure-Object Length -Sum).Sum
            $mb = [math]::Round((($a - $d) / 1MB), 2)
            Write-Success "${Nome}: ${mb} MB liberados."
            return $mb
        } catch { Write-Erro "Erro em ${Nome}: $_"; return 0 }
    }

    $total += LimparPasta "C:\Windows\Temp"                              "Windows\Temp"
    $total += LimparPasta "$env:USERPROFILE\AppData\Local\Temp"          "UserTemp"
    $total += LimparPasta "C:\Windows\Prefetch"                          "Prefetch"

    Pause-Script "  Temp/Prefetch OK. ENTER para Lixeira..."
    Write-Info "Esvaziando Lixeira..."
    try {
        $n = (New-Object -ComObject Shell.Application).Namespace(0xA).Items().Count
        Clear-RecycleBin -Force -ErrorAction Stop
        Write-Success "Lixeira: $n itens removidos."
    } catch { Write-Aviso "Lixeira: $_" }

    Pause-Script "  Lixeira OK. ENTER para Event Logs..."
    Write-Info "Limpando logs de eventos..."
    try {
        $logs   = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | Where-Object { $_.RecordCount -gt 0 }
        $limpos = 0
        foreach ($l in $logs) {
            try { [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($l.LogName); $limpos++ } catch { }
        }
        Write-Success "Event Logs: $limpos de $($logs.Count) limpos."
    } catch { Write-Erro "Erro nos logs: $_" }

    Show-Resumo "Limpeza" ([int]((Get-Date)-$t0).TotalSeconds) "$([math]::Round($total,2)) MB liberados"
    Pause-Script
}

# ==============================================================================
# MODULO 3 - SPOOLER
# ==============================================================================
function Invoke-RepararSpooler {
    Show-Separador "MODULO 3 - REPARO DE IMPRESSAO (SPOOLER)"
    $t0 = Get-Date; Write-Log "INICIO" "Spooler"

    Write-Info "Parando Spooler..."
    try { Stop-Service "Spooler" -Force -ErrorAction Stop; Write-Success "Spooler parado." }
    catch { Write-Erro "Falha: $_"; Pause-Script; return }
    Start-Sleep 2

    Write-Info "Limpando fila de impressao..."
    try {
        $itens = Get-ChildItem "C:\Windows\System32\spool\PRINTERS" -Force -ErrorAction SilentlyContinue
        $itens | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        Write-Success "$($itens.Count) arquivo(s) removidos."
    } catch { Write-Erro "Erro na fila: $_" }
    Start-Sleep 1

    Write-Info "Reiniciando Spooler..."
    try { Start-Service "Spooler" -ErrorAction Stop; Write-Success "Spooler ativo. Status: $((Get-Service 'Spooler').Status)" }
    catch { Write-Erro "Falha ao iniciar: $_" }

    Show-Resumo "Spooler" ([int]((Get-Date)-$t0).TotalSeconds)
    Pause-Script
}

# ==============================================================================
# MODULO 4 - REDE
# ==============================================================================
function Invoke-RedeSegura {
    Show-Separador "MODULO 4 - REDE SAFE MODE"
    $t0 = Get-Date; Write-Log "INICIO" "Rede"
    Write-Aviso "Nenhuma interface sera desativada. RDP/VPN preservados."
    Write-Host ""

    Write-Info "ipconfig /flushdns..."
    try { & ipconfig /flushdns 2>&1 | Out-Null; if ($LASTEXITCODE -eq 0) { Write-Success "DNS limpo." } else { Write-Aviso "Codigo $LASTEXITCODE" } }
    catch { Write-Erro $_}
    Start-Sleep 1

    Write-Info "ipconfig /registerdns..."
    try { & ipconfig /registerdns 2>&1 | Out-Null; if ($LASTEXITCODE -eq 0) { Write-Success "DNS registrado." } else { Write-Aviso "Codigo $LASTEXITCODE" } }
    catch { Write-Erro $_ }
    Pause-Script "  DNS OK. ENTER para Winsock reset..."

    Write-Info "netsh winsock reset..."
    Write-Aviso "Reiniciar a maquina para aplicar."
    try { & netsh winsock reset 2>&1 | Out-Null; if ($LASTEXITCODE -eq 0) { Write-Success "Winsock resetado." } else { Write-Aviso "Codigo $LASTEXITCODE" } }
    catch { Write-Erro $_ }

    Show-Resumo "Rede Safe Mode" ([int]((Get-Date)-$t0).TotalSeconds) "Reinicie para aplicar Winsock"
    Pause-Script
}

# ==============================================================================
# MODULO 5 - DIAGNOSTICO
# ==============================================================================
function Invoke-DiagnosticoRapido {
    param([switch]$Silencioso)
    if (-not $Silencioso) { Show-Separador "MODULO 5 - DIAGNOSTICO RAPIDO" }
    Write-Log "INICIO" "Diagnostico"

    Write-Info "Rede:"
    try {
        Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
            Where-Object { $_.IPAddress -ne "127.0.0.1" } |
            ForEach-Object { Write-Host "    $($_.InterfaceAlias): $($_.IPAddress)/$($_.PrefixLength)" -ForegroundColor White }
    } catch { Write-Aviso $_ }

    Write-Host ""
    Write-Info "Uptime:"
    try {
        $os = Get-CimInstance Win32_OperatingSystem
        $up = (Get-Date) - $os.LastBootUpTime
        Write-Host "    $($up.Days)d $($up.Hours)h $($up.Minutes)min  (boot: $($os.LastBootUpTime.ToString('dd/MM/yyyy HH:mm')))" -ForegroundColor White
    } catch { Write-Aviso $_ }

    Write-Host ""
    Write-Info "Ativacao Windows:"
    try {
        $m = @{0="Nao licenciado";1="ATIVO";2="OOBGrace";3="OOTGrace";4="NonGenuine";5="Notificacao";6="ExtendedGrace"}
        $l = Get-CimInstance SoftwareLicensingProduct -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*Windows*" } | Select-Object -First 1
        if ($l) { $cor = if ($l.LicenseStatus -eq 1) { "Green" } else { "Yellow" }; Write-Host "    $($m[[int]$l.LicenseStatus])" -ForegroundColor $cor }
    } catch { Write-Aviso $_ }

    Write-Host ""
    Write-Info "Disco:"
    try {
        Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue | Where-Object { $_.Used -gt 0 } | ForEach-Object {
            $tot = [math]::Round(($_.Used+$_.Free)/1GB,1); $liv = [math]::Round($_.Free/1GB,1)
            $pct = [math]::Round(($_.Used/($_.Used+$_.Free))*100,0)
            $cor = if ($pct -gt 85) {"Red"} elseif ($pct -gt 70) {"Yellow"} else {"White"}
            Write-Host "    Drive $($_.Name): $liv GB livres / $tot GB ($pct% usado)" -ForegroundColor $cor
        }
    } catch { Write-Aviso $_ }

    Write-Host ""
    Write-Info "Windows Defender:"
    try {
        $d = Get-MpComputerStatus -ErrorAction Stop
        $cor = if ($d.AntivirusEnabled) { "Green" } else { "Red" }
        $status = if ($d.AntivirusEnabled) { "ATIVO" } else { "INATIVO" }
        Write-Host "    Status    : $status" -ForegroundColor $cor
        Write-Host "    Definicoes: $($d.AntivirusSignatureLastUpdated.ToString('dd/MM/yyyy HH:mm'))" -ForegroundColor White
        if (-not $d.RealTimeProtectionEnabled) { Write-Aviso "Protecao em tempo real DESATIVADA!" }
    } catch { Write-Aviso "Nao foi possivel verificar Defender: $_" }

    if (-not $Silencioso) { Write-Host ""; Pause-Script }
}

# ==============================================================================
# MODULO 6 - WINGET
# ==============================================================================
function Invoke-WingetUpdate {
    Show-Separador "MODULO 6 - ATUALIZAR APLICATIVOS (WINGET)"
    $t0 = Get-Date; Write-Log "INICIO" "Winget"

    try { Get-Command winget -ErrorAction Stop | Out-Null; Write-Success "Winget encontrado." }
    catch { Write-Erro "Winget nao encontrado. Instale o App Installer (Microsoft Store)."; Pause-Script; return }

    Write-Host ""; Write-Info "Atualizacoes disponiveis:"; Write-Host ""
    try { & winget upgrade } catch { Write-Erro "$_"; Pause-Script; return }

    Write-Host ""
    if ((Read-Host "  Atualizar TODOS? (S/N)") -match "^[Ss]$") {
        Write-Info "Atualizando..."; Write-Aviso "Aguarde, nao feche o script."
        try {
            & winget upgrade --all --include-unknown --silent --accept-package-agreements --accept-source-agreements
            Show-Resumo "Winget" ([int]((Get-Date)-$t0).TotalSeconds)
        } catch { Write-Erro "$_" }
    } else { Write-Aviso "Cancelado." }
    Pause-Script
}

# ==============================================================================
# MODULO 7 - BACKUP DRIVERS
# ==============================================================================
function Invoke-BackupDrivers {
    Show-Separador "MODULO 7 - BACKUP DE DRIVERS"
    $dest = "C:\BackupDrivers\$(Get-Date -Format 'yyyy-MM-dd_HH-mm')"
    Write-Info "Destino: $dest"; Write-Aviso "Pode levar alguns minutos."
    Write-Host ""
    if ((Read-Host "  Confirmar backup em '$dest'? (S/N)") -notmatch "^[Ss]$") { Write-Aviso "Cancelado."; Pause-Script; return }

    $t0 = Get-Date; Write-Log "INICIO" "Backup Drivers -> $dest"
    try {
        New-Item -ItemType Directory -Path $dest -Force | Out-Null
        Write-Progress -Activity "Backup Drivers" -Status "Exportando..." -PercentComplete 30
        Export-WindowsDriver -Online -Destination $dest -ErrorAction Stop
        Write-Progress -Activity "Backup Drivers" -Completed
        $qtd = (Get-ChildItem $dest -Recurse -Filter "*.inf" -ErrorAction SilentlyContinue).Count
        Show-Resumo "Backup Drivers" ([int]((Get-Date)-$t0).TotalSeconds) "$qtd drivers em $dest"
    } catch { Write-Erro "$_" }
    Pause-Script
}

# ==============================================================================
# MODULO 8 - MANUTENCAO COMPLETA
# ==============================================================================
function Invoke-ManutencaoCompleta {
    Show-Separador "MODULO 8 - MANUTENCAO COMPLETA AUTOMATICA"
    Write-Aviso "Serao executados em sequencia: Limpeza + Rede + Diagnostico"
    Write-Host ""
    if ((Read-Host "  Confirmar? (S/N)") -notmatch "^[Ss]$") { Write-Aviso "Cancelado."; Pause-Script; return }

    $t0 = Get-Date; Write-Log "INICIO" "Manutencao Completa"

    Write-Host "`n  -----[ ETAPA 1/3 - LIMPEZA ]-----" -ForegroundColor Magenta
    Invoke-Limpeza
    Write-Host "`n  -----[ ETAPA 2/3 - REDE ]-----" -ForegroundColor Magenta
    Invoke-RedeSegura
    Write-Host "`n  -----[ ETAPA 3/3 - DIAGNOSTICO ]-----" -ForegroundColor Magenta
    Invoke-DiagnosticoRapido -Silencioso

    $seg = [int]((Get-Date)-$t0).TotalSeconds
    Write-Host ""
    Write-Host "  $tl$H71$tr" -ForegroundColor Magenta
    $txt = "MANUTENCAO COMPLETA CONCLUIDA em ${seg}s"
    $pad = [math]::Floor((71 - $txt.Length) / 2)
    Write-Host "  $cv$(' ' * $pad)$txt$(' ' * (71 - $pad - $txt.Length))$cv" -ForegroundColor Green
    $txt2 = "Recomenda-se REINICIAR a maquina para aplicar todas as mudancas."
    $pad2 = [math]::Floor((71 - $txt2.Length) / 2)
    Write-Host "  $cv$(' ' * $pad2)$txt2$(' ' * (71 - $pad2 - $txt2.Length))$cv" -ForegroundColor Yellow
    Write-Host "  $bl$H71$br" -ForegroundColor Magenta
    Write-Log "RESUMO" "Manutencao Completa em ${seg}s"
    Pause-Script
}

# ==============================================================================
# MODULO 9 - COLETAR LOGS PARA IA
# ==============================================================================
function Invoke-ColetarLogs {
    Show-Separador "MODULO 9 - COLETAR LOGS PARA ANALISE POR IA"

    $relDir  = "$desktop\ipHosting-Logs\Relatorios"
    $relFile = "$relDir\Diagnostico_${env:COMPUTERNAME}_$(Get-Date -Format 'yyyy-MM-dd_HH-mm').txt"

    Write-Info "O relatorio sera salvo em:"
    Write-Host "  $relFile" -ForegroundColor White
    Write-Host ""
    Write-Aviso "Serao coletados:"
    Write-Host "    - Informacoes do sistema (hostname, OS, RAM, CPU)"        -ForegroundColor DarkGray
    Write-Host "    - Logs de eventos: Erros e Avisos (ultimas 24h)"          -ForegroundColor DarkGray
    Write-Host "    - Drivers com problema (Device Manager)"                  -ForegroundColor DarkGray
    Write-Host "    - Servicos parados/com erro"                              -ForegroundColor DarkGray
    Write-Host "    - Configuracao de rede (ipconfig /all)"                   -ForegroundColor DarkGray
    Write-Host "    - Espaco em disco e saude dos volumes"                    -ForegroundColor DarkGray
    Write-Host "    - Status do Windows Defender"                             -ForegroundColor DarkGray
    Write-Host "    - Ultimas linhas do CBS.log (SFC) e DISM.log"            -ForegroundColor DarkGray
    Write-Host "    - Processos que mais consomem CPU/RAM"                    -ForegroundColor DarkGray
    Write-Host ""

    if ((Read-Host "  Iniciar coleta? (S/N)") -notmatch "^[Ss]$") { Write-Aviso "Cancelado."; Pause-Script; return }

    try { New-Item -ItemType Directory -Path $relDir -Force | Out-Null } catch { }

    $t0 = Get-Date
    Write-Log "INICIO" "Coleta de Logs para IA"
    $linhas = [System.Collections.Generic.List[string]]::new()

    function Secao {
        param([string]$Titulo)
        $linhas.Add("")
        $linhas.Add("=" * 72)
        $linhas.Add("  $Titulo")
        $linhas.Add("=" * 72)
    }

    function Linha { param([string]$T = "") $linhas.Add($T) }

    # CABECALHO
    $linhas.Add("╔══════════════════════════════════════════════════════════════════════╗")
    $linhas.Add("║        RELATORIO DE DIAGNOSTICO - ipHosting Kit de Manutencao       ║")
    $linhas.Add("╠══════════════════════════════════════════════════════════════════════╣")
    $linhas.Add("║  Maquina : $env:COMPUTERNAME")
    $linhas.Add("║  Usuario : $env:USERNAME")
    $linhas.Add("║  Data    : $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss')")
    $linhas.Add("╠══════════════════════════════════════════════════════════════════════╣")
    $linhas.Add("║  INSTRUCAO PARA IA:                                                  ║")
    $linhas.Add("║  Analise os logs abaixo e identifique:                               ║")
    $linhas.Add("║  1) Erros criticos ou recorrentes que causam instabilidade           ║")
    $linhas.Add("║  2) Drivers com problema que precisam de atualizacao                 ║")
    $linhas.Add("║  3) Servicos parados que deveriam estar ativos                       ║")
    $linhas.Add("║  4) Anomalias de rede ou DNS                                         ║")
    $linhas.Add("║  5) Recomendacoes de acao por prioridade (critico/medio/baixo)       ║")
    $linhas.Add("╚══════════════════════════════════════════════════════════════════════╝")

    # --- 1. SISTEMA ---
    Write-Progress -Activity "Coletando Logs" -Status "Sistema..." -PercentComplete 5
    Secao "1. INFORMACOES DO SISTEMA"
    try {
        $os  = Get-CimInstance Win32_OperatingSystem
        $cs  = Get-CimInstance Win32_ComputerSystem
        $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
        $up  = (Get-Date) - $os.LastBootUpTime
        Linha "Hostname        : $env:COMPUTERNAME"
        Linha "SO              : $($os.Caption) Build $($os.BuildNumber)"
        Linha "Arquitetura     : $($os.OSArchitecture)"
        Linha "Ultimo Boot     : $($os.LastBootUpTime.ToString('dd/MM/yyyy HH:mm'))"
        Linha "Uptime          : $($up.Days)d $($up.Hours)h $($up.Minutes)min"
        Linha "RAM Total       : $([math]::Round($cs.TotalPhysicalMemory/1GB,1)) GB"
        Linha "RAM Disponivel  : $([math]::Round($os.FreePhysicalMemory/1MB,1)) GB"
        Linha "CPU             : $($cpu.Name)"
        Linha "Dominio/Grupo   : $($cs.Domain)"
    } catch { Linha "Erro ao obter info do sistema: $_" }

    # --- 2. ATIVACAO ---
    Write-Progress -Activity "Coletando Logs" -Status "Ativacao..." -PercentComplete 10
    Secao "2. ATIVACAO DO WINDOWS"
    try {
        $m = @{0="Nao licenciado";1="ATIVO (Licenciado)";2="OOBGrace";3="OOTGrace";4="NonGenuineGrace";5="Notificacao";6="ExtendedGrace"}
        $l = Get-CimInstance SoftwareLicensingProduct -ErrorAction SilentlyContinue |
             Where-Object { $_.Name -like "*Windows*" } | Select-Object -First 1
        if ($l) { Linha "Status: $($m[[int]$l.LicenseStatus])" } else { Linha "Nao foi possivel verificar." }
    } catch { Linha "Erro: $_" }

    # --- 3. DISCO ---
    Write-Progress -Activity "Coletando Logs" -Status "Disco..." -PercentComplete 15
    Secao "3. ESPACO EM DISCO"
    try {
        Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue | Where-Object { $_.Used -gt 0 } | ForEach-Object {
            $tot = [math]::Round(($_.Used+$_.Free)/1GB,1); $liv = [math]::Round($_.Free/1GB,1)
            $pct = [math]::Round(($_.Used/($_.Used+$_.Free))*100,0)
            $alerta = if ($pct -gt 85) { " [CRITICO: disco quase cheio!]" } elseif ($pct -gt 70) { " [ATENCAO]" } else { "" }
            Linha "Drive $($_.Name): $liv GB livres de $tot GB ($pct% usado)$alerta"
        }
    } catch { Linha "Erro: $_" }

    # --- 4. REDE ---
    Write-Progress -Activity "Coletando Logs" -Status "Rede..." -PercentComplete 20
    Secao "4. CONFIGURACAO DE REDE"
    try {
        $saida = & ipconfig /all 2>&1
        foreach ($s in $saida) { Linha $s }
    } catch { Linha "Erro: $_" }

    # --- 5. DEFENDER ---
    Write-Progress -Activity "Coletando Logs" -Status "Defender..." -PercentComplete 25
    Secao "5. WINDOWS DEFENDER"
    try {
        $d = Get-MpComputerStatus -ErrorAction Stop
        Linha "Antivirus Ativo         : $($d.AntivirusEnabled)"
        Linha "Protecao Tempo Real     : $($d.RealTimeProtectionEnabled)"
        Linha "Definicoes Atualizadas  : $($d.AntivirusSignatureLastUpdated.ToString('dd/MM/yyyy HH:mm'))"
        Linha "Versao Definicoes       : $($d.AntivirusSignatureVersion)"
        Linha "AM Running Mode         : $($d.AMRunningMode)"
        if (-not $d.RealTimeProtectionEnabled) { Linha "[ALERTA] Protecao em tempo real esta DESATIVADA!" }
        if (-not $d.AntivirusEnabled)           { Linha "[ALERTA] Antivirus DESATIVADO!" }
    } catch { Linha "Nao foi possivel coletar dados do Defender: $_" }

    # --- 6. DRIVERS COM PROBLEMA ---
    Write-Progress -Activity "Coletando Logs" -Status "Drivers..." -PercentComplete 35
    Secao "6. DRIVERS COM PROBLEMA (Device Manager)"
    try {
        $devs = Get-PnpDevice -ErrorAction SilentlyContinue | Where-Object { $_.Status -ne "OK" }
        if ($devs) {
            foreach ($d in $devs) { Linha "[$($d.Status)] $($d.Class) - $($d.FriendlyName)" }
        } else { Linha "Nenhum driver com problema encontrado." }
    } catch { Linha "Erro: $_" }

    # --- 7. SERVICOS COM ERRO ---
    Write-Progress -Activity "Coletando Logs" -Status "Servicos..." -PercentComplete 45
    Secao "7. SERVICOS PARADOS (StartType=Automatic, Status=Stopped)"
    try {
        $svcs = Get-Service -ErrorAction SilentlyContinue |
                Where-Object { $_.StartType -eq "Automatic" -and $_.Status -eq "Stopped" }
        if ($svcs) { foreach ($s in $svcs) { Linha "PARADO: $($s.DisplayName) [$($s.Name)]" } }
        else       { Linha "Nenhum servico automatico parado." }
    } catch { Linha "Erro: $_" }

    # --- 8. PROCESSOS TOP CPU/RAM ---
    Write-Progress -Activity "Coletando Logs" -Status "Processos..." -PercentComplete 50
    Secao "8. TOP 15 PROCESSOS (CPU + RAM)"
    try {
        Linha "--- Por CPU (WorkingSet) ---"
        Get-Process -ErrorAction SilentlyContinue | Sort-Object CPU -Descending | Select-Object -First 15 |
            ForEach-Object { Linha ("  {0,-30} CPU:{1,8:F1}s  RAM:{2,6} MB" -f $_.Name, $_.CPU, [math]::Round($_.WorkingSet/1MB,1)) }
        Linha ""
        Linha "--- Por RAM ---"
        Get-Process -ErrorAction SilentlyContinue | Sort-Object WorkingSet -Descending | Select-Object -First 15 |
            ForEach-Object { Linha ("  {0,-30} RAM:{1,6} MB" -f $_.Name, [math]::Round($_.WorkingSet/1MB,1)) }
    } catch { Linha "Erro: $_" }

    # --- 9. EVENTOS: SISTEMA ---
    Write-Progress -Activity "Coletando Logs" -Status "Event Log System..." -PercentComplete 60
    Secao "9. EVENT LOG - SYSTEM (Erros/Avisos - ultimas 24h)"
    try {
        $desde = (Get-Date).AddHours(-24)
        $evs = Get-WinEvent -LogName System -ErrorAction SilentlyContinue |
               Where-Object { $_.TimeCreated -ge $desde -and $_.Level -in @(1,2,3) } |
               Select-Object -First 50
        if ($evs) {
            foreach ($e in $evs) {
                $nivel = @{1="CRITICO";2="ERRO";3="AVISO"}[[int]$e.Level]
                Linha "[$nivel] $($e.TimeCreated.ToString('dd/MM HH:mm:ss')) | $($e.ProviderName) | $($e.Message -replace '\r?\n',' ' | Select-Object -First 1)"
            }
        } else { Linha "Nenhum evento de erro/aviso nas ultimas 24h." }
    } catch { Linha "Erro ao ler System log: $_" }

    # --- 10. EVENTOS: APPLICATION ---
    Write-Progress -Activity "Coletando Logs" -Status "Event Log Application..." -PercentComplete 70
    Secao "10. EVENT LOG - APPLICATION (Erros/Avisos - ultimas 24h)"
    try {
        $desde = (Get-Date).AddHours(-24)
        $evs = Get-WinEvent -LogName Application -ErrorAction SilentlyContinue |
               Where-Object { $_.TimeCreated -ge $desde -and $_.Level -in @(1,2,3) } |
               Select-Object -First 50
        if ($evs) {
            foreach ($e in $evs) {
                $nivel = @{1="CRITICO";2="ERRO";3="AVISO"}[[int]$e.Level]
                Linha "[$nivel] $($e.TimeCreated.ToString('dd/MM HH:mm:ss')) | $($e.ProviderName) | $($e.Message -replace '\r?\n',' ' | Select-Object -First 1)"
            }
        } else { Linha "Nenhum evento de erro/aviso nas ultimas 24h." }
    } catch { Linha "Erro ao ler Application log: $_" }

    # --- 11. CBS LOG (SFC) ---
    Write-Progress -Activity "Coletando Logs" -Status "CBS.log (SFC)..." -PercentComplete 82
    Secao "11. CBS.LOG - ULTIMAS 80 LINHAS (SFC)"
    try {
        $cbsPath = "C:\Windows\Logs\CBS\CBS.log"
        if (Test-Path $cbsPath) {
            Get-Content $cbsPath -Tail 80 -ErrorAction SilentlyContinue | ForEach-Object { Linha $_ }
        } else { Linha "CBS.log nao encontrado (SFC pode nunca ter sido executado)." }
    } catch { Linha "Erro: $_" }

    # --- 12. DISM LOG ---
    Write-Progress -Activity "Coletando Logs" -Status "DISM.log..." -PercentComplete 90
    Secao "12. DISM.LOG - ULTIMAS 50 LINHAS"
    try {
        $dismPath = "C:\Windows\Logs\DISM\dism.log"
        if (Test-Path $dismPath) {
            Get-Content $dismPath -Tail 50 -ErrorAction SilentlyContinue | ForEach-Object { Linha $_ }
        } else { Linha "DISM.log nao encontrado." }
    } catch { Linha "Erro: $_" }

    # RODAPE
    Write-Progress -Activity "Coletando Logs" -Status "Salvando arquivo..." -PercentComplete 97
    $linhas.Add("")
    $linhas.Add("=" * 72)
    $linhas.Add("  FIM DO RELATORIO")
    $linhas.Add("  Gerado em: $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') por ipHosting Kit v3.0")
    $linhas.Add("=" * 72)

    # SALVAR
    try {
        [System.IO.File]::WriteAllLines($relFile, $linhas, [System.Text.Encoding]::UTF8)
        Write-Progress -Activity "Coletando Logs" -Completed
        $seg = [int]((Get-Date)-$t0).TotalSeconds
        Write-Host ""
        Write-Success "Relatorio gerado em ${seg}s!"
        Write-Host "  Arquivo : $relFile" -ForegroundColor White
        Write-Host "  Tamanho : $([math]::Round((Get-Item $relFile).Length/1KB,1)) KB" -ForegroundColor White
        Write-Log "RESUMO" "Relatorio salvo: $relFile"

        Write-Host ""
        Write-Aviso "Como usar com IA:"
        Write-Host "  1. Abra o arquivo acima em um editor de texto" -ForegroundColor DarkGray
        Write-Host "  2. Copie TODO o conteudo (Ctrl+A, Ctrl+C)" -ForegroundColor DarkGray
        Write-Host "  3. Cole no chat da IA (ChatGPT, Claude, Gemini)" -ForegroundColor DarkGray
        Write-Host "  4. A IA ira identificar os problemas e dar recomendacoes" -ForegroundColor DarkGray
        Write-Host ""

        $abrir = Read-Host "  Abrir o arquivo agora no Bloco de Notas? (S/N)"
        if ($abrir -match "^[Ss]$") { Start-Process notepad.exe -ArgumentList $relFile }
    } catch {
        Write-Erro "Falha ao salvar relatorio: $_"
    }

    Pause-Script
}

# ==============================================================================
# MODULO R - REINICIAR COMPUTADOR
# ==============================================================================
function Invoke-ReiniciarComputador {
    Show-Separador "REINICIAR COMPUTADOR"
    Write-Aviso "Esta acao vai REINICIAR o computador imediatamente!"
    Write-Host ""
    Write-Host "  Salve todos os arquivos abertos antes de confirmar." -ForegroundColor DarkGray
    Write-Host ""
    if ((Read-Host "  Confirmar reinicio? (S/N)") -match "^[Ss]$") {
        Write-Info "Reiniciando em 5 segundos..."
        Write-Log "ACAO" "Reinicio solicitado pelo tecnico"
        1..5 | ForEach-Object { Write-Host "  $_..." -ForegroundColor Yellow; Start-Sleep 1 }
        Restart-Computer -Force
    } else {
        Write-Aviso "Reinicio cancelado."
        Pause-Script
    }
}

# ==============================================================================
# LOOP PRINCIPAL
# ==============================================================================
Write-Log "SESSAO" "Iniciado por $env:USERNAME em $env:COMPUTERNAME"

do {
    Show-Banner
    Show-Menu

    $op = (Read-Host "  Opcao").Trim()

    switch ($op.ToUpper()) {
        "1" { Invoke-KitReparo }
        "2" { Invoke-Limpeza }
        "3" { Invoke-RepararSpooler }
        "4" { Invoke-RedeSegura }
        "5" { Invoke-DiagnosticoRapido }
        "6" { Invoke-WingetUpdate }
        "7" { Invoke-BackupDrivers }
        "8" { Invoke-ManutencaoCompleta }
        "9" { Invoke-ColetarLogs }
        "R" { Invoke-ReiniciarComputador }
        "0" {
            Show-Banner
            Write-Host "  Encerrando... Bom trabalho, $env:USERNAME!" -ForegroundColor Green
            Write-Host "  Log da sessao: $logFile" -ForegroundColor DarkGray
            Write-Log "SESSAO" "Encerrado pelo tecnico"
            Write-Host ""; Start-Sleep 2
        }
        default { Write-Aviso "Opcao invalida. Use 1-9, R ou 0."; Start-Sleep 2 }
    }

} while ($op -ne "0")