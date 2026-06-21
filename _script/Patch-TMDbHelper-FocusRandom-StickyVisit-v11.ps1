# TMDbHelper Focus Random Sticky Visit Patch V11
# Pure PowerShell patcher - no external Python required.
# 1 = Patch, 2 = Restore, 3 = Exit

$ErrorActionPreference = 'Stop'

$DefaultAddonPath = 'E:\Kodi\portable_data\addons\plugin.video.themoviedb.helper'
$PatchName = 'TMDbHelper-FocusRandom-StickyVisit-v11'
$BackupRoot = Join-Path $PSScriptRoot ($PatchName + '-backups')
$LatestFile = Join-Path $BackupRoot 'latest.txt'

function Write-Title {
    Clear-Host
    Write-Host '============================================================'
    Write-Host 'TMDbHelper - Focus Random Sticky Visit Patch V11'
    Write-Host '============================================================'
    Write-Host ''
}

function Read-TextFileUtf8NoBom([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "File tidak ditemukan: $Path"
    }
    return [System.IO.File]::ReadAllText($Path, [System.Text.UTF8Encoding]::new($false))
}

function Write-TextFileUtf8NoBom([string]$Path, [string]$Text) {
    [System.IO.File]::WriteAllText($Path, $Text, [System.Text.UTF8Encoding]::new($false))
}

function Get-TargetFiles([string]$AddonPath) {
    $imgmon = Join-Path $AddonPath 'resources\tmdbhelper\lib\monitor\imgmon.py'
    $images = Join-Path $AddonPath 'resources\tmdbhelper\lib\monitor\images.py'
    if (-not (Test-Path -LiteralPath $imgmon)) { throw "imgmon.py tidak ditemukan: $imgmon" }
    if (-not (Test-Path -LiteralPath $images)) { throw "images.py tidak ditemukan: $images" }
    return @{ Imgmon = $imgmon; Images = $images }
}

function Test-AlreadyPatched([string]$ImgmonText, [string]$ImagesText) {
    return ($ImgmonText -like '*Focus-random sticky visit patch V11*' -and $ImagesText -like '*_focus_random_sticky_choose*')
}

function New-Backup([string]$ImgmonPath, [string]$ImagesPath) {
    if (-not (Test-Path -LiteralPath $BackupRoot)) {
        New-Item -ItemType Directory -Path $BackupRoot | Out-Null
    }

    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $dir = Join-Path $BackupRoot $stamp
    New-Item -ItemType Directory -Path $dir | Out-Null

    Copy-Item -LiteralPath $ImgmonPath -Destination (Join-Path $dir 'imgmon.py') -Force
    Copy-Item -LiteralPath $ImagesPath -Destination (Join-Path $dir 'images.py') -Force
    Set-Content -LiteralPath $LatestFile -Value $dir -Encoding UTF8

    Write-Host "[INFO] Backup dibuat: $dir"
    return $dir
}

function Clear-PyCache([string]$AddonPath) {
    $monitorDir = Join-Path $AddonPath 'resources\tmdbhelper\lib\monitor'
    $pycache = Join-Path $monitorDir '__pycache__'
    if (Test-Path -LiteralPath $pycache) {
        Get-ChildItem -LiteralPath $pycache -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '^(imgmon|images)\..*\.pyc$' } |
            ForEach-Object {
                try { Remove-Item -LiteralPath $_.FullName -Force -ErrorAction Stop } catch {}
            }
        Write-Host '[INFO] __pycache__ imgmon/images dibersihkan.'
    }
}

