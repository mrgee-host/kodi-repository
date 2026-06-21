param(
    [ValidateSet('menu','patch','restore','exit')]
    [string]$Action = 'menu',

    [string]$AddonPath = "E:\Kodi\portable_data\addons\script.skin.helper.widgets",
    [string]$SkinPath  = "E:\Kodi\portable_data\addons\skin.arctic.fuse.3",
    [int]$Limit = 100
)

$ErrorActionPreference = 'Stop'

$MediaPy = Join-Path $AddonPath 'resources\lib\media.py'
$IncludesDefaults = Join-Path $SkinPath '1080i\Includes_Defaults.xml'

$MediaBackup = "$MediaPy.afm-random-movies-tvshows.bak"
$XmlBackup   = "$IncludesDefaults.afm-random-movies-tvshows-xml.bak"

$MethodMarker = '# AFM-RANDOM-MOVIES-TVSHOWS-METHOD-START'
$MethodEnd    = '# AFM-RANDOM-MOVIES-TVSHOWS-METHOD-END'
$EntryMarker  = '# AFM-RANDOM-MOVIES-TVSHOWS-LISTING'
$XmlMarker    = '<!-- AFM-RANDOM-MOVIES-TVSHOWS-XML-PATCH -->'

function Read-Utf8Text([string]$Path) {
    return [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
}

function Write-Utf8NoBom([string]$Path, [string]$Text) {
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($Path, $Text, $utf8NoBom)
}

function Ensure-Backup([string]$Source, [string]$Backup) {
    if (!(Test-Path $Source)) {
        throw "File tidak ditemukan: $Source"
    }
    if (!(Test-Path $Backup)) {
        Copy-Item $Source $Backup -Force
        Write-Host "[OK] Backup dibuat: $Backup"
    } else {
        Write-Host "[INFO] Backup sudah ada, tidak ditimpa: $Backup"
    }
}

function Patch-SkinHelperMedia {
    Write-Host ''
    Write-Host '--- Patch Skin Helper Widgets media.py ---'
    Write-Host "Target: $MediaPy"

    Ensure-Backup $MediaPy $MediaBackup
    $text = Read-Utf8Text $MediaPy

    # Remove older marker block from this patch so re-run stays clean.
    $blockPattern = "(?ms)\r?\n    $([regex]::Escape($MethodMarker)).*?    $([regex]::Escape($MethodEnd))\r?\n"
    $text = [regex]::Replace($text, $blockPattern, "`n")

    $method = @'
    # AFM-RANDOM-MOVIES-TVSHOWS-METHOD-START
    def randommoviestvshows(self):
        """get random movies and tvshows only - no episodes, no music, no pvr"""
        all_items = self.movies.random()
        all_items += self.tvshows.random()
        return sorted(all_items, key=lambda k: random.random())[:self.options["limit"]]
    # AFM-RANDOM-MOVIES-TVSHOWS-METHOD-END

'@

    # Add method inside Media class. Existing Skin Helper sources have def inprogress(self) after random/media methods.
    if ($text -notmatch 'def\s+randommoviestvshows\s*\(\s*self\s*\)\s*:') {
        $needle = '    def inprogress(self):'
        if ($text.Contains($needle)) {
            $text = $text.Replace($needle, $method + $needle)
            Write-Host '[OK] Method randommoviestvshows ditambahkan.'
        } else {
            throw 'Tidak menemukan posisi insert: def inprogress(self). media.py mungkin beda versi.'
        }
    } else {
        Write-Host '[INFO] Method randommoviestvshows sudah ada.'
    }

    # Optional: add browsable menu entry if source has Random Media entry. Direct path works even without this.
    if ($text -notmatch [regex]::Escape($EntryMarker)) {
        $old = '            (self.addon.getLocalizedString(32059), "random&mediatype=media", "DefaultMovies.png"),'
        $new = $old + "`n            (`"Random Movies + TV Shows`", `"randommoviestvshows&mediatype=media`", `"DefaultMovies.png`"),  " + $EntryMarker
        if ($text.Contains($old)) {
            $text = $text.Replace($old, $new)
            Write-Host '[OK] Entry menu Random Movies + TV Shows ditambahkan.'
        } else {
            Write-Host '[INFO] Entry Random Media tidak ditemukan; direct plugin path tetap dipakai dari XML.'
        }
    } else {
        Write-Host '[INFO] Entry menu sudah ada.'
    }

    Write-Utf8NoBom $MediaPy $text
    Write-Host '[OK] media.py selesai.'
}

function Patch-IncludesDefaultsXml {
    Write-Host ''
    Write-Host '--- Patch AF3 Includes_Defaults.xml ---'
    Write-Host "Target: $IncludesDefaults"

    Ensure-Backup $IncludesDefaults $XmlBackup
    $text = Read-Utf8Text $IncludesDefaults

    $pluginPathXml = "plugin://script.skin.helper.widgets/?action=randommoviestvshows&amp;mediatype=media&amp;limit=$Limit"
    $newVariable = @"
    <variable name=""Defs_ScreensaverWidget"">
        $XmlMarker
        <value>$pluginPathXml</value>
    </variable>
"@

    $pattern = '(?ms)\s*<variable\s+name="Defs_ScreensaverWidget">.*?</variable>'
    if ([regex]::IsMatch($text, $pattern)) {
        $rx = New-Object System.Text.RegularExpressions.Regex($pattern)
        $text = $rx.Replace($text, "`n" + $newVariable, 1)
        Write-Host '[OK] Variable Defs_ScreensaverWidget diganti partial.'
    } else {
        throw 'Variable Defs_ScreensaverWidget tidak ditemukan di Includes_Defaults.xml.'
    }

    Write-Utf8NoBom $IncludesDefaults $text
    Write-Host '[OK] Includes_Defaults.xml selesai.'
}

function Do-Patch {
    Write-Host '============================================================'
    Write-Host 'Skin Helper Widgets + AF3 Screensaver XML patch'
    Write-Host 'Random Movies + TV Shows only, tanpa episodes'
    Write-Host '============================================================'
    Write-Host "Addon path : $AddonPath"
    Write-Host "Skin path  : $SkinPath"
    Write-Host "Limit      : $Limit"

    Patch-SkinHelperMedia
    Patch-IncludesDefaultsXml

    Write-Host ''
    Write-Host '[OK] PATCH SELESAI.'
    Write-Host 'Path aktif di screensaver:'
    Write-Host "plugin://script.skin.helper.widgets/?action=randommoviestvshows&mediatype=media&limit=$Limit"
    Write-Host ''
    Write-Host 'Tutup Kodi penuh lalu buka lagi.'
}

function Do-Restore {
    Write-Host '============================================================'
    Write-Host 'Restore Skin Helper Widgets + AF3 Screensaver XML patch'
    Write-Host '============================================================'

    $did = $false

    if (Test-Path $MediaBackup) {
        Copy-Item $MediaBackup $MediaPy -Force
        Write-Host "[OK] media.py direstore dari: $MediaBackup"
        $did = $true
    } else {
        Write-Host "[WARN] Backup media.py tidak ditemukan: $MediaBackup"
    }

    if (Test-Path $XmlBackup) {
        Copy-Item $XmlBackup $IncludesDefaults -Force
        Write-Host "[OK] Includes_Defaults.xml direstore dari: $XmlBackup"
        $did = $true
    } else {
        Write-Host "[WARN] Backup XML tidak ditemukan: $XmlBackup"
    }

    if ($did) {
        Write-Host ''
        Write-Host '[OK] RESTORE SELESAI. Tutup Kodi penuh lalu buka lagi.'
    } else {
        Write-Host ''
        Write-Host '[INFO] Tidak ada backup yang bisa direstore.'
    }
}

function Show-Menu {
    while ($true) {
        Write-Host ''
        Write-Host '============================================================'
        Write-Host 'SHW Random Movies + TV Shows + AF3 XML'
        Write-Host '============================================================'
        Write-Host "Addon path : $AddonPath"
        Write-Host "Skin path  : $SkinPath"
        Write-Host ''
        Write-Host '1. Patch'
        Write-Host '2. Restore'
        Write-Host '3. Exit'
        Write-Host ''
        $choice = Read-Host 'Pilih [1/2/3]'
        if ($choice -eq '1') {
            Do-Patch
            Read-Host 'Enter untuk kembali ke menu'
        } elseif ($choice -eq '2') {
            Do-Restore
            Read-Host 'Enter untuk kembali ke menu'
        } elseif ($choice -eq '3') {
            Write-Host 'Exit.'
            return
        } else {
            Write-Host '[WARN] Pilihan tidak valid.'
        }
    }
}

try {
    switch ($Action) {
        'menu'    { Show-Menu }
        'patch'   { Do-Patch }
        'restore' { Do-Restore }
        'exit'    { Write-Host 'Exit.' }
    }
} catch {
    Write-Host ''
    Write-Host '[ERROR]' $_.Exception.Message
    Write-Host ''
    Write-Host 'Tidak semua file ditulis kalau error terjadi sebelum tahap penulisan.'
    if ($Action -eq 'menu') {
        Read-Host 'Enter untuk keluar'
    }
    exit 1
}
