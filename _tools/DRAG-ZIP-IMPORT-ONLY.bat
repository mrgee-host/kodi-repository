@echo off
setlocal EnableExtensions
cd /d "%~dp0"

if "%~1"=="" (
  echo Drag satu atau beberapa ZIP addon Kodi ke file ini.
  echo Ini hanya import lokal, tidak push ke GitHub.
  echo.
  pause
  exit /b 1
)

:import_loop
if "%~1"=="" goto done

echo.
echo ============================================================
echo Importing: %~nx1
echo ============================================================
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_tools\Import-Addon-Zip.ps1" -RepoRoot "%CD%" -ZipPath "%~1"
if errorlevel 1 (
  echo.
  echo Import failed.
  pause
  exit /b 1
)
shift
goto import_loop

:done
echo.
echo Import done. Not uploaded.
pause
