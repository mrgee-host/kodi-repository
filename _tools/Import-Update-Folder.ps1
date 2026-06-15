param(
    [string]$FolderPath = "",
    [string]$RepoRoot = "",
    [switch]$Upload,
    [switch]$KeepOld
)

$ErrorActionPreference = "Stop"
function Normalize-PathArg([string]$p) {
    if ([string]::IsNullOrWhiteSpace($p)) { return $p }
    return $p.Trim().Trim('"')
}
function Get-DefaultRepoRoot {
    $scriptDir = Split-Path -Parent $PSCommandPath
    if ((Split-Path -Leaf $scriptDir) -ieq "_tools") { return (Resolve-Path (Join-Path $scriptDir "..")).Path }
    return (Resolve-Path $scriptDir).Path
}

$scriptDir = Split-Path -Parent $PSCommandPath
$RepoRoot = Normalize-PathArg $RepoRoot
if ([string]::IsNullOrWhiteSpace($RepoRoot)) { $RepoRoot = Get-DefaultRepoRoot }
$RepoRoot = (Resolve-Path $RepoRoot).Path

$FolderPath = Normalize-PathArg $FolderPath
if ([string]::IsNullOrWhiteSpace($FolderPath)) {
    $FolderPath = Join-Path $RepoRoot "_incoming_addons"
}
$resolved = (Resolve-Path $FolderPath).Path

$zipFiles = @()
$tempDir = $null

if (Test-Path -LiteralPath $resolved -PathType Container) {
    $zipFiles = Get-ChildItem -LiteralPath $resolved -Recurse -Filter "*.zip" -File | Select-Object -ExpandProperty FullName
}
elseif (Test-Path -LiteralPath $resolved -PathType Leaf) {
    # If a single file is dropped, pass it to importer. It can be an addon zip.
    $zipFiles = @($resolved)
}
else {
    throw "Folder/file tidak ditemukan: $FolderPath"
}

if (-not $zipFiles -or $zipFiles.Count -eq 0) {
    throw "Tidak ada file .zip di: $resolved"
}

Write-Host "[import-folder] Found zip files:" $zipFiles.Count
foreach ($z in $zipFiles) { Write-Host "  - $z" }

$argsList = @()
$argsList += $zipFiles
$argsList += "-RepoRoot"; $argsList += $RepoRoot
if ($Upload) { $argsList += "-Upload" }
if ($KeepOld) { $argsList += "-KeepOld" }

& (Join-Path $scriptDir "Import-Addon-Zip.ps1") @argsList
