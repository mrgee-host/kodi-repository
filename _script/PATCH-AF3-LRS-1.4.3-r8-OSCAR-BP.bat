@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0PATCH-AF3-LRS-1.4.3-r8-OSCAR-BP.ps1"
echo.
pause
