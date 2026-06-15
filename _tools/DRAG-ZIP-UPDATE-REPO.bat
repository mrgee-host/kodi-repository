@echo off
setlocal EnableExtensions
cd /d "%~dp0"

if "%~1"=="" (
  echo Drag satu atau beberapa ZIP addon Kodi ke file ini.
  echo Contoh: script.library.ratings.scraper-1.3.10.zip
  echo.
  pause
  exit /b 1
)

:import_loop
if "%~1"=="" goto upload_now

echo.
echo ============================================================
echo Importing: %~nx1
echo ============================================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_tools\Import-Addon-Zip.ps1" -RepoRoot "%CD%" -ZipPath "%~1"
if errorlevel 1 (
  echo.
  echo Import failed. Upload cancelled.
  pause
  exit /b 1
)
shift
goto import_loop

:upload_now
echo.
echo ============================================================
echo Uploading repository to GitHub
echo ============================================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_tools\Upload-Repo.ps1" -RepoRoot "%CD%" -Message "Update Kodi repository addons"
if errorlevel 1 (
  echo.
  echo Upload failed.
  pause
  exit /b 1
)

echo.
echo Done. Kodi can now Check for updates.
pause
