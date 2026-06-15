# MrGee Kodi Repository Builder
# Run this from D:\Others\KodiRepo\_tools\Build-Repo.bat or directly with PowerShell.
# It packages the latest installed add-ons from your Kodi folders into a GitHub Pages Kodi repository.

param(
    [string]$RepoRoot,
    [string[]]$KodiAddonsPaths
)

$ErrorActionPreference = 'Stop'

function Resolve-CleanPath([string]$PathValue, [string]$FallbackPath) {
    if ([string]::IsNullOrWhiteSpace($PathValue)) { $PathValue = $FallbackPath }
    $PathValue = ([string]$PathValue).Trim().Trim('"').Trim("'")
    if ([string]::IsNullOrWhiteSpace($PathValue)) { $PathValue = $FallbackPath }
    return (Resolve-Path -LiteralPath $PathValue).Path
}

function Clean-PathString([string]$PathValue) {
    if ([string]::IsNullOrWhiteSpace($PathValue)) { return $PathValue }
    return ([string]$PathValue).Trim().Trim('"').Trim("'")
}

$RepoRoot = Resolve-CleanPath $RepoRoot (Join-Path $PSScriptRoot '..')

$RepoId = 'repository.mrgee.kodi'
$RepoName = 'MrGee Kodi Repository'
$RepoVersion = '1.0.0'
$ProviderName = 'Miftahul Ginda / MrGee'
$BaseUrl = 'https://mrgee-host.github.io/kodi-repository'

if (-not $KodiAddonsPaths -or $KodiAddonsPaths.Count -eq 0) {
    $KodiAddonsPaths = @(
        'E:\Kodi\portable_data\addons',
        'E:\Kodi\addons',
        "$env:APPDATA\Kodi\addons"
    )
}

function Write-Step($msg) { Write-Host "[repo] $msg" -ForegroundColor Cyan }
function Write-Warn($msg) { Write-Host "[skip] $msg" -ForegroundColor Yellow }
function Ensure-Dir($path) { if (-not (Test-Path $path)) { New-Item -ItemType Directory -Path $path | Out-Null } }

function Get-AddonVersion($addonXmlPath) {
    [xml]$xml = Get-Content -LiteralPath $addonXmlPath -Encoding UTF8
    return [string]$xml.addon.version
}

function Get-AddonId($addonXmlPath) {
    [xml]$xml = Get-Content -LiteralPath $addonXmlPath -Encoding UTF8
    return [string]$xml.addon.id
}

function Find-InstalledAddon($addonId) {
    foreach ($base in $KodiAddonsPaths) {
        $base = Clean-PathString $base
        if ([string]::IsNullOrWhiteSpace($base)) { continue }
        $candidate = Join-Path $base $addonId
        if (Test-Path (Join-Path $candidate 'addon.xml')) {
            return (Resolve-Path $candidate).Path
        }
    }
    return $null
}

