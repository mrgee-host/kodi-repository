@echo off
setlocal EnableExtensions DisableDelayedExpansion

set "TOOLDIR=%~dp0"
for %%I in ("%TOOLDIR%..") do set "REPOROOT=%%~fI"

if "%~1"=="" (
  echo.
  echo Drag one or more Kodi addon zip files onto this BAT.
  echo.
  pause
  exit /b 1
)

set "FAILED=0"

:IMPORT_LOOP
if "%~1"=="" goto AFTER_IMPORT

echo.
echo ============================================================
echo Importing: %~nx1
echo ============================================================

powershell -NoProfile -ExecutionPolicy Bypass -File "%TOOLDIR%Import-Addon-Zip-CopyOnly.ps1" -RepoRoot "%REPOROOT%" -ZipPath "%~f1"
if errorlevel 1 set "FAILED=1"
shift
goto IMPORT_LOOP

:AFTER_IMPORT
if "%FAILED%"=="1" (
  echo.
  echo Import failed.
  pause
  exit /b 1
)

echo.
echo Import complete. ZIP and icon.png copied. Not uploaded.
pause
