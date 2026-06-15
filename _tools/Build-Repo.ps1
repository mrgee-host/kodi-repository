param(
    [string]$RepoRoot = "",
    [string[]]$AddonSearchPaths = @(
        "E:\Kodi\portable_data\addons",
        "E:\Kodi\addons",
        "$env:APPDATA\Kodi\addons"
    )
)

$ErrorActionPreference = "Stop"
function Normalize-PathArg([string]$p) { if ([string]::IsNullOrWhiteSpace($p)) { return $p }; return $p.Trim().Trim('"') }
function Get-DefaultRepoRoot { $scriptDir = Split-Path -Parent $PSCommandPath; if ((Split-Path -Leaf $scriptDir) -ieq "_tools") { return (Resolve-Path (Join-Path $scriptDir "..")).Path }; return (Resolve-Path $scriptDir).Path }
function Compress-FolderToZip([string]$sourceDir, [string]$destZip) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
    if (Test-Path -LiteralPath $destZip) { Remove-Item -LiteralPath $destZip -Force }
    $temp = Join-Path ([System.IO.Path]::GetTempPath()) ("kodi_addon_zip_" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $temp | Out-Null
    try {
        $copyDest = Join-Path $temp (Split-Path -Leaf $sourceDir)
        Copy-Item -LiteralPath $sourceDir -Destination $copyDest -Recurse -Force
        [System.IO.Compression.ZipFile]::CreateFromDirectory($temp, $destZip)
    }
    finally {
        if (Test-Path -LiteralPath $temp) { Remove-Item -LiteralPath $temp -Recurse -Force }
    }
}

$scriptDir = Split-Path -Parent $PSCommandPath
$RepoRoot = Normalize-PathArg $RepoRoot
if ([string]::IsNullOrWhiteSpace($RepoRoot)) { $RepoRoot = Get-DefaultRepoRoot }
$RepoRoot = (Resolve-Path $RepoRoot).Path

$targetFile = Join-Path $RepoRoot "repo-addons.txt"
if (-not (Test-Path -LiteralPath $targetFile)) { throw "repo-addons.txt tidak ditemukan di $RepoRoot" }
$targets = Get-Content -LiteralPath $targetFile | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith("#") }

Write-Host "[repo] Repo root:" $RepoRoot
Write-Host "[repo] Kodi addon search paths:"
foreach ($p in $AddonSearchPaths) { Write-Host "  - $p" }
Write-Host "[repo] Packaging add-ons..."

$packaged = @()
$skipped = @()
foreach ($id in $targets) {
    $src = $null
    foreach ($base in $AddonSearchPaths) {
        $candidate = Join-Path $base $id
        if (Test-Path -LiteralPath (Join-Path $candidate "addon.xml")) { $src = $candidate; break }
    }
    if (-not $src) {
        Write-Host "[skip] $id not found in Kodi add-ons folders"
        $skipped += $id
        continue
    }
    [xml]$xml = Get-Content -LiteralPath (Join-Path $src "addon.xml") -Raw
    $ver = [string]$xml.addon.version
    $destDir = Join-Path $RepoRoot $id
    if (-not (Test-Path -LiteralPath $destDir)) { New-Item -ItemType Directory -Path $destDir | Out-Null }
    Get-ChildItem -LiteralPath $destDir -Filter "$id-*.zip" -File -ErrorAction SilentlyContinue | Remove-Item -Force
    $destZip = Join-Path $destDir "$id-$ver.zip"
    Compress-FolderToZip $src $destZip
    Write-Host "  OK $id v$ver"
    $packaged += "$id v$ver"
}

& (Join-Path $scriptDir "Update-Repo-Index.ps1") -RepoRoot $RepoRoot

Write-Host ""
Write-Host "Build complete."
if ($packaged.Count) { Write-Host "Packaged:"; foreach ($p in $packaged) { Write-Host "  - $p" } }
if ($skipped.Count) { Write-Host "Skipped:"; foreach ($s in $skipped) { Write-Host "  - $s" } }
