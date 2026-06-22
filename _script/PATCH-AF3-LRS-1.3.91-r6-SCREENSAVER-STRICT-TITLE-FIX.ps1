$ErrorActionPreference = "Stop"
$DefaultSkin1080i = "E:\Kodi\portable_data\addons\skin.arctic.fuse.3\1080i"
$Skin1080i = $DefaultSkin1080i
function Read-Text($Path) { return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8) }
function Write-Text($Path, $Text) { [System.IO.File]::WriteAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false)) }
function Count-Literal($Text, $Needle) { return ([regex]::Matches($Text, [regex]::Escape($Needle))).Count }
$OldTitleVisible = '<visible>String.IsEmpty(Window(Home).Property(LibraryRatings.Screensaver.ClearLogoFinal)) | !String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.ClearLogoFinalTitle),Container(1297).ListItem.Title)</visible>'
$NewTitleVisible = '<visible>String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.ClearLogoFinalMode),title) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.ClearLogoFinalTitle),Container(1297).ListItem.Title)</visible>'
$OldRatingVisible = '<visible>String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.HasData),true)</visible>'
$OldRatingVisible2 = '<visible>String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.HasData),true) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.Title),Container(1297).ListItem.Title)</visible>'
$NewRatingVisible = '<visible>String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.HasData),true) + String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.ClearLogoFinalTitle),Container(1297).ListItem.Title)</visible>'
function Patch-ScreensaverStrictTitle {
    $path = Join-Path $Skin1080i 'screensaver-arctic-mirage.xml'
    if (!(Test-Path $path)) { throw "File tidak ketemu: $path" }
    $backup = "$path.lrs-1.3.91-r6-before"
    if (!(Test-Path $backup)) {
        Copy-Item -LiteralPath $path -Destination $backup -Force
        Write-Host "[OK] Backup dibuat: $backup"
    } else {
        Write-Host "[INFO] Backup sudah ada: $backup"
    }
    $t = Read-Text $path
    $beforeOldTitle = Count-Literal $t $OldTitleVisible
    $beforeNewTitle = Count-Literal $t $NewTitleVisible
    $beforeOldRating = Count-Literal $t $OldRatingVisible
    $beforeNewRating = Count-Literal $t $NewRatingVisible
    $t = $t.Replace($OldTitleVisible, $NewTitleVisible)
    $t = $t.Replace($OldRatingVisible2, $NewRatingVisible)
    $t = $t.Replace($OldRatingVisible, $NewRatingVisible)
    [xml]$null = $t
    $finalBlocks = ([regex]::Matches($t, 'AFM-CLEARLOGO-FINAL-LRS-START-1\.3\.91-r5')).Count
    $strictTitles = Count-Literal $t $NewTitleVisible
    $ratingGuards = Count-Literal $t $NewRatingVisible
    $oldTitlesLeft = Count-Literal $t $OldTitleVisible
    $directDefault = ($t -match 'Container\(1297\)\.ListItem\.Art\(clearlogo\)')
    if ($finalBlocks -lt 2 -or $strictTitles -lt 2 -or $ratingGuards -lt 2 -or $oldTitlesLeft -ne 0 -or $directDefault) {
        throw "Validasi gagal: finalBlocks=$finalBlocks strictTitles=$strictTitles ratingGuards=$ratingGuards oldTitlesLeft=$oldTitlesLeft directDefault=$directDefault. Tidak menulis file."
    }
    Write-Text $path $t
    Write-Host "[OK] screensaver r6 patched: title fallback strict + rating title guard"
    Write-Host "     title old->strict : $beforeOldTitle old, $beforeNewTitle strict sebelum patch"
    Write-Host "     rating guard      : $beforeOldRating plain, $beforeNewRating guarded sebelum patch"
}
function Restore-ScreensaverStrictTitle {
    $path = Join-Path $Skin1080i 'screensaver-arctic-mirage.xml'
    $backup = "$path.lrs-1.3.91-r6-before"
    if (Test-Path $backup) {
        Copy-Item -LiteralPath $backup -Destination $path -Force
        Write-Host "[OK] Restore dari backup r6: $backup"
    } else {
        Write-Host "[WARN] Backup r6 tidak ada: $backup"
    }
}
function Check-Status {
    $path = Join-Path $Skin1080i 'screensaver-arctic-mirage.xml'
    if (!(Test-Path $path)) { throw "File tidak ketemu: $path" }
    $t = Read-Text $path
    $finalBlocks = ([regex]::Matches($t, 'AFM-CLEARLOGO-FINAL-LRS-START-1\.3\.91-r5')).Count
    $strictTitles = Count-Literal $t $NewTitleVisible
    $oldTitles = Count-Literal $t $OldTitleVisible
    $ratingGuards = Count-Literal $t $NewRatingVisible
    $plainRating = Count-Literal $t $OldRatingVisible
    $lrsRows = ([regex]::Matches($t, 'LRS-AF3-SCREENSAVER-AF3-ROW-START')).Count
    $vignette = ([regex]::Matches($t, 'vignette\.png')).Count
    $odd = ([regex]::Matches($t, 'Integer\.IsOdd\(ListItem\.CurrentItem\)')).Count
    $directDefault = ($t -match 'Container\(1297\)\.ListItem\.Art\(clearlogo\)')
    $modeProp = ($t -match 'LibraryRatings\.Screensaver\.ClearLogoFinalMode')
    Write-Host "`nSTATUS"
    Write-Host "  Skin path                  : $Skin1080i"
    Write-Host "  Final clearlogo blocks     : $finalBlocks"
    Write-Host "  Strict title fallback      : $(if($strictTitles -ge 2 -and $oldTitles -eq 0 -and $modeProp){'YES'}else{'NO'}) ($strictTitles)"
    Write-Host "  Old mismatch title left    : $oldTitles"
    Write-Host "  Rating title guard         : $(if($ratingGuards -ge 2 -and $plainRating -eq 0){'YES'}else{'NO'}) ($ratingGuards)"
    Write-Host "  Plain rating visible left  : $plainRating"
    Write-Host "  LRS screensaver rows       : $lrsRows"
    Write-Host "  AF3 vignette preserved     : $(if($vignette -ge 2){'YES'}else{'NO'}) ($vignette)"
    Write-Host "  AF3 odd/even preserved     : $(if($odd -ge 4){'YES'}else{'NO'}) ($odd)"
    Write-Host "  Direct default clearlogo   : $(if($directDefault){'YES'}else{'NO'})"
    Write-Host "  RESULT                     : $(if($finalBlocks -ge 2 -and $strictTitles -ge 2 -and $oldTitles -eq 0 -and $ratingGuards -ge 2 -and $plainRating -eq 0 -and $lrsRows -ge 2 -and $vignette -ge 2 -and $odd -ge 4 -and -not $directDefault){'OK'}else{'CHECK'})"
}
while ($true) {
    Clear-Host
    Write-Host 'AF3 LRS 1.3.91 r6 - Screensaver strict title transition fix'
    Write-Host '============================================================'
    Write-Host "Skin 1080i: $Skin1080i"
    Write-Host '1. Patch screensaver strict title fallback + rating guard'
    Write-Host '2. Restore r6 backup'
    Write-Host '3. Check status'
    Write-Host '4. Change skin 1080i path'
    Write-Host '5. Exit'
    $c = Read-Host 'Pilih [1-5]'
    try {
        switch ($c) {
            '1' { Patch-ScreensaverStrictTitle }
            '2' { Restore-ScreensaverStrictTitle }
            '3' { Check-Status }
            '4' { $new = Read-Host 'Masukkan full path folder 1080i'; if ($new.Trim()) { $Skin1080i = $new.Trim() } }
            '5' { break }
            default { Write-Host 'Pilihan tidak dikenal' }
        }
    } catch { Write-Host "[ERROR] $($_.Exception.Message)" }
    Write-Host ''
    Read-Host 'Tekan Enter untuk kembali ke menu'
}