function Patch-Imgmon([string]$Text) {
    $newline = if ($Text.Contains("`r`n")) { "`r`n" } else { "`n" }

    if ($Text -notmatch 'self\.properties\s*=\s*set\(\)') {
        throw 'Anchor imgmon.py tidak cocok: self.properties = set() tidak ditemukan.'
    }

    if ($Text -notlike '*self._focus_random_visit_id*') {
        $Text = [regex]::Replace(
            $Text,
            'self\.properties\s*=\s*set\(\)',
            "self.properties = set()$newline        self._focus_random_visit_id = 0  # Focus-random sticky visit patch V11",
            1
        )
    }

    $pattern = '(?ms)(        # Check if the item has changed before retrieving details again\r?\n        if not self\.is_same_item\(update=True\) or not self\.is_same_window\(update=True\):\r?\n)(.*?)(?=\r?\n    @kodi_try_except)'
    if (-not [regex]::IsMatch($Text, $pattern)) {
        throw 'Anchor imgmon.py tidak cocok: blok is_next_refresh() tidak ditemukan.'
    }

    $replacement = @"
`${1}            # Focus-random sticky visit patch V11: new item/window = new random visit
            try:
                self._focus_random_visit_id += 1
            except AttributeError:
                self._focus_random_visit_id = 1
            return True

        # Focus-random sticky visit patch V11: disable idle extra-fanart refresh.
        # Random only happens when Kodi focus moves to another item/window.
        return False
"@
    $replacement = $replacement -replace "`r?`n", $newline
    $Text = [regex]::Replace($Text, $pattern, $replacement, 1)
    return $Text
}

function Patch-Images([string]$Text) {
    $newline = if ($Text.Contains("`r`n")) { "`r`n" } else { "`n" }

    if ($Text -notlike '*_focus_random_sticky_choose*') {
        $helper = @'

# Focus-random sticky visit patch V11
# Keeps the random fanart choice stable while the same focused item is being processed.
# A new visit id from imgmon.py allows the same movie to get a new random fanart when you leave it and return.
_FOCUS_RANDOM_STICKY_BY_VISIT = {}
_FOCUS_RANDOM_STICKY_LAST_BY_ITEM = {}


def _focus_random_sticky_unique(values):
    output = []
    for value in values:
        if value and value not in output:
            output.append(value)
    return output


def _focus_random_sticky_attr(parent, name, default=None):
    try:
        return getattr(parent, name, default)
    except Exception:
        return default


def _focus_random_sticky_choose(item, artworks, parent=None):
    artworks = _focus_random_sticky_unique(artworks)
    if not artworks:
        return None
    if len(artworks) == 1:
        return artworks[0]

    parent_id = id(parent) if parent is not None else 0
    visit_id = _focus_random_sticky_attr(parent, '_focus_random_visit_id', 0)
    cur_item = repr(_focus_random_sticky_attr(parent, 'pre_item', None))
    cur_window = repr(_focus_random_sticky_attr(parent, 'pre_window', None))

    visit_key = (parent_id, visit_id, cur_item, cur_window, item)
    cached = _FOCUS_RANDOM_STICKY_BY_VISIT.get(visit_key)
    if cached in artworks:
        return cached

    item_key = (parent_id, cur_item, item)
    last = _FOCUS_RANDOM_STICKY_LAST_BY_ITEM.get(item_key)
    choices = [art for art in artworks if art != last] or artworks
    choice = random.choice(choices)

    _FOCUS_RANDOM_STICKY_BY_VISIT[visit_key] = choice
    _FOCUS_RANDOM_STICKY_LAST_BY_ITEM[item_key] = choice

    # Keep dictionaries small during long library browsing sessions.
    if len(_FOCUS_RANDOM_STICKY_BY_VISIT) > 500:
        _FOCUS_RANDOM_STICKY_BY_VISIT.clear()
        _FOCUS_RANDOM_STICKY_BY_VISIT[visit_key] = choice
    if len(_FOCUS_RANDOM_STICKY_LAST_BY_ITEM) > 500:
        _FOCUS_RANDOM_STICKY_LAST_BY_ITEM.clear()
        _FOCUS_RANDOM_STICKY_LAST_BY_ITEM[item_key] = choice

    return choice
'@
        $helper = $helper -replace "`r?`n", $newline
        $anchor = 'class ImageFunctions'
        $idx = $Text.IndexOf($anchor)
        if ($idx -lt 0) {
            throw 'Anchor images.py tidak cocok: class ImageFunctions tidak ditemukan.'
        }
        $Text = $Text.Insert($idx, $helper + $newline)
    }

    if ($Text -match 'return\s+_focus_random_sticky_choose\(item, artworks, self\._parent\)') {
        return $Text
    }

    $matches = [regex]::Matches($Text, 'return\s+random\.choice\(artworks\)')
    if ($matches.Count -ne 1) {
        throw "Anchor images.py tidak cocok: return random.choice(artworks) ditemukan $($matches.Count) kali."
    }

    $Text = [regex]::Replace($Text, 'return\s+random\.choice\(artworks\)', 'return _focus_random_sticky_choose(item, artworks, self._parent)', 1)
    return $Text
}

