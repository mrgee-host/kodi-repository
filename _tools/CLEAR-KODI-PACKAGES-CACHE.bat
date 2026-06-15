@echo off
setlocal
echo This deletes cached downloaded addon zips from Kodi packages cache.
echo It does NOT delete installed addons.
echo.

set "PKG=E:\Kodi\portable_data\addons\packages"
if exist "%PKG%" (
  del /q "%PKG%\script.library.ratings.scraper-*.zip" 2>nul
  del /q "%PKG%\context.tpdb.artwork-*.zip" 2>nul
  del /q "%PKG%\script.artwork.curator-*.zip" 2>nul
  del /q "%PKG%\script.akl.texture.cache.cleaner-*.zip" 2>nul
  del /q "%PKG%\repository.mrgee.kodi-*.zip" 2>nul
  echo Cleared: %PKG%
) else (
  echo Packages folder not found: %PKG%
)
echo.
pause
