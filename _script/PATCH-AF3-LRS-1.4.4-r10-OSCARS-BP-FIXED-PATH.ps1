$ErrorActionPreference = "Stop"
$DefaultSkin1080i = "E:\Kodi\portable_data\addons\skin.arctic.fuse.3\1080i"
$Skin1080i = $DefaultSkin1080i
$PatchVersion = "1.4.4-r10-oscars-bp-fixed-path"

function Read-Text($Path) {
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}
function Write-Text($Path, $Text) {
    [System.IO.File]::WriteAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false))
}
function Backup-Once($Path) {
    $b = "$Path.lrs-144-r10-before"
    if ((Test-Path -LiteralPath $Path) -and !(Test-Path -LiteralPath $b)) {
        Copy-Item -LiteralPath $Path -Destination $b -Force
        Write-Host "[BACKUP] $b"
    }
}
function Replace-InBlockMany($Text, $StartMarker, $EndMarker, $Pairs) {
    $start = $Text.IndexOf($StartMarker)
    if ($start -lt 0) { return @{ Text=$Text; Changed=$false; Reason="start marker not found" } }
    $end = $Text.IndexOf($EndMarker, $start)
    if ($end -lt 0) { return @{ Text=$Text; Changed=$false; Reason="end marker not found" } }
    $end2 = $end + $EndMarker.Length
    $before = $Text.Substring(0, $start)
    $block = $Text.Substring($start, $end2 - $start)
    $after = $Text.Substring($end2)
    $newBlock = $block
    foreach ($p in $Pairs) { $newBlock = $newBlock.Replace($p.Old, $p.New) }
    return @{ Text=($before + $newBlock + $after); Changed=($newBlock -ne $block); Reason="ok" }
}

$OldOscarPath = 'flags/$VAR[Color_Directory]/ratings/oscars.png'
$BestPicturePath = 'flags/$VAR[Color_Directory]/ratings/oscars_bp.png'
$BadListDynamic = 'flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.ListItem.Oscar_Icon)]'
$BadScreenDynamic = 'flags/$VAR[Color_Directory]/ratings/$INFO[Window(Home).Property(LibraryRatings.Screensaver.Oscar_Icon)]'
$ListVar = '$VAR[LRS_ListItem_Oscar_Icon_Texture]'
$ScreenVar = '$VAR[LRS_Screensaver_Oscar_Icon_Texture]'
$VarStart = '<!-- LRS-OSCAR-BP-VARS-START -->'
$VarEnd = '<!-- LRS-OSCAR-BP-VARS-END -->'

$VariableBlock = @"
$VarStart
    <variable name="LRS_ListItem_Oscar_Icon_Texture">
        <value condition="String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.Oscar_BestPicture),true)">$BestPicturePath</value>
        <value condition="String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.OscarBestPicture),true)">$BestPicturePath</value>
        <value condition="String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.Oscar_BestPicture),1)">$BestPicturePath</value>
        <value condition="String.IsEqual(Window(Home).Property(LibraryRatings.ListItem.OscarBestPicture),1)">$BestPicturePath</value>
        <value>$OldOscarPath</value>
    </variable>
    <variable name="LRS_Screensaver_Oscar_Icon_Texture">
        <value condition="String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.Oscar_BestPicture),true)">$BestPicturePath</value>
        <value condition="String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.OscarBestPicture),true)">$BestPicturePath</value>
        <value condition="String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.Oscar_BestPicture),1)">$BestPicturePath</value>
        <value condition="String.IsEqual(Window(Home).Property(LibraryRatings.Screensaver.OscarBestPicture),1)">$BestPicturePath</value>
        <value>$OldOscarPath</value>
    </variable>
$VarEnd
"@

function Ensure-OscarVariables($Text) {
    $s = $Text.IndexOf($VarStart)
    if ($s -ge 0) {
        $e = $Text.IndexOf($VarEnd, $s)
        if ($e -lt 0) { throw "Marker $VarStart ada, tapi $VarEnd tidak ditemukan." }
        $e2 = $e + $VarEnd.Length
        $new = $Text.Substring(0, $s) + $VariableBlock + $Text.Substring($e2)
        return @{ Text=$new; Changed=($new -ne $Text); Mode="updated" }
    }
    $inc = $Text.IndexOf('<includes>')
    if ($inc -lt 0) { throw "Tag <includes> tidak ditemukan di Includes_Info.xml. Tidak bisa inject variable." }
    $pos = $inc + '<includes>'.Length
    $new = $Text.Substring(0, $pos) + "`r`n" + $VariableBlock + $Text.Substring($pos)
    return @{ Text=$new; Changed=$true; Mode="inserted" }
}

