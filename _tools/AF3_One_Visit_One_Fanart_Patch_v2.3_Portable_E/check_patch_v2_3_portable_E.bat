@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0apply_one_visit_one_fanart_v2_3_windows.ps1" -AddonsDir "E:\Kodi\portable_data\addons" -Check
echo.
pause
