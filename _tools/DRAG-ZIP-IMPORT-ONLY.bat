@echo off
setlocal EnableExtensions

REM ============================================================
REM Drag one or more Kodi add-on ZIP files onto this BAT.
REM Location expected: <repo-root>\_tools\DRAG-ZIP-IMPORT-ONLY.bat
REM Action: import ZIP(s) and update addons.xml locally only. No upload.
REM ============================================================

set "TOOL_DIR=%~dp0"
for %%I in ("%TOOL_DIR%..") do set "REPO_ROOT=%%~fI"

if "%~1"=="" (
    echo Drag add-on zip file^(s^) onto this BAT.
    echo This only imports locally and does NOT upload.
    echo.
    pause
    exit /b 1
)

:IMPORT_LOOP
if "%~1"=="" goto DONE

echo.
echo ============================================================
echo Importing: %~nx1
echo ============================================================

powershell -NoProfile -ExecutionPolicy Bypass -File "%TOOL_DIR%Import-Addon-Zip.ps1" -RepoRoot "%REPO_ROOT%" -ZipPath "%~1"
if errorlevel 1 (
    echo.
    echo Import failed.
    pause
    exit /b 1
)

shift
goto IMPORT_LOOP

:DONE
echo.
echo Done. Imported locally only. Run UPLOAD-ONLY.bat when ready.
pause
