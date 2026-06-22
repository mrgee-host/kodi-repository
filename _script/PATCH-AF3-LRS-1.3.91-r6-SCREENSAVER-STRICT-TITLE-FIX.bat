@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0PATCH-AF3-LRS-1.3.91-r6-SCREENSAVER-STRICT-TITLE-FIX.ps1"
pause
