[CmdletBinding()]
param(
    [string]$AddonsDir = "E:\Kodi\portable_data\addons",
    [switch]$Check,
    [switch]$RestoreLatest
)

Set-StrictMode -Version 2.0
$ErrorActionPreference = "Stop"

$PatchId = "AF3_ONE_VISIT_ONE_FANART_V2_3"
$BackupRoot = Join-Path $AddonsDir "AF3_Sequential_ExtraFanart_Backups"
$ImagesRel = "plugin.video.themoviedb.helper\resources\tmdbhelper\lib\monitor\images.py"
$ImagesTarget = Join-Path $AddonsDir $ImagesRel

function Stop-Patch([string]$Message) { throw $Message }

function Read-Utf8File([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { Stop-Patch "File tidak ditemukan: $Path" }
    [byte[]]$bytes = [System.IO.File]::ReadAllBytes($Path)
    $hasBom = $bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF
    $encoding = New-Object System.Text.UTF8Encoding($false, $true)
    try {
        if ($hasBom) { $text = $encoding.GetString($bytes, 3, $bytes.Length - 3) }
        else { $text = $encoding.GetString($bytes) }
    } catch { Stop-Patch "File bukan UTF-8 valid: $Path" }
    $newline = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }
    return [PSCustomObject]@{
        Text = $text.Replace("`r`n", "`n").Replace("`r", "`n")
        Newline = $newline
        Bom = $hasBom
    }
}

function Convert-ToBytes($FileData, [string]$Text) {
    $normalized = $Text.Replace("`r`n", "`n").Replace("`r", "`n")
    $rendered = if ($FileData.Newline -eq "`r`n") { $normalized.Replace("`n", "`r`n") } else { $normalized }
    $encoding = New-Object System.Text.UTF8Encoding($false)
    [byte[]]$body = $encoding.GetBytes($rendered)
    if ($FileData.Bom) {
        [byte[]]$prefix = 0xEF, 0xBB, 0xBF
        [byte[]]$combined = New-Object byte[] ($prefix.Length + $body.Length)
        [Array]::Copy($prefix, 0, $combined, 0, $prefix.Length)
        [Array]::Copy($body, 0, $combined, $prefix.Length, $body.Length)
        return $combined
    }
    return $body
}

function Write-Atomic([string]$Path, [byte[]]$Bytes) {
    $directory = Split-Path -Parent $Path
    $temp = Join-Path $directory ((Split-Path -Leaf $Path) + ".af3v23.tmp." + [Guid]::NewGuid().ToString("N"))
    try {
        [System.IO.File]::WriteAllBytes($temp, $Bytes)
        Move-Item -LiteralPath $temp -Destination $Path -Force
    } finally {
        if (Test-Path -LiteralPath $temp -PathType Leaf) { Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue }
    }
}

