param(
    [Parameter(Mandatory=$true)][string]$RepoRoot,
    [Parameter(Mandatory=$true)][string]$ZipPath
)

$ErrorActionPreference = 'Stop'

function Clean-PathArg([string]$p) {
    if ($null -eq $p) { return $p }
    return $p.Trim().Trim('"')
}

function Ensure-ZipFileSystem {
    if (-not ([System.Management.Automation.PSTypeName]'System.IO.Compression.ZipFile').Type) {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }
}

function Copy-DirectoryContents($Source, $Destination) {
    if (-not (Test-Path $Destination)) { New-Item -ItemType Directory -Force -Path $Destination | Out-Null }
    Get-ChildItem -LiteralPath $Source -Force | ForEach-Object {
        $dest = Join-Path $Destination $_.Name
        if ($_.PSIsContainer) {
            Copy-Item -LiteralPath $_.FullName -Destination $dest -Recurse -Force
        } else {
            Copy-Item -LiteralPath $_.FullName -Destination $dest -Force
        }
    }
}

$RepoRoot = Clean-PathArg $RepoRoot
$ZipPath = Clean-PathArg $ZipPath
$RepoRoot = (Resolve-Path $RepoRoot).Path
$ZipPath = (Resolve-Path $ZipPath).Path

if ([IO.Path]::GetExtension($ZipPath).ToLowerInvariant() -ne '.zip') {
    throw "Not a zip file: $ZipPath"
}

Ensure-ZipFileSystem
$temp = Join-Path $env:TEMP ("kodi_import_" + [Guid]::NewGuid().ToString('N'))
$norm = Join-Path $env:TEMP ("kodi_norm_" + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Force -Path $temp | Out-Null
New-Item -ItemType Directory -Force -Path $norm | Out-Null

try {
    [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipPath, $temp)

    $addonXml = Get-ChildItem -LiteralPath $temp -Filter addon.xml -Recurse -Force |
        Where-Object { $_.FullName -notmatch '__MACOSX' } |
        Select-Object -First 1

    if (-not $addonXml) {
        throw "addon.xml not found inside zip: $ZipPath"
    }

    [xml]$xml = Get-Content -LiteralPath $addonXml.FullName -Raw
    $id = [string]$xml.addon.id
    $version = [string]$xml.addon.version

    if ([string]::IsNullOrWhiteSpace($id)) { throw "addon id missing in addon.xml" }
    if ([string]::IsNullOrWhiteSpace($version)) { throw "addon version missing in addon.xml" }

    $addonRoot = $addonXml.Directory.FullName
    $normAddon = Join-Path $norm $id
    New-Item -ItemType Directory -Force -Path $normAddon | Out-Null
    Copy-DirectoryContents -Source $addonRoot -Destination $normAddon

    $targetDir = Join-Path $RepoRoot $id
    New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

    # Remove older zips for the same addon id only.
    Get-ChildItem -LiteralPath $targetDir -Filter "$id-*.zip" -File -ErrorAction SilentlyContinue | ForEach-Object {
        Remove-Item -LiteralPath $_.FullName -Force
    }

    $targetZip = Join-Path $targetDir ("$id-$version.zip")
    if (Test-Path $targetZip) { Remove-Item -LiteralPath $targetZip -Force }

    [System.IO.Compression.ZipFile]::CreateFromDirectory($norm, $targetZip)
    Write-Host "[import] $id v$version -> $targetZip" -ForegroundColor Green

    & (Join-Path $PSScriptRoot 'Update-Repo-Index.ps1') -RepoRoot $RepoRoot
    if ($LASTEXITCODE -ne 0) { throw "Update-Repo-Index failed." }
}
finally {
    if (Test-Path $temp) { Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue }
    if (Test-Path $norm) { Remove-Item -LiteralPath $norm -Recurse -Force -ErrorAction SilentlyContinue }
}
