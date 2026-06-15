MrGee Kodi Repository - clean drag-zip flow

Installed repo folder:
D:\Others\KodiRepo\kodi-repository

Main flow:
1. Download addon zip from ChatGPT.
2. Drag it to:
   _tools\DRAG-ZIP-UPDATE-REPO.bat
3. Kodi: Check for updates.

All BAT files are inside _tools. No _incoming_addons folder is used.

If Kodi says UPDATE FAILED / invalid package:
1. Run _tools\CLEAR-KODI-PACKAGES-CACHE.bat
2. Re-drag the original addon zip from ChatGPT to _tools\DRAG-ZIP-UPDATE-REPO.bat
3. In Kodi, Check for updates again.

Important:
The importer normalizes every addon zip so Kodi receives:
addon.id-version.zip
  addon.idddon.xml
