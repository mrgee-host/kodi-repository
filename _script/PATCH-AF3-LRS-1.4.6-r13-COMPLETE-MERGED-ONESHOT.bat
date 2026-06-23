@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0PATCH-AF3-LRS-1.4.6-r13-COMPLETE-MERGED-ONESHOT.ps1"
echo.
pause
