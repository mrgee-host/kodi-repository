<#
Kodi Patch Manager hard restore script
Restores all 17 current AF3 XML targets patched by Kodi Patch Manager 0.2.46, plus the legacy Python targets already supported by this script, back to clean/default addon files where possible.
Default Kodi root: E:\Kodi

Current restore policy:
- Creates a timestamped backup of every active target file before touching it.
- Downloads ONLY the required raw files from GitHub, not full repository ZIP files.
- Saves every successfully downloaded clean source file into a persistent local restore cache.
- If GitHub/internet is unavailable, restores from the local clean-source cache.
- If both GitHub and cache are unavailable for a target, performs marker cleanup only for that target.
- Deletes Python __pycache__/*.pyc files after restore so old compiled KPM code cannot survive.
- Restores the exact 17 current AF3 XML patch targets listed by KPM 0.2.46.
- Does not restore AF3 XML files that are diagnostics-only and not patched by current KPM.
- Validates downloaded/cached XML before replacing an active XML file.
- Reports remaining KPM markers after restore.

Run while Kodi is CLOSED.
#>

param(
    [string]$KodiRoot = "E:\Kodi",
    [switch]$NoDownload,
    [switch]$SkipPrompts
)

$ErrorActionPreference = 'Stop'

function Write-Title($Text) {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor DarkGray
    Write-Host $Text -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor DarkGray
}

function Ensure-Dir($Path) {
    if (!(Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

function Normalize-Rel([string]$Rel) {
    return (($Rel -replace '^[\\/]+', '') -replace '/', '\')
}

function Join-Rel($Base, [string]$Rel) {
    return Join-Path $Base (Normalize-Rel $Rel)
}

function Copy-Backup($Source, $BackupRoot, $Rel) {
    if (Test-Path -LiteralPath $Source) {
        $dst = Join-Rel $BackupRoot $Rel
        Ensure-Dir (Split-Path $dst -Parent)
        Copy-Item -LiteralPath $Source -Destination $dst -Force
        return $true
    }
    return $false
}

function Download-RawFile($Url, $OutFile) {
    Ensure-Dir (Split-Path $OutFile -Parent)
    Write-Host "Downloading raw: $Url"
    Invoke-WebRequest -Uri $Url -OutFile $OutFile -UseBasicParsing -TimeoutSec 90
    if (!(Test-Path -LiteralPath $OutFile)) { throw "Download did not create output file." }
    if ((Get-Item -LiteralPath $OutFile).Length -le 0) { throw "Downloaded file is empty." }
}


function Assert-ValidXmlIfNeeded($Path, $TargetPath) {
    if ([System.IO.Path]::GetExtension($TargetPath) -ine '.xml') { return }
    try {
        $raw = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
        $null = [xml]$raw
    } catch {
        throw "Invalid XML source for $TargetPath : $($_.Exception.Message)"
    }
}

function Remove-RegexBlock([string]$Text, [string]$Start, [string]$End) {
    $pattern = [regex]::Escape($Start) + '(?s).*?' + [regex]::Escape($End) + "\r?\n?"
    return [regex]::Replace($Text, $pattern, '')
}

function Marker-Cleanup($Path) {
    if (!(Test-Path -LiteralPath $Path)) { return $false }
    $text = Get-Content -LiteralPath $Path -Raw -Encoding UTF8
    $orig = $text

    # XML block markers used by KPM experiments.
    $pairs = @(
        @('<!-- KPM-VFS-PAUSE-RATINGS-START -->','<!-- KPM-VFS-PAUSE-RATINGS-END -->'),
        @('<!-- KPM-DIALOG-SEEKBAR-PAUSE-RATINGS-START -->','<!-- KPM-DIALOG-SEEKBAR-PAUSE-RATINGS-END -->'),
        @('<!-- KPM-VIDEOOSD-CLEARART-RIGHT-START -->','<!-- KPM-VIDEOOSD-CLEARART-RIGHT-END -->'),
        @('<!-- KPM-VIDEOOSD-FAST-CLOSE-RESUME-START -->','<!-- KPM-VIDEOOSD-FAST-CLOSE-RESUME-END -->'),
        @('<!-- KPM-OSD-PLOT-WIDTH-START -->','<!-- KPM-OSD-PLOT-WIDTH-END -->'),
        @('<!-- KPM-DIALOG-SEEKBAR-CLEARART-BEHIND-PROGRESS-START -->','<!-- KPM-DIALOG-SEEKBAR-CLEARART-BEHIND-PROGRESS-END -->'),
        @('<!-- KPM-OSD-RANGE-MARKERS-HIDDEN-START -->','<!-- KPM-OSD-RANGE-MARKERS-HIDDEN-END -->'),
        @('<!-- KPM-ACTION-OSD-PAUSE-STAY-START -->','<!-- KPM-ACTION-OSD-PAUSE-STAY-END -->'),
        @('<!-- KPM-STUDIO-LOGOS-IMAGE-VAR-START -->','<!-- KPM-STUDIO-LOGOS-IMAGE-VAR-END -->'),
        @('<!-- KPM-STUDIO-LOGOS-FURNITURE-START -->','<!-- KPM-STUDIO-LOGOS-FURNITURE-END -->'),
        @('<!-- KPM-FANART-AF3-SOURCE-BRIDGE-V1 -->','<!-- KPM-FANART-AF3-SOURCE-BRIDGE-END -->')
    )
    foreach ($p in $pairs) { $text = Remove-RegexBlock $text $p[0] $p[1] }

    # Single line XML markers/values.
    $lineMarkers = @(
        'KPM-DIALOG-SEEKBAR-AUTO-VIDEOOSD',
        'KPM-UPNEXT-EPISODE-THUMB',
        'KPM-SHW-RANDOM-MOVIES-TVSHOWS-XML',
        'KPM-INDEPENDENT-FANART-V1',
        'KPM-INDEPENDENT-FANART-LAUNCH-V2',
        'KPM-STUDIO-LOGOS-FURNITURE-v0.1.30-SINGLE'
    )
    foreach ($m in $lineMarkers) {
        $text = [regex]::Replace($text, "(?m)^.*" + [regex]::Escape($m) + ".*\r?\n?", '')
    }

    # Python block markers for TMDbHelper/SHW.
    $pyPairs = @(
        @('# KPM-SHW-RANDOM-MOVIES-TVSHOWS-METHOD-START','# KPM-SHW-RANDOM-MOVIES-TVSHOWS-METHOD-END'),
        @('# KPM-TMDB-FOCUS-RANDOM-V12-REFRESH-START','# KPM-TMDB-FOCUS-RANDOM-V12-REFRESH-END'),
        @('# KPM-TMDB-FOCUS-RANDOM-V11-REFRESH-START','# KPM-TMDB-FOCUS-RANDOM-V11-REFRESH-END'),
        @('# KPM-TMDB-FOCUS-RANDOM-V12-HELPER-START','# KPM-TMDB-FOCUS-RANDOM-V12-HELPER-END'),
        @('# KPM-TMDB-FOCUS-RANDOM-V11-HELPER-START','# KPM-TMDB-FOCUS-RANDOM-V11-HELPER-END')
    )
    foreach ($p in $pyPairs) { $text = Remove-RegexBlock $text $p[0] $p[1] }
    foreach ($m in @('# KPM-SHW-RANDOM-MOVIES-TVSHOWS-LISTING','# KPM-TMDB-FOCUS-RANDOM-V12-ATTR','# KPM-TMDB-FOCUS-RANDOM-V11-ATTR','# KPM-TMDB-FOCUS-RANDOM-V12-CALL','# KPM-TMDB-FOCUS-RANDOM-V11-CALL')) {
        $text = [regex]::Replace($text, "(?m)^.*" + [regex]::Escape($m) + ".*\r?\n?", '')
    }

    if ($text -ne $orig) {
        Set-Content -LiteralPath $Path -Value $text -Encoding UTF8 -NoNewline
        Write-Host "CLEANED MARKERS: $Path" -ForegroundColor Yellow
        return $true
    }
    return $false
}


function Clear-PythonCacheTree($Root, $BackupRoot, [string]$BackupRelBase) {
    $deleted = @()
    if (!(Test-Path -LiteralPath $Root)) { return $deleted }

    $compiled = @(Get-ChildItem -LiteralPath $Root -Recurse -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -in @('.pyc','.pyo') })
    foreach ($file in $compiled) {
        try {
            $relPart = $file.FullName.Substring($Root.Length).TrimStart('\','/')
            $backupRel = Join-Path $BackupRelBase $relPart
            $null = Copy-Backup $file.FullName $BackupRoot $backupRel
            Remove-Item -LiteralPath $file.FullName -Force
            $deleted += $file.FullName
            Write-Host "DELETED PYTHON CACHE: $($file.FullName)" -ForegroundColor Yellow
        } catch {
            Write-Host "Failed to delete Python cache $($file.FullName): $($_.Exception.Message)" -ForegroundColor DarkYellow
        }
    }

    $cacheDirs = @(Get-ChildItem -LiteralPath $Root -Recurse -Directory -Filter '__pycache__' -ErrorAction SilentlyContinue | Sort-Object FullName -Descending)
    foreach ($dir in $cacheDirs) {
        try {
            $remaining = @(Get-ChildItem -LiteralPath $dir.FullName -Force -ErrorAction SilentlyContinue)
            if ($remaining.Count -eq 0) {
                Remove-Item -LiteralPath $dir.FullName -Force
                Write-Host "REMOVED EMPTY PYCACHE DIR: $($dir.FullName)" -ForegroundColor DarkYellow
            }
        } catch {}
    }

    return $deleted
}

function Restore-Target($Target, $BackupRoot, $WorkRoot, $CacheRoot, [bool]$SkipDownload) {
    $name = $Target.Name
    $targetPath = $Target.TargetPath
    $backupRel = $Target.BackupRel
    $cacheRel = $Target.CacheRel
    $sourceKey = $Target.SourceKey
    $urls = @($Target.Urls)

    $null = Copy-Backup $targetPath $BackupRoot $backupRel

    Ensure-Dir (Split-Path $targetPath -Parent)
    $cachePath = Join-Rel (Join-Path $CacheRoot $sourceKey) $cacheRel
    $tmpName = (($sourceKey + '_' + $cacheRel) -replace '[\\/:*?"<>|]', '_')
    $tmpFile = Join-Path $WorkRoot $tmpName

    if (!$SkipDownload) {
        foreach ($url in $urls) {
            try {
                if (Test-Path -LiteralPath $tmpFile) { Remove-Item -LiteralPath $tmpFile -Force }
                Download-RawFile $url $tmpFile
                Assert-ValidXmlIfNeeded $tmpFile $targetPath

                Ensure-Dir (Split-Path $cachePath -Parent)
                Copy-Item -LiteralPath $tmpFile -Destination $cachePath -Force
                Copy-Item -LiteralPath $tmpFile -Destination $targetPath -Force

                Write-Host "RESTORED FROM GITHUB: $name" -ForegroundColor Green
                return [pscustomobject]@{ Name=$name; Result='github'; Detail=$url; Cache=$cachePath; Target=$targetPath }
            } catch {
                Write-Host "GitHub source failed for ${name}: $($_.Exception.Message)" -ForegroundColor DarkYellow
            }
        }
    } else {
        Write-Host "NoDownload set. Skipping GitHub for $name." -ForegroundColor DarkGray
    }

    if (Test-Path -LiteralPath $cachePath) {
        Assert-ValidXmlIfNeeded $cachePath $targetPath
        Copy-Item -LiteralPath $cachePath -Destination $targetPath -Force
        Write-Host "RESTORED FROM LOCAL CACHE: $name" -ForegroundColor Green
        return [pscustomobject]@{ Name=$name; Result='cache'; Detail=$cachePath; Cache=$cachePath; Target=$targetPath }
    }

    Write-Host "NO GITHUB/CACHE SOURCE: $name. Marker cleanup fallback only." -ForegroundColor Yellow
    return [pscustomobject]@{ Name=$name; Result='fallback_cleanup_only'; Detail='No online source and no local cache.'; Cache=$cachePath; Target=$targetPath }
}

$Profile = Join-Path $KodiRoot 'portable_data'
$Addons = Join-Path $Profile 'addons'
$UserData = Join-Path $Profile 'userdata'
$KpmData = Join-Path $UserData 'addon_data\script.kodi.patch.manager'
$BackupRoot = Join-Path $KpmData ("hard_restore_backups\" + (Get-Date -Format 'yyyyMMdd-HHmmss'))
$CacheRoot = Join-Path $KpmData 'restore_source_cache'
$Work = Join-Path $BackupRoot '_downloads'
Ensure-Dir $BackupRoot
Ensure-Dir $CacheRoot
Ensure-Dir $Work

$Skin = Join-Path $Addons 'skin.arctic.fuse.3'
$TMDb = Join-Path $Addons 'plugin.video.themoviedb.helper'
$SHW = Join-Path $Addons 'script.skin.helper.widgets'

$af3Files = @(
    # A. AF3 Unified Visual Integration
    'Includes_Info.xml',
    'Includes_Layouts.xml',
    'screensaver-arctic-mirage.xml',
    'Includes_Views.xml',
    'Includes_Hubs.xml',
    'Includes_Views_Combined.xml',
    'Includes_Background.xml',
    'Font.xml',
    'DialogExtendedProgressBar.xml',

    # B. Startup Weather and Up Next
    'Includes_Images.xml',

    # C. Screensaver Source
    'Includes_Defaults.xml',

    # D. Pause / Full OSD
    'DialogSeekBar.xml',
    'VideoOSD.xml',
    'Includes_OSD.xml',
    'Includes_Actions.xml',

    # E. Reliable Studio Logos
    'Includes_Furniture.xml',

    # F. Poster Ratio 2:3
    'Includes_Constants.xml'
)

# Read/export-only AF3 files intentionally NOT restored because current KPM 0.2.46 does not patch them:
$af3DiagnosticsOnly = @(
    'Home.xml',
    'MyPrograms.xml',
    'MyVideoNav.xml',
    'Custom_1101_Hub.xml',
    'Custom_1102_Hub.xml',
    'Custom_1103_Hub.xml',
    'Custom_1104_Hub.xml',
    'DialogBusy.xml',
    'Custom_1198_Dialog_Startup.xml',
    'FileBrowser.xml',
    'VideoFullScreen.xml',
    'Includes_Lists.xml',
    'Includes_Widgets.xml'
)

$tmdbFiles = @('resources/tmdbhelper/lib/monitor/imgmon.py','resources/tmdbhelper/lib/monitor/images.py')
$shwFiles = @('resources/lib/media.py')

$targets = @()
foreach ($f in $af3Files) {
    $rel = '1080i/' + $f
    $targets += [pscustomobject]@{
        Name       = "AF3 $f"
        SourceKey  = 'skin.arctic.fuse.3-omega'
        CacheRel   = $rel
        BackupRel  = 'skin.arctic.fuse.3/' + $rel
        TargetPath = Join-Rel $Skin $rel
        Urls       = @("https://raw.githubusercontent.com/jurialmunkey/skin.arctic.fuse.3/omega/$rel")
    }
}
foreach ($rel in $tmdbFiles) {
    $targets += [pscustomobject]@{
        Name       = "TMDbHelper $rel"
        SourceKey  = 'plugin.video.themoviedb.helper-nexus'
        CacheRel   = $rel
        BackupRel  = 'plugin.video.themoviedb.helper/' + $rel
        TargetPath = Join-Rel $TMDb $rel
        Urls       = @("https://raw.githubusercontent.com/jurialmunkey/plugin.video.themoviedb.helper/nexus/$rel")
    }
}
foreach ($rel in $shwFiles) {
    $targets += [pscustomobject]@{
        Name       = "Skin Helper Widgets $rel"
        SourceKey  = 'script.skin.helper.widgets'
        CacheRel   = $rel
        BackupRel  = 'script.skin.helper.widgets/' + $rel
        TargetPath = Join-Rel $SHW $rel
        Urls       = @(
            "https://raw.githubusercontent.com/kodi-community-addons/script.skin.helper.widgets/master/$rel",
            "https://raw.githubusercontent.com/kodi-community-addons/script.skin.helper.widgets/main/$rel"
        )
    }
}

Write-Title "Kodi Patch Manager hard restore"
Write-Host "Kodi root       : $KodiRoot"
Write-Host "Active backup   : $BackupRoot"
Write-Host "Source cache    : $CacheRoot"
Write-Host "Download policy : raw files only; no full repository ZIP"
Write-Host "Current AF3 XML : $($af3Files.Count) files"
Write-Host "Legacy Python   : $($tmdbFiles.Count + $shwFiles.Count) files"
Write-Host "Total targets   : $($targets.Count) files"
Write-Host "Diagnostics-only AF3 XML excluded: $($af3DiagnosticsOnly.Count)"
Write-Host ""
Write-Host "CLOSE KODI before continuing." -ForegroundColor Yellow

Write-Title "Restoring target files"
$results = @()
foreach ($target in $targets) {
    $results += Restore-Target $target $BackupRoot $Work $CacheRoot ([bool]$NoDownload)
}

Write-Title "Marker cleanup fallback"
foreach ($target in $targets) {
    $null = Marker-Cleanup $target.TargetPath
}

Write-Title "Clearing Python compiled cache"
$pycacheDeleted = @()
$pycacheDeleted += Clear-PythonCacheTree (Join-Path $TMDb 'resources\tmdbhelper\lib') $BackupRoot 'plugin.video.themoviedb.helper\resources\tmdbhelper\lib'
$pycacheDeleted += Clear-PythonCacheTree (Join-Path $SHW 'resources\lib') $BackupRoot 'script.skin.helper.widgets\resources\lib'

Write-Title "Scanning for remaining KPM markers"
$scanRoots = @(
    (Join-Path $Skin '1080i'),
    (Join-Path $TMDb 'resources\tmdbhelper\lib'),
    (Join-Path $SHW 'resources\lib')
)
$patterns = @('KPM','Kodi Patch Manager','KPM.Fanart','KPM.Studio','KPM-','LibraryRatings')
$hits = @()
foreach ($root in $scanRoots) {
    if (!(Test-Path -LiteralPath $root)) { continue }
    foreach ($file in Get-ChildItem -LiteralPath $root -Recurse -File -Include *.xml,*.py -ErrorAction SilentlyContinue) {
        try {
            $txt = Get-Content -LiteralPath $file.FullName -Raw -ErrorAction Stop
            foreach ($pat in $patterns) {
                if ($txt -like "*$pat*") {
                    $hits += "$($file.FullName) :: $pat"
                    break
                }
            }
        } catch {}
    }
}

$summaryLines = @()
foreach ($group in ($results | Group-Object Result)) {
    $summaryLines += ("{0}: {1}" -f $group.Name, $group.Count)
}

$report = Join-Path $BackupRoot 'restore-report.txt'
$detailLines = @()
foreach ($r in $results) {
    $detailLines += ("[{0}] {1}" -f $r.Result, $r.Name)
    $detailLines += ("  Target: {0}" -f $r.Target)
    $detailLines += ("  Source: {0}" -f $r.Detail)
    $detailLines += ("  Cache : {0}" -f $r.Cache)
}

@(
    "Kodi Patch Manager hard restore report",
    "Time: $(Get-Date)",
    "KodiRoot: $KodiRoot",
    "Active backup: $BackupRoot",
    "Source cache: $CacheRoot",
    "Download policy: raw files only; no full repository ZIP",
    "NoDownload/cache-only mode: $([bool]$NoDownload)",
    "Current AF3 XML target count: $($af3Files.Count)",
    "Legacy Python target count: $($tmdbFiles.Count + $shwFiles.Count)",
    "Diagnostics-only AF3 XML excluded: $($af3DiagnosticsOnly.Count)",
    "",
    "Current AF3 XML targets:",
    (($af3Files | ForEach-Object { "1080i/$_" }) -join "`r`n"),
    "",
    "Diagnostics-only AF3 XML not restored:",
    (($af3DiagnosticsOnly | ForEach-Object { "1080i/$_" }) -join "`r`n"),
    "",
    "Summary:",
    ($summaryLines -join "`r`n"),
    "Python cache deleted: $($pycacheDeleted.Count)",
    "",
    "Per-file results:",
    ($detailLines -join "`r`n"),
    "",
    "Deleted Python cache files:",
    ($pycacheDeleted -join "`r`n"),
    "",
    "Remaining marker scan:",
    ($hits -join "`r`n")
) | Set-Content -LiteralPath $report -Encoding UTF8

if ($hits.Count -gt 0) {
    Write-Host "Remaining marker-like text found. See report:" -ForegroundColor Yellow
    Write-Host $report
    Write-Host "Note: LibraryRatings entries can be from older LRS integration/baseline, not necessarily KPM." -ForegroundColor Yellow
} else {
    Write-Host "No KPM marker-like text found in scanned target paths." -ForegroundColor Green
}

Write-Title "Done"
Write-Host "Summary:" -ForegroundColor Cyan
foreach ($line in $summaryLines) { Write-Host "  $line" }
Write-Host "  Python cache deleted: $($pycacheDeleted.Count)"
Write-Host "Restart Kodi after this restore."
Write-Host "Active backup folder: $BackupRoot"
Write-Host "Clean source cache : $CacheRoot"
Write-Host "Report             : $report"
