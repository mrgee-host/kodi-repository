param(
    [Parameter(Mandatory=$true)]
    [string]$ZipPath,
    [Parameter(Mandatory=$true)]
    [string]$RepoRoot
)

$ErrorActionPreference = "Stop"

function Clean-PathArg([string]$p) {
    if ($null -eq $p) { return $p }
    return $p.Trim().Trim('"')
}

function Copy-DirectoryContents([string]$SourceDir, [string]$DestDir) {
    New-Item -ItemType Directory -Force -Path $DestDir | Out-Null
    Get-ChildItem -LiteralPath $SourceDir -Force | ForEach-Object {
        $dest = Join-Path $DestDir $_.Name
        if ($_.PSIsContainer) {
            Copy-Item -LiteralPath $_.FullName -Destination $dest -Recurse -Force
        } else {
            Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
        }
    }
}

$ZipPath = Clean-PathArg $ZipPath
$RepoRoot = Clean-PathArg $RepoRoot
$ZipPath = (Resolve-Path -LiteralPath $ZipPath).Path
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$toolDir = Split-Path -Parent $MyInvocation.MyCommand.Path

$tmp = Join-Path $env:TEMP ("kodi_repo_import_" + [guid]::NewGuid().ToString("N"))
$extractDir = Join-Path $tmp "extract"
$zipRoot = Join-Path $tmp "ziproot"
New-Item -ItemType Directory -Force -Path $extractDir, $zipRoot | Out-Null

try {
    Expand-Archive -LiteralPath $ZipPath -DestinationPath $extractDir -Force

    $addonXmlFile = Get-ChildItem -LiteralPath $extractDir -Recurse -File -Filter "addon.xml" -ErrorAction SilentlyContinue |
        Sort-Object { $_.FullName.Length } |
        Select-Object -First 1

    if (-not $addonXmlFile) {
        throw "addon.xml tidak ditemukan di dalam zip: $ZipPath"
    }

    [xml]$addonXml = Get-Content -LiteralPath $addonXmlFile.FullName -Raw -Encoding UTF8
    if (-not $addonXml.addon -or -not $addonXml.addon.id -or -not $addonXml.addon.version) {
        throw "addon.xml tidak valid: $($addonXmlFile.FullName)"
    }

    $id = [string]$addonXml.addon.id
    $version = [string]$addonXml.addon.version
    $addonSourceRoot = Split-Path -Parent $addonXmlFile.FullName

    $normalizedAddonRoot = Join-Path $zipRoot $id
    if (Test-Path -LiteralPath $normalizedAddonRoot) { Remove-Item -LiteralPath $normalizedAddonRoot -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $normalizedAddonRoot | Out-Null
    Copy-DirectoryContents $addonSourceRoot $normalizedAddonRoot

    $destFolder = Join-Path $RepoRoot $id
    New-Item -ItemType Directory -Force -Path $destFolder | Out-Null

    # Remove old versions for same add-on, to avoid Kodi/index confusion.
    Get-ChildItem -LiteralPath $destFolder -File -Filter "$id-*.zip" -ErrorAction SilentlyContinue |
        Remove-Item -Force -ErrorAction SilentlyContinue

    $destZip = Join-Path $destFolder ("$id-$version.zip")
    if (Test-Path -LiteralPath $destZip) { Remove-Item -LiteralPath $destZip -Force }

    Compress-Archive -LiteralPath $normalizedAddonRoot -DestinationPath $destZip -Force
    Write-Host "[import] $id v$version -> $destZip"
}
finally {
    Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
}

& (Join-Path $toolDir "Update-Repo-Index.ps1") -RepoRoot $RepoRoot
if ($LASTEXITCODE -ne 0) { throw "Update-Repo-Index gagal." }
