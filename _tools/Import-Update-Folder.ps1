param(
    [string]$InputDir = "",
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

$RepoRoot = Resolve-RepoRoot $RepoRoot
$toolDir = Split-Path -Parent $PSCommandPath
if ([string]::IsNullOrWhiteSpace($InputDir)) { $InputDir = Join-Path $RepoRoot "_incoming_addons" }
$InputDir = (Resolve-Path ($InputDir.Trim().Trim('"').Trim("'"))).Path

$zips = @(Get-ChildItem -LiteralPath $InputDir -Filter "*.zip" -File -ErrorAction SilentlyContinue)
if ($zips.Count -eq 0) { throw "Tidak ada file .zip di $InputDir" }

foreach ($zip in $zips) {
    & (Join-Path $toolDir "Import-Addon-Zip.ps1") -RepoRoot $RepoRoot -ZipPath $zip.FullName
    if ($LASTEXITCODE -ne 0) { throw "Import gagal: $($zip.FullName)" }
}

& (Join-Path $toolDir "Update-Repo-Index.ps1") -RepoRoot $RepoRoot
if ($LASTEXITCODE -ne 0) { throw "Update-Repo-Index gagal." }

if ($Upload) {
    & (Join-Path $toolDir "Upload-Repo.ps1") -RepoRoot $RepoRoot -Message "Import addon update pack"
}
