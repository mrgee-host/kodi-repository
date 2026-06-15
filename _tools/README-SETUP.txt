MRGEE KODI REPOSITORY PACK
==========================

Target GitHub repo:
  https://github.com/mrgee-host/kodi-repository

Target local folder:
  D:\Others\KodiRepo\

GitHub Pages URL used by Kodi:
  https://mrgee-host.github.io/kodi-repository/

WHAT IS INCLUDED
----------------
- repository.mrgee.kodi Kodi repository add-on zip
- addons.xml + addons.xml.md5 initial repo index
- Build-Repo.ps1 / Build-Repo.bat
- Upload-Repo.ps1
- Build-And-Upload-Repo.ps1 / .bat
- repo-addons.txt list of add-ons to publish

IMPORTANT
---------
This pack does NOT include fake copies of your add-ons.
Build-Repo.ps1 will package the latest add-on folders installed on your PC from:
  E:\Kodi\portable_data\addons
  E:\Kodi\addons
  %APPDATA%\Kodi\addons

This avoids accidentally publishing dummy/old add-ons.

HOW TO USE
----------
1. Extract the contents of this zip into:
     D:\Others\KodiRepo\

2. Make sure your GitHub repo files are in that same folder.
   If the folder is empty/new:
     git clone https://github.com/mrgee-host/kodi-repository.git D:\Others\KodiRepo
   then copy this pack contents into that folder.

3. Enable GitHub Pages in GitHub:
     Settings > Pages > Deploy from a branch > main > / root > Save

4. Run:
     D:\Others\KodiRepo\_tools\Build-Repo.bat

5. Then upload:
     D:\Others\KodiRepo\_tools\Upload-Repo.ps1
   or just run:
     D:\Others\KodiRepo\_tools\Build-And-Upload-Repo.bat

6. In Kodi, install this zip once:
     D:\Others\KodiRepo\repository.mrgee.kodi\repository.mrgee.kodi-1.0.0.zip

7. After that, updates come from:
     https://mrgee-host.github.io/kodi-repository/addons.xml

DEFAULT ADD-ONS IN repo-addons.txt
----------------------------------
script.artwork.curator
script.library.ratings.scraper
context.tpdb.artwork
script.akl.texture.cache.cleaner
plugin.program.steam.collections

If plugin.program.steam.collections is not installed yet, the builder will skip it safely.

IMPORTANT VERSION NOTE
----------------------
The add-on versions are NOT hardcoded in this repository pack.
Build-Repo.ps1 reads the real version from each installed add-on's addon.xml.
So if Library Ratings Scraper was rolled back from 1.4.0 and then updated again,
the repo will publish whatever version is currently installed in your Kodi add-ons folder.

Before building, run this from the repository root:

    CHECK-INSTALLED-ADDONS.bat

It will create installed-addons-report.txt and show the exact versions found.

