@echo off
setlocal
cd /d "%~dp0"

echo ============================================================
echo Skin Helper Widgets - Random Movies + TV Shows patch
echo ============================================================
echo.
echo 1. Patch
echo 2. Restore
echo 3. Exit
echo.
set /p choice=Choose [1/2/3]: 
if "%choice%"=="1" goto patch
if "%choice%"=="2" goto restore
goto end

:patch
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0PATCH-SKIN-HELPER-RANDOM-MOVIES-TVSHOWS.ps1" -Action patch
pause
goto end

:restore
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0PATCH-SKIN-HELPER-RANDOM-MOVIES-TVSHOWS.ps1" -Action restore
pause
goto end

:end
endlocal
