@echo off
setlocal EnableExtensions

REM ============================================================
REM Drag one or more Kodi add-on ZIP files onto this BAT.
REM Location expected: <repo-root>\_tools\DRAG-ZIP-UPDATE-REPO.bat
REM Action: import ZIP(s), update addons.xml, then git commit/push.
REM ============================================================

set "TOOL_DIR=%~dp0"
for %%I in ("%TOOL_DIR%..") do set "REPO_ROOT=%%~fI"

if "%~1"=="" (
    echo Drag add-on zip file^(s^) onto this BAT.
    echo.
    echo Example:
    echo   script.library.ratings.scraper-1.3.10.zip
    echo.
    pause
    exit /b 1
)

:IMPORT_LOOP
if "%~1"=="" goto UPLOAD

echo.
echo ============================================================
echo Importing: %~nx1
echo ============================================================

powershell -NoProfile -ExecutionPolicy Bypass -File "%TOOL_DIR%Import-Addon-Zip.ps1" -RepoRoot "%REPO_ROOT%" -ZipPath "%~1"
if errorlevel 1 (
    echo.
    echo Import failed. Upload skipped.
    pause
    exit /b 1
)

shift
goto IMPORT_LOOP

:UPLOAD
echo.
echo ============================================================
echo Uploading repository to GitHub
echo ============================================================

powershell -NoProfile -ExecutionPolicy Bypass -File "%TOOL_DIR%Upload-Repo.ps1" -RepoRoot "%REPO_ROOT%"
if errorlevel 1 (
    echo.
    echo Upload failed.
    pause
    exit /b 1
)

echo.
echo Done. Kodi can now Check for updates.
pause
