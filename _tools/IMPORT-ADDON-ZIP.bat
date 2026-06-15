@echo off
setlocal
cd /d "%~dp0"
if "%~1"=="" (
  echo Drag satu file addon .zip ke file BAT ini.
  echo.
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Import-Addon-Zip.ps1" -RepoRoot "%~dp0.." -ZipPath "%~1"
echo.
pause
