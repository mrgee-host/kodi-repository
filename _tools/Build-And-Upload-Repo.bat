@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Build-And-Upload-Repo.ps1" -RepoRoot "%~dp0.."
echo.
pause
