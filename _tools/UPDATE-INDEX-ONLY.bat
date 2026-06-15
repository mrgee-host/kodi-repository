@echo off
setlocal EnableExtensions DisableDelayedExpansion
set "TOOLDIR=%~dp0"
for %%I in ("%TOOLDIR%..") do set "REPOROOT=%%~fI"
powershell -NoProfile -ExecutionPolicy Bypass -File "%TOOLDIR%Update-Repo-Index.ps1" -RepoRoot "%REPOROOT%"
echo.
pause
