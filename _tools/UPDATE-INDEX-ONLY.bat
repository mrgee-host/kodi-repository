@echo off
setlocal EnableExtensions

REM ============================================================
REM Regenerate addons.xml, addons.xml.md5, and index.html only.
REM Location expected: <repo-root>\_tools\UPDATE-INDEX-ONLY.bat
REM ============================================================

set "TOOL_DIR=%~dp0"
for %%I in ("%TOOL_DIR%..") do set "REPO_ROOT=%%~fI"

echo.
echo ============================================================
echo Updating repository index only
echo ============================================================

powershell -NoProfile -ExecutionPolicy Bypass -File "%TOOL_DIR%Update-Repo-Index.ps1" -RepoRoot "%REPO_ROOT%"
if errorlevel 1 (
    echo.
    echo Update index failed.
    pause
    exit /b 1
)

echo.
echo Done.
pause
