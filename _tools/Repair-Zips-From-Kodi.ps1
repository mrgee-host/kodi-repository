param(
    [string]$RepoRoot = "",
    [switch]$Upload
)

$ErrorActionPreference = "Stop"

function Resolve-RepoRoot([string]$PathValue) {
    if ([string]::IsNullOrWhiteSpace($PathValue)) {
        $scriptDir = Split-Path -Parent $PSCommandPath
        return (Resolve-Path (Join-Path $scriptDir "..")).Path
    }
    return (Resolve-Path ($PathValue.Trim().Trim('"').Trim("'"))).Path
}

function Copy-DirectoryContent([string]$SourceDir, [string]$DestDir) {
    New-Item -ItemType Directory -Force -Path $DestDir | Out-Null
    Get-ChildItem -LiteralPath $SourceDir -Force | ForEach-Object {
        $dest = Join-Path $DestDir $_.Name
        if ($_.PSIsContainer) { Copy-Item -LiteralPath $_.FullName -Destination $dest -Recurse -Force }
        else { Copy-Item -LiteralPath $_.FullName -Destination $dest -Force }
    }
}

function New-NormalizedAddonZip([string]$SourceAddonDir, [string]$AddonId, [string]$OutputZip) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem | Out-Null
    if (Test-Path -LiteralPath $OutputZip) { Remove-Item -LiteralPath $OutputZip -Force }
    $stageParent = Join-Path ([System.IO.Path]::GetTempPath()) ("kodirepo_zip_" + [guid]::NewGuid().ToString("N"))
    $stageAddon = Join-Path $stageParent $AddonId
    New-Item -ItemType Directory -Force -Path $stageAddon | Out-Null
    Copy-DirectoryContent $SourceAddonDir $stageAddon
    [System.IO.Compression.ZipFile]::CreateFromDirectory($stageParent, $OutputZip, [System.IO.Compression.CompressionLevel]::Optimal, $false)
    Remove-Item -LiteralPath $stageParent -Recurse -Force
}

function Read-Targets([string]$RepoRoot) {
    $targetFile = Join-Path $RepoRoot "repo-addons.txt"
    if (Test-Path -LiteralPath $targetFile) {
        return @(Get-Content -LiteralPath $targetFile | ForEach-Object { $_.Trim() } | Where-Object { $_ -and -not $_.StartsWith('#') })
    }
    return @("script.artwork.curator", "script.library.ratings.scraper", "context.tpdb.artwork", "script.akl.texture.cache.cleaner", "plugin.program.steam.collections")
}

$RepoRoot = Resolve-RepoRoot $RepoRoot
$toolDir = Split-Path -Parent $PSCommandPath
$searchPaths = @(
    "E:\Kodi\portable_data\addons",
    "E:\Kodi\addons",
    (Join-Path $env:APPDATA "Kodi\addons")
) | Where-Object { $_ -and (Test-Path -LiteralPath $_) }

Write-Host "[repair] Repo root: $RepoRoot"
Write-Host "[repair] Kodi addon search paths:"
$searchPaths | ForEach-Object { Write-Host "  - $_" }

$targets = Read-Targets $RepoRoot
$packaged = @()
$skipped = @()
foreach ($id in $targets) {
    $src = $null
    foreach ($base in $searchPaths) {
        $candidate = Join-Path $base $id
        if (Test-Path -LiteralPath (Join-Path $candidate "addon.xml")) { $src = $candidate; break }
    }
    if ($null -eq $src) {
        Write-Host "[skip] $id not found in Kodi add-ons folders"
        $skipped += $id
        continue
    }
    [xml]$xml = [System.IO.File]::ReadAllText((Join-Path $src "addon.xml"), [System.Text.Encoding]::UTF8)
    $version = [string]$xml.addon.version
    $realId = [string]$xml.addon.id
    $destDir = Join-Path $RepoRoot $realId
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
    Get-ChildItem -LiteralPath $destDir -Filter "*.zip" -File -ErrorAction SilentlyContinue | Remove-Item -Force
    $destZip = Join-Path $destDir ("$realId-$version.zip")
    New-NormalizedAddonZip -SourceAddonDir $src -AddonId $realId -OutputZip $destZip
    Write-Host "  OK $realId v$version"
    $packaged += "$realId v$version"
}

& (Join-Path $toolDir "Update-Repo-Index.ps1") -RepoRoot $RepoRoot
if ($LASTEXITCODE -ne 0) { throw "Update-Repo-Index gagal." }

Write-Host ""
Write-Host "Repair complete."
if ($packaged.Count -gt 0) { Write-Host "Packaged:"; $packaged | ForEach-Object { Write-Host "  - $_" } }
if ($skipped.Count -gt 0) { Write-Host "Skipped:"; $skipped | ForEach-Object { Write-Host "  - $_" } }

if ($Upload) {
    & (Join-Path $toolDir "Upload-Repo.ps1") -RepoRoot $RepoRoot -Message "Repair Kodi repository zips"
}
