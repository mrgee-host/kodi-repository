@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Import-Update-Folder.ps1" -RepoRoot "%~dp0.." -InputDir "%~dp0..\_incoming_addons" -Upload
echo.
pause
