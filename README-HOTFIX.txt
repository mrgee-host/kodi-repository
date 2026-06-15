Hotfix drag upload v2
=====================

Masalah:
DRAG-ZIP-UPDATE-REPO.bat mencari _tools di folder download/extract sementara, misalnya:
D:\Libraries\Downloads\Compressed\_tools\Upload-Repo.ps1

Perbaikan:
BAT sekarang selalu pakai repo root tetap:
D:\Others\KodiRepo\kodi-repository

Cara pakai:
1. Copy/timpa 3 BAT ini ke:
   D:\Others\KodiRepo\kodi-repository\

2. Jalankan/drag zip ke BAT yang ada di folder repo itu:
   D:\Others\KodiRepo\kodi-repository\DRAG-ZIP-UPDATE-REPO.bat

3. Kalau import sudah sukses tapi upload tadi gagal, cukup jalankan:
   D:\Others\KodiRepo\kodi-repository\UPLOAD-ONLY.bat
