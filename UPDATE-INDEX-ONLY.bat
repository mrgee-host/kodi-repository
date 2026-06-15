@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_tools\Update-Repo-Index.ps1" -RepoRoot "%CD%"
echo.
pause