function Copy-AddonClean($Source, $Dest) {
    if (Test-Path $Dest) { Remove-Item -LiteralPath $Dest -Recurse -Force }
    Ensure-Dir $Dest
    $Source = (Resolve-Path $Source).Path
    $skipDirs = @('__pycache__', '.git', '.svn', '.hg', '.idea', '.vscode', 'node_modules')
    $skipExts = @('.pyc', '.pyo')

    Get-ChildItem -LiteralPath $Source -Recurse -Force | ForEach-Object {
        $rel = $_.FullName.Substring($Source.Length).TrimStart('\','/')
        if ([string]::IsNullOrWhiteSpace($rel)) { return }
        $parts = $rel -split '[\\/]'
        foreach ($sd in $skipDirs) {
            if ($parts -contains $sd) { return }
        }
        if (-not $_.PSIsContainer -and ($skipExts -contains $_.Extension.ToLowerInvariant())) { return }
        $target = Join-Path $Dest $rel
        if ($_.PSIsContainer) {
            Ensure-Dir $target
        } else {
            Ensure-Dir (Split-Path $target -Parent)
            Copy-Item -LiteralPath $_.FullName -Destination $target -Force
        }
    }
}

function New-ZipWithRootFolder($SourceFolder, $DestinationZip) {
    if (Test-Path $DestinationZip) { Remove-Item -LiteralPath $DestinationZip -Force }
    $parent = Split-Path $SourceFolder -Parent
    $leaf = Split-Path $SourceFolder -Leaf
    # Safer: build to a temp zip outside SourceFolder, then move into place.
    # This avoids repository.mrgee.kodi-1.0.0.zip being zipped into itself.
    $tempZip = Join-Path ([System.IO.Path]::GetTempPath()) (([System.Guid]::NewGuid().ToString()) + '.zip')
    Push-Location $parent
    try {
        Compress-Archive -Path $leaf -DestinationPath $tempZip -CompressionLevel Optimal -Force
    } finally {
        Pop-Location
    }
    Ensure-Dir (Split-Path $DestinationZip -Parent)
    Move-Item -LiteralPath $tempZip -Destination $DestinationZip -Force
}

function Get-AddonXmlForRepository($addonXmlPath) {
    $text = Get-Content -LiteralPath $addonXmlPath -Raw -Encoding UTF8
    $text = $text -replace '^\s*<\?xml[^>]*\?>\s*', ''
    return $text.Trim() + "`n"
}

Write-Step "Repo root: $RepoRoot"
Write-Step "Kodi addon search paths:"
$KodiAddonsPaths | ForEach-Object { Write-Host "  - $_" }

# Prepare repository add-on folder
$RepoAddonDir = Join-Path $RepoRoot $RepoId
Ensure-Dir $RepoAddonDir

$RepoAddonXml = @"
<?xml version="1.0" encoding="UTF-8"?>
<addon id="$RepoId" name="$RepoName" version="$RepoVersion" provider-name="$ProviderName">
    <extension point="xbmc.addon.repository" name="$RepoName">
        <dir minversion="20.0.0">
            <info compressed="false">$BaseUrl/addons.xml</info>
            <checksum>$BaseUrl/addons.xml.md5</checksum>
            <datadir zip="true">$BaseUrl/</datadir>
            <hashes>false</hashes>
        </dir>
    </extension>
    <extension point="xbmc.addon.metadata">
        <summary lang="en_GB">$RepoName</summary>
        <description lang="en_GB">Private Kodi repository for MrGee custom addons.</description>
        <platform>all</platform>
        <license>MIT</license>
        <assets>
            <icon>icon.png</icon>
            <fanart>fanart.jpg</fanart>
        </assets>
    </extension>
</addon>
"@
Set-Content -LiteralPath (Join-Path $RepoAddonDir 'addon.xml') -Value $RepoAddonXml -Encoding UTF8

# Keep existing assets if present. Create tiny fallback files only if missing.
if (-not (Test-Path (Join-Path $RepoAddonDir 'icon.png'))) {
    Write-Warn "icon.png missing; using existing pack icon is recommended."
}
if (-not (Test-Path (Join-Path $RepoAddonDir 'fanart.jpg'))) {
    Write-Warn "fanart.jpg missing; using existing pack fanart is recommended."
}

$TempRoot = Join-Path $RepoRoot '_tmp_build'
if (Test-Path $TempRoot) { Remove-Item -LiteralPath $TempRoot -Recurse -Force }
Ensure-Dir $TempRoot

# Zip the repository addon itself
$RepoAddonZip = Join-Path $RepoAddonDir "$RepoId-$RepoVersion.zip"
New-ZipWithRootFolder -SourceFolder $RepoAddonDir -DestinationZip $RepoAddonZip

$addonsXmlParts = New-Object System.Collections.Generic.List[string]
$addonsXmlParts.Add((Get-AddonXmlForRepository (Join-Path $RepoAddonDir 'addon.xml')))

# Load target addon list
$AddonListFile = Join-Path $RepoRoot 'repo-addons.txt'
if (-not (Test-Path $AddonListFile)) {
    @('script.artwork.curator','script.library.ratings.scraper','context.tpdb.artwork','script.akl.texture.cache.cleaner','plugin.program.steam.collections') | Set-Content -LiteralPath $AddonListFile -Encoding UTF8
}
$TargetAddonIds = Get-Content -LiteralPath $AddonListFile -Encoding UTF8 |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and -not $_.StartsWith('#') }

