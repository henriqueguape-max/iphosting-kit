# ipHosting — Kit de Manutenção Técnica

Ferramenta de manutenção Windows desenvolvida pela equipe **ipHosting**.  
Interface interativa no terminal com menu categorizado, stats ao vivo e log automático de sessão.

---

## Execução rápida (recomendado)

Abra o **PowerShell como Administrador** e execute:

```powershell
irm https://raw.githubusercontent.com/henriqueguape-max/iphosting-kit/main/ipHosting-Manutencao.ps1 | iex
```

> O script não é salvo no disco. Tudo roda diretamente na memória.

---

## Execução local

1. Baixe os dois arquivos:
   - `ipHosting.bat`
   - `ipHosting-Manutencao.ps1`
2. Coloque-os na **mesma pasta**
3. Dê duplo clique em `ipHosting.bat`

> O `.bat` eleva para Administrador automaticamente se necessário.

---

## Requisitos

| Item | Versão mínima |
|------|--------------|
| Windows | 10 / 11 |
| PowerShell | 5.1 (já incluso no Windows) |
| Permissão | Administrador (eleva automaticamente) |
| Winget | Apenas para opção [6] — App Installer (Microsoft Store) |

---

## Interface

```
╔═════════════════════════════════════════════════════════════════════════╗
║                                                                         ║
║   ██╗██████╗ ██╗  ██╗ ██████╗ ███████╗████████╗██╗███╗   ██╗ ██████╗  ║
║   ██║██╔══██╗██║  ██║██╔═══██╗██╔════╝╚══██╔══╝██║████╗  ██║██╔════╝  ║
║   ██║██████╔╝███████║██║   ██║███████╗   ██║   ██║██╔██╗ ██║██║  ███╗ ║
║   ██║██╔═══╝ ██╔══██║██║   ██║╚════██║   ██║   ██║██║╚██╗██║██║   ██║ ║
║   ██║██║     ██║  ██║╚██████╔╝███████║   ██║   ██║██║ ╚████║╚██████╔╝ ║
║   ╚═╝╚═╝     ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝   ╚═╝╚═╝  ╚═══╝ ╚═════╝  ║
║                                                                         ║
║              KIT DE MANUTENCAO TECNICA  |  ipHosting v3.0              ║
╚═════════════════════════════════════════════════════════════════════════╝

╔═════════════════════════════════════════════════════════════════════════╗
║  MENU PRINCIPAL                                                         ║
╠═════════════════════════════════════════════════════════════════════════╣
║  RAM: 8.1/16.0 GB (51% usado)   Uptime: 0d 4h 32min                    ║
║  Disco C: 120/476 GB  (75% usado)                                       ║
╠═════════════════════════════════════════════════════════════════════════╣
║                                                                         ║
║  ── Reparo e Manutencao ────────────────────────────────────────────── ║
║    [1]  Kit Reparo        - SFC + DISM (repara arquivos do Windows)     ║
║    [2]  Limpeza           - Temp, Prefetch, Lixeira, Event Logs         ║
║    [3]  Reparo Spooler    - Para/limpa/reinicia servico de impressao    ║
║    [4]  Rede Safe Mode    - Flush DNS + Winsock Reset                   ║
║                                                                         ║
║  ── Ferramentas ────────────────────────────────────────────────────── ║
║    [5]  Diagnostico Rapido - IP, Disco, Ativacao, Defender, Uptime      ║
║    [6]  Atualizar Apps     - Winget upgrade em todos os aplicativos     ║
║    [7]  Backup de Drivers  - Exporta todos os drivers instalados        ║
║                                                                         ║
║  ── Avancado ───────────────────────────────────────────────────────── ║
║    [8]  Manutencao Completa - Limpeza + Rede + Diagnostico (auto)       ║
║    [9]  Coleta de Logs Profundos para Analise                           ║
║                                                                         ║
║  ── Sistema ────────────────────────────────────────────────────────── ║
║    [R]  Reiniciar Computador                                            ║
║    [0]  Sair                                                            ║
╚═════════════════════════════════════════════════════════════════════════╝
```

---

## Módulos

### [1] Kit Reparo — SFC + DISM
Executa o verificador de arquivos do sistema (`sfc /scannow`) e restauração de imagem do Windows (`DISM /RestoreHealth`).  
Log gerado em `C:\Windows\Logs\CBS\CBS.log`.

