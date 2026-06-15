@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Repair-Zips-From-Kodi.ps1" -RepoRoot "%~dp0.." -Upload
echo.
pause
