@echo off
setlocal
cd /d "%~dp0"
echo Running AF3 + LRS 1.3.82 patcher with PowerShell (no Python needed)...
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0PATCH-AF3-LRS-1.3.82-FIX.ps1"
if errorlevel 1 (
  echo.
  echo PowerShell failed. Right-click this BAT and choose Run as administrator only if your Kodi folder needs admin rights.
  pause
)
