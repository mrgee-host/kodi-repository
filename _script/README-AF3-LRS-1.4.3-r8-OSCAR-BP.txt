AF3 + LRS 1.4.3 r8 Oscar Best Picture XML Patch

Fungsi:
- Mengubah icon Oscar di row LRS AF3 dari hardcode oscars.png menjadi property addon:
  - ListItem: LibraryRatings.ListItem.Oscar_Icon
  - Screensaver: LibraryRatings.Screensaver.Oscar_Icon
- Jika addon LRS mengirim Oscar_Icon=oscar_bp.png, skin akan memakai oscar_bp.png.
- Jika addon LRS mengirim Oscar_Icon=oscar.png, skin akan memakai oscar.png.

Cara pakai:
1. Pastikan patch AF3 LRS r7 sebelumnya sudah terpasang.
2. Jalankan PATCH-AF3-LRS-1.4.3-r8-OSCAR-BP.bat.
3. Pilih 1 untuk patch.
4. Reload skin / restart Kodi.

Catatan icon:
- File oscar_bp.png harus ada di folder ratings skin yang aktif:
  E:\Kodi\portable_data\addons\skin.arctic.fuse.3\media\flags\<color>\ratings\oscar_bp.png
- Jika file belum ada, XML sudah benar tapi icon Best Picture tidak akan muncul.

Restore:
- Pilih 2 untuk mengembalikan XML ke hardcode oscars.png saja.
