@echo off
setlocal
cd /d "%~dp0"
echo.
echo AF3 One Visit One Fanart Patch v2.3 - Portable E
echo Target: E:\Kodi\portable_data\addons
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0apply_one_visit_one_fanart_v2_3_windows.ps1" -AddonsDir "E:\Kodi\portable_data\addons"
echo.
pause