### [2] Limpeza e Otimização
Remove arquivos temporários das pastas:
- `C:\Windows\Temp`
- `%USERPROFILE%\AppData\Local\Temp`
- `C:\Windows\Prefetch`
- Lixeira
- Event Logs do Windows

Exibe total de MB liberados ao final.

### [3] Reparo de Impressão (Spooler)
Para o serviço `Spooler`, limpa a fila de impressão travada em `C:\Windows\System32\spool\PRINTERS` e reinicia o serviço.

### [4] Rede Safe Mode
- `ipconfig /flushdns` — limpa cache DNS
- `ipconfig /registerdns` — re-registra DNS
- `netsh winsock reset` — reseta a pilha de rede (requer reinício)

Nenhuma interface de rede é desativada. RDP e VPN são preservados.

### [5] Diagnóstico Rápido
Coleta e exibe em tela:
- Endereços IP de todas as interfaces
- Tempo de uptime e último boot
- Status de ativação do Windows
- Espaço em disco (alerta colorido acima de 70%/85%)
- Status do Windows Defender (ativo/inativo, data das definições)

### [6] Atualizar Apps (Winget)
Lista todas as atualizações disponíveis e, com confirmação, executa `winget upgrade --all`.

Requer **App Installer** instalado via Microsoft Store.

### [7] Backup de Drivers
Exporta todos os drivers instalados para `C:\BackupDrivers\YYYY-MM-DD_HH-mm` usando `Export-WindowsDriver`.  
Útil antes de formatos ou reinstalações.

### [8] Manutenção Completa (automática)
Executa em sequência sem interação:
1. Limpeza (módulo 2)
2. Rede Safe Mode (módulo 4)
3. Diagnóstico Rápido (módulo 5)

Ideal para manutenção rápida padrão.

### [9] Coleta de Logs Profundos para Análise
Gera um relatório `.txt` completo no Desktop contendo:
- Informações do sistema (SO, CPU, RAM, uptime)
- Status de ativação do Windows
- Espaço em disco
- `ipconfig /all`
- Status do Windows Defender
- Dispositivos com problema (Device Manager)
- Serviços automáticos parados
- Top 15 processos por CPU e RAM
- Event Log System — erros/avisos das últimas 24h
- Event Log Application — erros/avisos das últimas 24h
- Últimas 80 linhas do `CBS.log` (SFC)
- Últimas 50 linhas do `DISM.log`

O arquivo inclui cabeçalho explicativo para análise por IA (Claude, ChatGPT, Gemini).

### [R] Reiniciar Computador
Solicita confirmação e reinicia com contagem regressiva de 5 segundos.

---

## Logs de sessão

Cada execução grava um log automático em:

```
%USERPROFILE%\Desktop\ipHosting-Logs\YYYY-MM-DD.log
```

Formato de cada entrada:

```
14:32:07 [OK]    Spooler parado.
14:32:09 [OK]    3 arquivo(s) removidos.
14:32:10 [OK]    Spooler ativo. Status: Running
14:32:10 [RESUMO] Spooler concluido em 5s
```

Relatórios do módulo 9 são salvos em:

```
%USERPROFILE%\Desktop\ipHosting-Logs\Relatorios\Diagnostico_MAQUINA_YYYY-MM-DD_HH-mm.txt
```

---

## Segurança

- Nenhuma credencial, token ou dado pessoal está armazenado no script
- Nenhuma conexão de rede é feita durante a execução (exceto módulos 4 e 6)
- Todo o código é aberto e auditável
- Requer confirmação explícita antes de qualquer ação destrutiva (limpeza, backup, reinício)

---

## Estrutura do repositório

```
/
├── ipHosting.bat               # Launcher (duplo clique)
├── ipHosting-Manutencao.ps1    # Script principal
└── README.md                   # Este arquivo
```

---

## Contribuindo

Pull requests são bem-vindos.  
Para reportar bugs ou sugerir melhorias, abra uma [Issue](../../issues).

---

## Licença

MIT — uso livre, inclusive comercial.

---

*Desenvolvido por ipHosting — Suporte e Infraestrutura Windows*