function Patch-IncludesInfoFixedPath {
    $path = Join-Path $Skin1080i "Includes_Info.xml"
    if (!(Test-Path -LiteralPath $path)) { throw "Includes_Info.xml tidak ditemukan: $path" }
    Backup-Once $path
    $t = Read-Text $path
    $orig = $t

    $var = Ensure-OscarVariables $t
    $t = $var.Text
    if ($var.Changed) { Write-Host "[OK] Includes_Info.xml Oscar BP variables $($var.Mode)." }

    $pairs = @(
        @{ Old=$BadListDynamic; New=$ListVar },
        @{ Old=$OldOscarPath; New=$ListVar }
    )
    # Jangan ubah icon path di dalam variable block sendiri.
    $withoutVars = $t
    $vs = $withoutVars.IndexOf($VarStart)
    $ve = if ($vs -ge 0) { $withoutVars.IndexOf($VarEnd, $vs) } else { -1 }
    $varBlockText = $null
    if ($vs -ge 0 -and $ve -ge 0) {
        $ve2 = $ve + $VarEnd.Length
        $varBlockText = $withoutVars.Substring($vs, $ve2 - $vs)
        $placeholder = "__LRS_OSCAR_BP_VAR_BLOCK_PLACEHOLDER__"
        $withoutVars = $withoutVars.Substring(0, $vs) + $placeholder + $withoutVars.Substring($ve2)
    }

    $res = Replace-InBlockMany $withoutVars '<!-- LRS-AF3-INCLUDE-DEF-START -->' '<!-- LRS-AF3-INCLUDE-DEF-END -->' $pairs
    if (-not $res.Changed) {
        if ($res.Reason -ne "ok") { Write-Host "[WARN] LRS include marker tidak lengkap di Includes_Info.xml: $($res.Reason)" }
        if ($withoutVars.Contains($BadListDynamic)) {
            $res.Text = $withoutVars.Replace($BadListDynamic, $ListVar)
            $res.Changed = $true
            Write-Host "[WARN] Fallback replace dynamic ListItem texture dipakai untuk Includes_Info.xml."
        }
    }
    $withoutVars = $res.Text
    if ($varBlockText -ne $null) { $t = $withoutVars.Replace($placeholder, $varBlockText) } else { $t = $withoutVars }

    if ($t -ne $orig) {
        Write-Text $path $t
        Write-Host "[OK] Includes_Info.xml patched: Oscar texture -> $ListVar"
    } else {
        Write-Host "[SKIP] Includes_Info.xml tidak berubah."
    }
}

function Patch-ScreensaverFixedPath {
    $path = Join-Path $Skin1080i "screensaver-arctic-mirage.xml"
    if (!(Test-Path -LiteralPath $path)) { throw "screensaver-arctic-mirage.xml tidak ditemukan: $path" }
    Backup-Once $path
    $t = Read-Text $path
    $orig = $t
    $pairs = @(
        @{ Old=$BadScreenDynamic; New=$ScreenVar },
        @{ Old=$OldOscarPath; New=$ScreenVar }
    )
    $res = Replace-InBlockMany $t '<!-- LRS-AF3-SCREENSAVER-AF3-ROW-START-1.3.87 -->' '<!-- LRS-AF3-SCREENSAVER-AF3-ROW-END-1.3.87 -->' $pairs
    if (-not $res.Changed) {
        if ($res.Reason -ne "ok") { Write-Host "[WARN] LRS screensaver marker tidak lengkap: $($res.Reason)" }
        if ($t.Contains($BadScreenDynamic)) {
            $res.Text = $t.Replace($BadScreenDynamic, $ScreenVar)
            $res.Changed = $true
            Write-Host "[WARN] Fallback replace dynamic Screensaver texture dipakai."
        }
    }
    if ($res.Changed) {
        Write-Text $path $res.Text
        Write-Host "[OK] screensaver-arctic-mirage.xml patched: Oscar texture -> $ScreenVar"
    } else {
        Write-Host "[SKIP] screensaver-arctic-mirage.xml tidak berubah."
    }
}