$Replacement = @'
    # AF3_ONE_VISIT_ONE_FANART_V2_3
    def _get_random_hold_item_key(self):
        """Identify the focused container slot, not volatile item metadata."""
        parent = self._parent

        def _item_info(name):
            try:
                return parent.get_infolabel(name) or ''
            except (AttributeError, TypeError):
                return ''

        def _global_info(name):
            try:
                return get_infolabel(name) or ''
            except (AttributeError, TypeError):
                return ''

        # The container slot is stable while a Home tab enriches its metadata.
        # Moving to another item changes Position. Switching tabs changes the
        # widget/container folder path. Returning to an old slot is therefore a
        # genuine new visit, even if it happens before ten seconds.
        container = getattr(parent, 'container', '') or 'Container.'
        widget_id = getattr(parent, 'widget_id', '') or container
        base_window = getattr(parent, 'cur_base_window', '') or ''
        folderpath = (
            _global_info('{}FolderPath'.format(container))
            or _item_info('folderpath')
        )
        position = (
            _global_info('{}Position'.format(container))
            or _item_info('Position')
            or _global_info('{}CurrentItem'.format(container))
        )
        if folderpath or position:
            return 'slot:{}|{}|{}|{}'.format(
                base_window,
                widget_id,
                folderpath,
                position,
            )

        # Atomic provider IDs are safe fallbacks when no container slot exists.
        mediahub_key = _item_info('Property(mediahub_item_key)')
        if mediahub_key:
            return 'mediahub:{}'.format(mediahub_key)

        steam_appid = _item_info('Property(steam_appid)') or _item_info('Property(appid)')
        if steam_appid:
            return 'steam:{}'.format(steam_appid)

        # Last-resort fallback for static/non-container windows.
        label = _item_info('label') or _item_info('title') or _item_info('tvshowtitle')
        label = ' '.join(str(label).split()).casefold()
        if label:
            return 'label:{}'.format(label)

    def _select_held_random_artwork(self, artworks):
        """One visit selects once; internal refreshes reuse that selection."""
        if not artworks:
            return

        parent = self._parent
        item_key = self._get_random_hold_item_key()

        unique = []
        for artwork in artworks:
            if artwork and artwork not in unique:
                unique.append(artwork)
        artworks = unique or artworks

        import time
        now = time.monotonic()

        try:
            state = parent._af3_one_visit_one_fanart_v2_3
        except AttributeError:
            state = {
                'active_key': None,
                'active_since': 0.0,
                'current_artwork': None,
                'last_by_item': {},
            }
            parent._af3_one_visit_one_fanart_v2_3 = state

        # During a transient frame with no usable slot, keep the current image.
        # Do not manufacture a leave-and-return event from incomplete metadata.
        if not item_key:
            return state['current_artwork'] or random.choice(artworks)

        new_visit = state['active_key'] != item_key
        ten_seconds_elapsed = (
            not new_visit
            and state['active_since']
            and now - state['active_since'] >= 10.0
        )

        if not new_visit and not ten_seconds_elapsed and state['current_artwork']:
            return state['current_artwork']

        previous = state['last_by_item'].get(item_key)
        candidates = [artwork for artwork in artworks if artwork != previous]
        selected = random.choice(candidates or artworks)

        state['active_key'] = item_key
        state['active_since'] = now
        state['current_artwork'] = selected
        state['last_by_item'][item_key] = selected

        if len(state['last_by_item']) > 500:
            oldest = next(iter(state['last_by_item']))
            if oldest != item_key:
                state['last_by_item'].pop(oldest, None)

        return selected

    def get_artwork_item(self, item, prebuilt=False):
        def _get_artwork_item(i, x=''):
            if not prebuilt:
                return self._parent.get_infolabel(i.format(x=x))
            if not i.startswith('art('):
                return
            return self.built_artwork.get(i.format(x=x)[4:-1])

        if '{x}' not in item:
            return _get_artwork_item(item)

        artwork0 = _get_artwork_item(item)
        if not artwork0:
            return

        artwork1 = _get_artwork_item(item, x=1)

        # Keep compatibility with providers publishing extras as properties.
        if not artwork1 and item == 'art(fanart{x})' and not prebuilt:
            property1 = self._parent.get_infolabel('Property(fanart1)')
            if property1:
                artworks = [
                    self._parent.get_infolabel('Property(fanart)') or artwork0,
                    property1,
                ]
                for x in range(2, 9):
                    artwork = self._parent.get_infolabel('Property(fanart{})'.format(x))
                    if not artwork:
                        break
                    artworks.append(artwork)
                return self._select_held_random_artwork(artworks)

        if not artwork1:
            return artwork0

        artworks = [artwork0, artwork1]
        for x in range(2, 9):
            artwork = _get_artwork_item(item, x=x)
            if not artwork:
                break
            artworks.append(artwork)

        return self._select_held_random_artwork(artworks)
'@
$Replacement = $Replacement.TrimEnd([char[]]"`r`n")

function Patch-ImagesPy([string]$Text) {
    if ($Text.Contains($PatchId) -and $Text.Contains("'slot:{}'.format")) { return $Text }
    if ($Text -match 'AF3SEQ_(MOD|PATCH)_') { Stop-Patch "Mod sequential lama masih aktif. Restore kondisi native/random terlebih dahulu." }

    $endToken = "`nclass ImageManipulations"
    $end = $Text.IndexOf($endToken, [System.StringComparison]::Ordinal)
    if ($end -lt 0) { Stop-Patch "Batas class ImageManipulations tidak ditemukan di images.py." }

    $startToken = "    def _get_random_hold_item_key(self):`n"
    $start = $Text.IndexOf($startToken, [System.StringComparison]::Ordinal)

    if ($start -lt 0) {
        $startToken = "    def get_artwork_item(self, item, prebuilt=False):`n"
        $start = $Text.IndexOf($startToken, [System.StringComparison]::Ordinal)
        if ($start -lt 0) { Stop-Patch "Fungsi get_artwork_item() tidak ditemukan di images.py." }
        $oldBlock = $Text.Substring($start, $end - $start)
        if (-not $oldBlock.Contains("if '{x}' not in item:") -or
            -not $oldBlock.Contains("return random.choice(artworks)") -or
            -not $oldBlock.Contains("for x in range(2, 9):")) {
            Stop-Patch "Struktur images.py tidak dikenali. Tidak ada file yang ditulis."
        }
    } else {
        $known = (
            $Text.Contains("AF3_NATIVE_RANDOM_HOLD_V2_1") -or
            $Text.Contains("AF3_NATIVE_RANDOM_HOLD_MWH_V2_2") -or
            $Text.Contains("AF3_ONE_VISIT_ONE_FANART_V2_3")
        )
        if (-not $known) { Stop-Patch "Blok random-hold yang aktif tidak dikenal. Tidak ada file yang ditulis." }
    }

    $patched = $Text.Substring(0, $start) + $Replacement + $Text.Substring($end)
    if (-not $patched.Contains($PatchId) -or
        -not $patched.Contains("{}FolderPath'.format(container)") -or
        -not $patched.Contains("{}Position'.format(container)") -or
        -not $patched.Contains("now - state['active_since'] >= 10.0")) {
        Stop-Patch "Validasi hasil images.py gagal."
    }
    return $patched
}

