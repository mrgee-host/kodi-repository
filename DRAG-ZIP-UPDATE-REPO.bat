@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "REPO_ROOT=D:\Others\KodiRepo\kodi-repository"

if "%~1"=="" (
  echo Drag satu atau beberapa zip addon ke file BAT ini.
  echo.
  pause
  exit /b 1
)

if not exist "%REPO_ROOT%\_tools\Import-Addon-Zip.ps1" (
  echo ERROR: Tools repo tidak ditemukan:
  echo   %REPO_ROOT%\_tools\Import-Addon-Zip.ps1
  echo.
  echo Pastikan BAT ini dipakai setelah APPLY-CLEAN-REPO.bat berhasil.
  pause
  exit /b 1
)

if not exist "%REPO_ROOT%\_tools\Upload-Repo.ps1" (
  echo ERROR: Upload tool tidak ditemukan:
  echo   %REPO_ROOT%\_tools\Upload-Repo.ps1
  pause
  exit /b 1
)

:loop
if "%~1"=="" goto upload

echo.
echo ============================================================
echo Importing: %~nx1
echo ============================================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO_ROOT%\_tools\Import-Addon-Zip.ps1" -RepoRoot "%REPO_ROOT%" -ZipPath "%~1"
if errorlevel 1 (
  echo.
  echo IMPORT GAGAL. Upload dibatalkan.
  pause
  exit /b 1
)
shift
goto loop

:upload
echo.
echo ============================================================
echo Uploading repository to GitHub
echo ============================================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%REPO_ROOT%\_tools\Upload-Repo.ps1" -RepoRoot "%REPO_ROOT%"
if errorlevel 1 (
  echo.
  echo UPLOAD GAGAL.
  pause
  exit /b 1
)

echo.
echo Done. Kodi can now Check for updates.
pause
