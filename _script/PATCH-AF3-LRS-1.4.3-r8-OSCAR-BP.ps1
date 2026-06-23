$ErrorActionPreference = "Stop"
$DefaultSkin1080i = "E:\Kodi\portable_data\addons\skin.arctic.fuse.3\1080i"
$Skin1080i = $DefaultSkin1080i
$PatchVersion = "1.4.3-r8-oscar-bp"

function Read-Text($Path) {
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}
function Write-Text($Path, $Text) {
    [System.IO.File]::WriteAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false))
}
function Backup-Once($Path) {
    $b = "$Path.lrs-143-r8-before"
    if ((Test-Path -LiteralPath $Path) -and !(Test-Path -LiteralPath $b)) {
        Copy-Item -LiteralPath $Path -Destination $b -Force
        Write-Host "[BACKUP] $b"
    }
}
function Replace-InBlock($Text, $StartMarker, $EndMarker, $Old, $New) {
    $start = $Text.IndexOf($StartMarker)
    if ($start -lt 0) { return @{ Text=$Text; Changed=$false; Reason="start marker not found" } }
    $end = $Text.IndexOf($EndMarker, $start)
    if ($end -lt 0) { return @{ Text=$Text; Changed=$false; Reason="end marker not found" } }
    $end2 = $end + $EndMarker.Length
    $before = $Text.Substring(0, $start)
    $block = $Text.Substring($start, $end2 - $start)
    $after = $Text.Substring($end2)
    $newBlock = $block.Replace($Old, $New)
    return @{ Text=($before + $newBlock + $after); Changed=($newBlock -ne $block); Reason="ok" }
}

$InfoOldOscar = 'flags/$VAR[Color_Directory]/ratings/oscars.png'
$InfoNewOscar = 'flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.Oscar_Icon)]'
$ScreenOldOscar = 'flags/$VAR[Color_Directory]/ratings/oscars.png'
$ScreenNewOscar = 'flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.Oscar_Icon)]'

function Patch-IncludesInfoOscarBP {
    $path = Join-Path $Skin1080i "Includes_Info.xml"
    if (!(Test-Path -LiteralPath $path)) { throw "Includes_Info.xml tidak ditemukan: $path" }
    Backup-Once $path
    $t = Read-Text $path
    if ($t.Contains($InfoNewOscar)) {
        Write-Host "[SKIP] Includes_Info.xml sudah pakai Oscar_Icon property."
        return
    }
    $res = Replace-InBlock $t '<!-- LRS-AF3-INCLUDE-DEF-START -->' '<!-- LRS-AF3-INCLUDE-DEF-END -->' $InfoOldOscar $InfoNewOscar
    if (-not $res.Changed) {
        if ($res.Reason -ne "ok") {
            Write-Host "[WARN] LRS include marker tidak lengkap di Includes_Info.xml: $($res.Reason)"
        }
        if ($t.Contains($InfoOldOscar)) {
            $res.Text = $t.Replace($InfoOldOscar, $InfoNewOscar)
            $res.Changed = $true
            Write-Host "[WARN] Fallback replace global dipakai untuk Includes_Info.xml."
        }
    }
    if ($res.Changed) {
        Write-Text $path $res.Text
        Write-Host "[OK] Includes_Info.xml patched: oscars.png -> ListItem.Oscar_Icon"
    } else {
        Write-Host "[WARN] Tidak ada oscars.png LRS yang bisa diganti di Includes_Info.xml. Pastikan patch r7 sudah terpasang."
    }
}

function Patch-ScreensaverOscarBP {
    $path = Join-Path $Skin1080i "screensaver-arctic-mirage.xml"
    if (!(Test-Path -LiteralPath $path)) { throw "screensaver-arctic-mirage.xml tidak ditemukan: $path" }
    Backup-Once $path
    $t = Read-Text $path
    if ($t.Contains($ScreenNewOscar)) {
        Write-Host "[SKIP] screensaver-arctic-mirage.xml sudah pakai Screensaver.Oscar_Icon property."
        return
    }
    $res = Replace-InBlock $t '<!-- LRS-AF3-SCREENSAVER-AF3-ROW-START-1.3.87 -->' '<!-- LRS-AF3-SCREENSAVER-AF3-ROW-END-1.3.87 -->' $ScreenOldOscar $ScreenNewOscar
    if (-not $res.Changed) {
        if ($res.Reason -ne "ok") {
            Write-Host "[WARN] LRS screensaver marker tidak lengkap: $($res.Reason)"
        }
        if ($t.Contains($ScreenOldOscar)) {
            $res.Text = $t.Replace($ScreenOldOscar, $ScreenNewOscar)
            $res.Changed = $true
            Write-Host "[WARN] Fallback replace global dipakai untuk screensaver-arctic-mirage.xml."
        }
    }
    if ($res.Changed) {
        Write-Text $path $res.Text
        Write-Host "[OK] screensaver-arctic-mirage.xml patched: oscars.png -> Screensaver.Oscar_Icon"
    } else {
        Write-Host "[WARN] Tidak ada oscars.png LRS yang bisa diganti di screensaver-arctic-mirage.xml."
    }
}

