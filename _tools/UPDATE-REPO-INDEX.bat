@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Update-Repo-Index.ps1" -RepoRoot "%~dp0.."
echo.
pause