function Invoke-Patch([string]$AddonPath) {
    $files = Get-TargetFiles $AddonPath
    Write-Host '[INFO] Membaca file aktif...'
    $imgmonText = Read-TextFileUtf8NoBom $files.Imgmon
    $imagesText = Read-TextFileUtf8NoBom $files.Images

    if (Test-AlreadyPatched $imgmonText $imagesText) {
        Write-Host '[INFO] Patch V11 sudah terpasang. Tidak ada perubahan.'
        return
    }

    Write-Host '[INFO] Membuat backup sebelum patch...'
    New-Backup $files.Imgmon $files.Images | Out-Null

    Write-Host '[INFO] Menyiapkan patch imgmon.py...'
    $newImgmon = Patch-Imgmon $imgmonText

    Write-Host '[INFO] Menyiapkan patch images.py...'
    $newImages = Patch-Images $imagesText

    if ($newImgmon -eq $imgmonText -and $newImages -eq $imagesText) {
        Write-Host '[INFO] Tidak ada perubahan yang diperlukan.'
        return
    }

    Write-Host '[INFO] Menulis file patch...'
    Write-TextFileUtf8NoBom $files.Imgmon $newImgmon
    Write-TextFileUtf8NoBom $files.Images $newImages
    Clear-PyCache $AddonPath
    Write-Host ''
    Write-Host '[OK] Patch V11 berhasil dipasang.'
    Write-Host '     Tutup/buka Kodi lagi kalau Kodi masih berjalan.'
}

function Invoke-Restore([string]$AddonPath) {
    $files = Get-TargetFiles $AddonPath
    if (-not (Test-Path -LiteralPath $LatestFile)) {
        throw "Backup latest V11 tidak ditemukan: $LatestFile"
    }
    $dir = (Get-Content -LiteralPath $LatestFile -Raw).Trim()
    if (-not (Test-Path -LiteralPath $dir)) {
        throw "Folder backup latest tidak ditemukan: $dir"
    }
    $bImgmon = Join-Path $dir 'imgmon.py'
    $bImages = Join-Path $dir 'images.py'
    if (-not (Test-Path -LiteralPath $bImgmon)) { throw "Backup imgmon.py tidak ditemukan: $bImgmon" }
    if (-not (Test-Path -LiteralPath $bImages)) { throw "Backup images.py tidak ditemukan: $bImages" }

    Copy-Item -LiteralPath $bImgmon -Destination $files.Imgmon -Force
    Copy-Item -LiteralPath $bImages -Destination $files.Images -Force
    Clear-PyCache $AddonPath
    Write-Host ''
    Write-Host "[OK] Restore V11 berhasil dari: $dir"
}

Write-Title
Write-Host 'Addon path:'
Write-Host "  $DefaultAddonPath"
Write-Host ''
Write-Host 'Pilih aksi:'
Write-Host '  1. Patch Focus Random Sticky Visit'
Write-Host '  2. Restore backup V11'
Write-Host '  3. Exit'
Write-Host ''
$choice = Read-Host 'Masukkan pilihan [1/2/3]'

try {
    switch ($choice) {
        '1' { Invoke-Patch $DefaultAddonPath }
        '2' { Invoke-Restore $DefaultAddonPath }
        '3' { Write-Host 'Exit.' }
        default { Write-Host 'Pilihan tidak valid.' }
    }
}
catch {
    Write-Host ''
    Write-Host '[ERROR]' $_.Exception.Message -ForegroundColor Red
    Write-Host 'Tidak ada file yang ditimpa jika error terjadi sebelum tahap penulisan.'
}

Write-Host ''
Read-Host 'Press Enter to exit'