function Restore-OscarBPXmlOnly {
    $info = Join-Path $Skin1080i "Includes_Info.xml"
    $ss = Join-Path $Skin1080i "screensaver-arctic-mirage.xml"
    if (Test-Path -LiteralPath $info) {
        Backup-Once $info
        $t = Read-Text $info
        $n = $t.Replace($InfoNewOscar, $InfoOldOscar)
        if ($n -ne $t) { Write-Text $info $n; Write-Host "[OK] Includes_Info.xml restored to oscars.png." } else { Write-Host "[SKIP] Includes_Info.xml tidak memakai dynamic Oscar_Icon." }
    }
    if (Test-Path -LiteralPath $ss) {
        Backup-Once $ss
        $t = Read-Text $ss
        $n = $t.Replace($ScreenNewOscar, $ScreenOldOscar)
        if ($n -ne $t) { Write-Text $ss $n; Write-Host "[OK] screensaver-arctic-mirage.xml restored to oscars.png." } else { Write-Host "[SKIP] screensaver-arctic-mirage.xml tidak memakai dynamic Oscar_Icon." }
    }
}

function Check-IconFiles {
    $skinRoot = Split-Path $Skin1080i -Parent
    $bp = @(Get-ChildItem -LiteralPath $skinRoot -Recurse -Filter "oscar_bp.png" -ErrorAction SilentlyContinue)
    $osc = @(Get-ChildItem -LiteralPath $skinRoot -Recurse -Filter "oscars.png" -ErrorAction SilentlyContinue)
    Write-Host ""
    Write-Host "Icon files:"
    Write-Host "  oscars.png   : $($osc.Count) found"
    Write-Host "  oscar_bp.png : $($bp.Count) found"
    if ($bp.Count -eq 0) {
        Write-Host "[WARN] oscar_bp.png belum ditemukan di skin. Letakkan oscar_bp.png di folder ratings yang aktif, misalnya:"
        Write-Host "       E:\Kodi\portable_data\addons\skin.arctic.fuse.3\media\flags\<color>\ratings\oscar_bp.png"
    }
}

function Check-Status {
    $info = Join-Path $Skin1080i "Includes_Info.xml"
    $ss = Join-Path $Skin1080i "screensaver-arctic-mirage.xml"
    Write-Host ""
    Write-Host "============================================================"
    Write-Host "AF3 LRS Oscar Best Picture XML status ($PatchVersion)"
    Write-Host "============================================================"
    if (Test-Path -LiteralPath $info) {
        $t = Read-Text $info
        Write-Host "  Includes_Info dynamic Oscar icon : $(if($t.Contains($InfoNewOscar)){'YES'}else{'NO'})"
        Write-Host "  Includes_Info old oscars hardcode: $(if($t.Contains($InfoOldOscar)){'YES'}else{'NO'})"
    } else { Write-Host "  Includes_Info.xml: NOT FOUND" }
    if (Test-Path -LiteralPath $ss) {
        $t = Read-Text $ss
        Write-Host "  Screensaver dynamic Oscar icon   : $(if($t.Contains($ScreenNewOscar)){'YES'}else{'NO'})"
        Write-Host "  Screensaver old oscars hardcode  : $(if($t.Contains($ScreenOldOscar)){'YES'}else{'NO'})"
    } else { Write-Host "  screensaver-arctic-mirage.xml: NOT FOUND" }
    Check-IconFiles
}

function Patch-All {
    Patch-IncludesInfoOscarBP
    Patch-ScreensaverOscarBP
    Check-Status
}

Write-Host "============================================================"
Write-Host "AF3 + LRS 1.4.3 Oscar Best Picture XML Patch ($PatchVersion)"
Write-Host "============================================================"
Write-Host "Skin 1080i path:"
Write-Host "  $Skin1080i"
Write-Host ""
Write-Host "Pilih aksi:"
Write-Host "  1. Patch Oscar Best Picture icon property"
Write-Host "  2. Restore Oscar icon hardcode only"
Write-Host "  3. Check status"
Write-Host "  4. Exit"
$choice = Read-Host "Masukkan pilihan [1/2/3/4]"
try {
    switch ($choice) {
        '1' { Patch-All }
        '2' { Restore-OscarBPXmlOnly; Check-Status }
        '3' { Check-Status }
        default { Write-Host "Exit." }
    }
} catch {
    Write-Host ""
    Write-Host "[ERROR] $($_.Exception.Message)"
    Write-Host "Tidak ada file yang ditimpa jika error terjadi sebelum tahap penulisan."
    exit 1
}
