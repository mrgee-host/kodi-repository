@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0RESTORE-KPM-TO-DEFAULT.ps1"
echo.
pause
