@echo off
setlocal
cd /d "%~dp0"
if "%~1"=="" (
  echo Drag file zip addon ke BAT ini.
  echo File dari ChatGPT jangan install manual ke Kodi.
  echo Drag ke sini supaya masuk repo GitHub, lalu Kodi update dari repo.
  echo.
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Import-Addon-Zip.ps1" %* -RepoRoot "%~dp0.." -Upload
echo.
pause
