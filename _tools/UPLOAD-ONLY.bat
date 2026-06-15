@echo off
setlocal
cd /d "%~dp0.."
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Upload-Repo.ps1" -RepoRoot "%CD%" -Message "Update Kodi repository add-ons"
pause
