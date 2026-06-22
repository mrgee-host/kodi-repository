@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0PATCH-AF3-LRS-1.3.91-r5-MERGED-FIX.ps1"
pause
