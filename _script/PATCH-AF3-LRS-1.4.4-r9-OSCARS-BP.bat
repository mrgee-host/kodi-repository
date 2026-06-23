@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0PATCH-AF3-LRS-1.4.4-r9-OSCARS-BP.ps1"
echo.
pause
