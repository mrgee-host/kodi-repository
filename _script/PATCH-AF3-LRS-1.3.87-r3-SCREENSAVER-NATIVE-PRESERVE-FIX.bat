@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0PATCH-AF3-LRS-1.3.87-r3-SCREENSAVER-NATIVE-PRESERVE-FIX.ps1"
pause