Write-Step "Packaging add-ons..."
$packaged = @()
$skipped = @()
foreach ($addonId in $TargetAddonIds) {
    if ($addonId -eq $RepoId) { continue }
    $source = Find-InstalledAddon $addonId
    if (-not $source) {
        Write-Warn "$addonId not found in Kodi add-ons folders"
        $skipped += $addonId
        continue
    }

    $sourceXml = Join-Path $source 'addon.xml'
    $actualId = Get-AddonId $sourceXml
    if ($actualId -ne $addonId) {
        Write-Warn "$addonId folder contains addon id '$actualId'; skipped for safety"
        $skipped += $addonId
        continue
    }
    $ver = Get-AddonVersion $sourceXml

    $outDir = Join-Path $RepoRoot $addonId
    Ensure-Dir $outDir
    # Remove old zips for the same addon id, so repo doesn't keep obsolete versions forever.
    Get-ChildItem -LiteralPath $outDir -Filter "$addonId-*.zip" -ErrorAction SilentlyContinue | Remove-Item -Force

    $staged = Join-Path $TempRoot $addonId
    Copy-AddonClean -Source $source -Dest $staged

    $zipPath = Join-Path $outDir "$addonId-$ver.zip"
    New-ZipWithRootFolder -SourceFolder $staged -DestinationZip $zipPath
    $addonsXmlParts.Add((Get-AddonXmlForRepository (Join-Path $staged 'addon.xml')))
    $packaged += "$addonId v$ver"
    Write-Host "  OK $addonId v$ver" -ForegroundColor Green
}

$addonsXml = "<addons>`n" + (($addonsXmlParts -join "`n").Trim()) + "`n</addons>`n"
$addonsXmlPath = Join-Path $RepoRoot 'addons.xml'
Set-Content -LiteralPath $addonsXmlPath -Value $addonsXml -Encoding UTF8

$md5 = [System.BitConverter]::ToString([System.Security.Cryptography.MD5]::Create().ComputeHash([System.Text.Encoding]::UTF8.GetBytes($addonsXml))).Replace('-','').ToLowerInvariant()
Set-Content -LiteralPath (Join-Path $RepoRoot 'addons.xml.md5') -Value $md5 -Encoding ASCII

Set-Content -LiteralPath (Join-Path $RepoRoot '.nojekyll') -Value '' -Encoding ASCII

$IndexHtml = @"
<!doctype html>
<html><head><meta charset="utf-8"><title>$RepoName</title></head>
<body style="font-family:Arial,sans-serif;background:#101722;color:#eef4ff;padding:30px">
<h1>$RepoName</h1>
<p>Kodi repository files.</p>
<ul>
<li><a href="addons.xml">addons.xml</a></li>
<li><a href="addons.xml.md5">addons.xml.md5</a></li>
<li><a href="$RepoId/$RepoId-$RepoVersion.zip">Install repository zip</a></li>
</ul>
</body></html>
"@
Set-Content -LiteralPath (Join-Path $RepoRoot 'index.html') -Value $IndexHtml -Encoding UTF8

if (Test-Path $TempRoot) { Remove-Item -LiteralPath $TempRoot -Recurse -Force }

Write-Host ""
Write-Host "Build complete." -ForegroundColor Green
Write-Host "Packaged:" -ForegroundColor Cyan
if ($packaged.Count -eq 0) { Write-Host "  none" -ForegroundColor Yellow } else { $packaged | ForEach-Object { Write-Host "  - $_" } }
if ($skipped.Count -gt 0) {
    Write-Host "Skipped:" -ForegroundColor Yellow
    $skipped | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
}
Write-Host ""
Write-Host "Repository install zip:" -ForegroundColor Cyan
Write-Host "  $RepoAddonZip"
Write-Host ""
Write-Host "After upload, GitHub Pages URL should be:" -ForegroundColor Cyan
Write-Host "  $BaseUrl/"
