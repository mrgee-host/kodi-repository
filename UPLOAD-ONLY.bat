@echo off
setlocal EnableExtensions
set "REPO_ROOT=D:\Others\KodiRepo\kodi-repository"

if not exist "%REPO_ROOT%\_tools\Upload-Repo.ps1" (
  echo ERROR: Upload tool tidak ditemukan:
  echo   %REPO_ROOT%\_tools\Upload-Repo.ps1
  pause
  exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO_ROOT%\_tools\Upload-Repo.ps1" -RepoRoot "%REPO_ROOT%"
pause
