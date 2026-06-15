@echo off
echo Clearing Kodi cached packages for custom addons...
del /q "E:\Kodi\portable_data\addons\packages\script.library.ratings.scraper-*.zip" 2>nul
del /q "E:\Kodi\portable_data\addons\packages\context.tpdb.artwork-*.zip" 2>nul
del /q "E:\Kodi\portable_data\addons\packages\script.artwork.curator-*.zip" 2>nul
del /q "E:\Kodi\portable_data\addons\packages\script.akl.texture.cache.cleaner-*.zip" 2>nul
del /q "E:\Kodi\portable_data\addons\packages\repository.mrgee.kodi-*.zip" 2>nul
echo Done.
pause
