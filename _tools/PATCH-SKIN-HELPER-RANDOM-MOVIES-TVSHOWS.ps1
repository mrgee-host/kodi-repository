
param(
    [string]$AddonPath = "E:\Kodi\portable_data\addons\script.skin.helper.widgets",
    [ValidateSet('patch','restore')]
    [string]$Action = 'patch'
)

$ErrorActionPreference = 'Stop'
$MediaPy = Join-Path $AddonPath 'resources\lib\media.py'
$Backup = "$MediaPy.random-movies-tvshows.bak"
$MethodMarker = '# AFM-RANDOM-MOVIES-TVSHOWS-METHOD-START'
$MethodEnd = '# AFM-RANDOM-MOVIES-TVSHOWS-METHOD-END'
$EntryMarker = '# AFM-RANDOM-MOVIES-TVSHOWS-LISTING'

function ReadText($p) {
    return [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8)
}
function WriteText($p, $s) {
    $utf8NoBom = New-Object System.Text.UTF8Encoding($false)
    [System.IO.File]::WriteAllText($p, $s, $utf8NoBom)
}

Write-Host '============================================================'
Write-Host 'Skin Helper Widgets - Random Movies + TV Shows patch'
Write-Host '============================================================'
Write-Host "Addon path: $AddonPath"
Write-Host "media.py  : $MediaPy"
Write-Host "Action    : $Action"
Write-Host ''

if (!(Test-Path $MediaPy)) {
    throw "media.py tidak ditemukan: $MediaPy"
}

if ($Action -eq 'restore') {
    if (!(Test-Path $Backup)) {
        throw "Backup tidak ditemukan: $Backup"
    }
    Copy-Item $Backup $MediaPy -Force
    Write-Host '[OK] Restore selesai.'
    Write-Host 'Restart Kodi penuh setelah restore.'
    exit 0
}

if (!(Test-Path $Backup)) {
    Copy-Item $MediaPy $Backup -Force
    Write-Host "[OK] Backup dibuat: $Backup"
} else {
    Write-Host "[INFO] Backup sudah ada, tidak ditimpa: $Backup"
}

$text = ReadText $MediaPy

# Remove older patch block if re-run
$pattern = "(?ms)\n    $([regex]::Escape($MethodMarker)).*?    $([regex]::Escape($MethodEnd))\r?\n"
$text = [regex]::Replace($text, $pattern, "`n")

$method = @'
    # AFM-RANDOM-MOVIES-TVSHOWS-METHOD-START
    def randommoviestvshows(self):
        """get random movies and tvshows only - no episodes, no music, no pvr"""
        all_items = self.movies.random()
        all_items += self.tvshows.random()
        return sorted(all_items, key=lambda k: random.random())[:self.options["limit"]]
    # AFM-RANDOM-MOVIES-TVSHOWS-METHOD-END

'@

if ($text -notmatch 'def randommoviestvshows\(self\):') {
    $needle = "    def inprogress(self):"
    if ($text.Contains($needle)) {
        $text = $text.Replace($needle, $method + $needle)
        Write-Host '[OK] Method randommoviestvshows ditambahkan.'
    } else {
        throw 'Tidak menemukan posisi insert sebelum def inprogress(self).'
    }
} else {
    Write-Host '[INFO] Method randommoviestvshows sudah ada.'
}

# Add menu entry in Media listing if possible (optional). The direct plugin path works even without this.
if ($text -notmatch [regex]::Escape($EntryMarker)) {
    $old = '            (self.addon.getLocalizedString(32059), "random&mediatype=media", "DefaultMovies.png"),'
    $new = $old + "`n            (`"Random Movies + TV Shows`", `"randommoviestvshows&mediatype=media`", `"DefaultMovies.png`"),  " + $EntryMarker
    if ($text.Contains($old)) {
        $text = $text.Replace($old, $new)
        Write-Host '[OK] Entry menu Random Movies + TV Shows ditambahkan.'
    } else {
        Write-Host '[WARN] Entry Random Media tidak ditemukan; method tetap bisa dipakai via path langsung.'
    }
} else {
    Write-Host '[INFO] Entry menu sudah ada.'
}

WriteText $MediaPy $text
Write-Host ''
Write-Host '[OK] Patch selesai.'
Write-Host 'Pakai path XML ini:'
Write-Host '<value>plugin://script.skin.helper.widgets/?action=randommoviestvshows&amp;mediatype=media&amp;limit=100</value>'
Write-Host ''
Write-Host 'Restart Kodi penuh setelah patch.'
