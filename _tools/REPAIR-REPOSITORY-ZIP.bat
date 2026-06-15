@echo off
setlocal
cd /d "%~dp0\.."
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Repair-Repository-Zip.ps1" -RepoRoot "%CD%"
echo.
pause