function Get-LatestBackup {
    if (-not (Test-Path -LiteralPath $BackupRoot -PathType Container)) { return $null }
    return Get-ChildItem -LiteralPath $BackupRoot -Directory -Filter "one_visit_one_fanart_v2_3_*" |
        Sort-Object Name -Descending | Select-Object -First 1
}

try {
    Write-Host ""
    Write-Host "AF3 One Visit One Fanart Patch v2.3" -ForegroundColor Cyan
    Write-Host "Target: $AddonsDir" -ForegroundColor Cyan
    Write-Host "File partial: $ImagesRel" -ForegroundColor Cyan
    Write-Host ""

    if ($RestoreLatest) {
        $latest = Get-LatestBackup
        if ($null -eq $latest) { Stop-Patch "Backup v2.3 tidak ditemukan di $BackupRoot" }
        $backupFile = Join-Path $latest.FullName $ImagesRel
        if (-not (Test-Path -LiteralPath $backupFile -PathType Leaf)) { Stop-Patch "Backup tidak lengkap: $backupFile" }
        Copy-Item -LiteralPath $backupFile -Destination $ImagesTarget -Force
        Write-Host "Restore berhasil dari: $($latest.FullName)" -ForegroundColor Green
        exit 0
    }

    $data = Read-Utf8File $ImagesTarget

    if ($Check) {
        $ok = $data.Text.Contains($PatchId) -and
              $data.Text.Contains("{}FolderPath'.format(container)") -and
              $data.Text.Contains("{}Position'.format(container)")
        if ($ok) {
            Write-Host "AKTIF: satu kunjungan item hanya memilih satu fanart." -ForegroundColor Green
            Write-Host "AKTIF: refresh internal tab memakai fanart yang sama." -ForegroundColor Green
            exit 0
        }
        Write-Host "BELUM AKTIF: patch v2.3 tidak ditemukan." -ForegroundColor Yellow
        exit 1
    }

    $patched = Patch-ImagesPy $data.Text
    if ($patched -eq $data.Text) {
        Write-Host "Patch v2.3 sudah aktif. Tidak ada file yang ditulis." -ForegroundColor Cyan
        exit 0
    }

    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupDir = Join-Path $BackupRoot ("one_visit_one_fanart_v2_3_" + $stamp)
    $backupFile = Join-Path $backupDir $ImagesRel
    New-Item -ItemType Directory -Path (Split-Path -Parent $backupFile) -Force | Out-Null
    Copy-Item -LiteralPath $ImagesTarget -Destination $backupFile -Force
    @(
        "Patch=$PatchId"
        "Created=$stamp"
        "AddonsDir=$AddonsDir"
        "Files=1"
        "Target=$ImagesRel"
    ) | Set-Content -LiteralPath (Join-Path $backupDir "manifest.txt") -Encoding UTF8

    try { Write-Atomic $ImagesTarget (Convert-ToBytes $data $patched) }
    catch {
        Copy-Item -LiteralPath $backupFile -Destination $ImagesTarget -Force
        throw
    }

    Write-Host ""
    Write-Host "PATCH v2.3 BERHASIL." -ForegroundColor Green
    Write-Host "Backup: $backupDir" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Flow aktif:" -ForegroundColor Cyan
    Write-Host "  - Masuk item: pilih satu fanart."
    Write-Host "  - Refresh internal pada kunjungan yang sama: tetap fanart itu."
    Write-Host "  - Keluar lalu kembali: pilih satu fanart baru."
    Write-Host "  - Diam 10 detik: boleh memilih fanart baru."
    Write-Host "  - Hanya images.py yang diubah."
} catch {
    Write-Host ""
    Write-Host "GAGAL: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Tidak ada file yang ditulis jika kegagalan terjadi saat validasi."
    exit 1
}