function Restore-R9-DynamicOnlyToHardcode {
    $info = Join-Path $Skin1080i "Includes_Info.xml"
    $ss = Join-Path $Skin1080i "screensaver-arctic-mirage.xml"
    foreach ($path in @($info,$ss)) {
        if (!(Test-Path -LiteralPath $path)) { continue }
        Backup-Once $path
        $t = Read-Text $path
        $orig = $t
        $t = $t.Replace($ListVar, $OldOscarPath).Replace($ScreenVar, $OldOscarPath)
        $t = $t.Replace($BadListDynamic, $OldOscarPath).Replace($BadScreenDynamic, $OldOscarPath)
        $s = $t.IndexOf($VarStart)
        if ($s -ge 0) {
            $e = $t.IndexOf($VarEnd, $s)
            if ($e -ge 0) {
                $e2 = $e + $VarEnd.Length
                $t = $t.Substring(0,$s) + $t.Substring($e2)
            }
        }
        if ($t -ne $orig) { Write-Text $path $t; Write-Host "[OK] Restored hardcode oscars.png in $([IO.Path]::GetFileName($path))" } else { Write-Host "[SKIP] Tidak ada patch r10/r9 di $([IO.Path]::GetFileName($path))" }
    }
}

function Find-IconFiles($Name) {
    $skinRoot = Split-Path $Skin1080i -Parent
    return @(Get-ChildItem -LiteralPath $skinRoot -Recurse -Filter $Name -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName)
}
function Print-Icon($Name) {
    $files = Find-IconFiles $Name
    Write-Host "  $Name : $($files.Count) found"
    foreach ($f in ($files | Select-Object -First 6)) { Write-Host "    - $f" }
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
        Write-Host "  Includes_Info has BP variables       : $(if($t.Contains($VarStart)){'YES'}else{'NO'})"
        Write-Host "  Includes_Info uses ListItem variable : $(if($t.Contains($ListVar)){'YES'}else{'NO'})"
        Write-Host "  BAD ListItem dynamic `$INFO texture  : $(if($t.Contains($BadListDynamic)){'YES'}else{'NO'})"
    } else { Write-Host "  Includes_Info.xml: NOT FOUND" }
    if (Test-Path -LiteralPath $ss) {
        $t = Read-Text $ss
        Write-Host "  Screensaver uses variable            : $(if($t.Contains($ScreenVar)){'YES'}else{'NO'})"
        Write-Host "  BAD Screensaver dynamic `$INFO texture: $(if($t.Contains($BadScreenDynamic)){'YES'}else{'NO'})"
    } else { Write-Host "  screensaver-arctic-mirage.xml: NOT FOUND" }
    Write-Host ""
    Write-Host "Expected paths used by variables:"
    Write-Host "  Normal Oscar      : $OldOscarPath"
    Write-Host "  Best Picture Oscar: $BestPicturePath"
    Write-Host ""
    Write-Host "Important icon files in skin:"
    foreach ($n in @('imdb.png','tmdb.png','tmdbx.png','metacritic.png','trakt.png','letterboxd.png','mdblist.png','certified.png','certifiedx.png','rfresh.png','rrotten.png','verifiedhot.png','verifiedhotx.png','oscars.png','oscars_bp.png','emmys.png','ends.png')) {
        Print-Icon $n
    }
}

function Patch-All {
    Patch-IncludesInfoFixedPath
    Patch-ScreensaverFixedPath
    Check-Status
}

Write-Host "============================================================"
Write-Host "AF3 + LRS 1.4.4 Oscar Best Picture XML Patch ($PatchVersion)"
Write-Host "============================================================"
Write-Host "Skin 1080i path:"
Write-Host "  $Skin1080i"
Write-Host ""
Write-Host "Pilih aksi:"
Write-Host "  1. Patch fixed-path Oscar BP variables"
Write-Host "  2. Restore Oscar icon hardcode only"
Write-Host "  3. Check status"
Write-Host "  4. Exit"
$choice = Read-Host "Masukkan pilihan [1/2/3/4]"
try {
    switch ($choice) {
        '1' { Patch-All }
        '2' { Restore-R9-DynamicOnlyToHardcode; Check-Status }
        '3' { Check-Status }
        default { Write-Host "Exit." }
    }
} catch {
    Write-Host ""
    Write-Host "[ERROR] $($_.Exception.Message)"
    Write-Host "Tidak ada file yang ditimpa jika error terjadi sebelum tahap penulisan."
    exit 1
}
