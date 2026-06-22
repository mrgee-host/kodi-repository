@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0PATCH-AF3-LRS-1.3.91-r7-MERGED-PROGRESS-LEFT-FIX.ps1"
pause
