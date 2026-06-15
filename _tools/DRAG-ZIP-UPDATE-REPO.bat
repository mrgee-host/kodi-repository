@echo off
setlocal
cd /d "%~dp0.."
if "%~1"=="" (
  echo Drag one or more Kodi addon zip files onto this BAT.
  echo.
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Import-Addon-Zip.ps1" -RepoRoot "%CD%" -Upload -ZipPath %*
if errorlevel 1 (
  echo.
  echo FAILED. Not uploading.
  pause
  exit /b 1
)
echo.
echo Done. Kodi can now Check for updates.
pause
