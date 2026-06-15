@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Import-Update-Folder.ps1" -FolderPath "%~dp0..\_incoming_addons" -RepoRoot "%~dp0.." -Upload
echo.
pause
