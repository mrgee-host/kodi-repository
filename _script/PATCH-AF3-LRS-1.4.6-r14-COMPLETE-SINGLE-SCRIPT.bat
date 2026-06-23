@echo off
setlocal
set SCRIPT=%~dp0PATCH-AF3-LRS-1.4.6-r14-COMPLETE-SINGLE-SCRIPT.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT%"
echo.
pause
