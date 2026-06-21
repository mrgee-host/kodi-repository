@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0PATCH-AF3-LRS-1.3.87-r4-MERGED-FIX.ps1"
pause
