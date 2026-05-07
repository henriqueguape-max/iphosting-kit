@echo off
chcp 65001 > nul
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ipHosting-Manutencao.ps1"
pause
