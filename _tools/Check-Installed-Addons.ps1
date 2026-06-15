# Check installed Kodi add-ons and their actual addon.xml versions.
# Run from D:\Others\KodiRepo\CHECK-INSTALLED-ADDONS.bat
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

if (-not $KodiAddonsPaths -or $KodiAddonsPaths.Count -eq 0) {
    $KodiAddonsPaths = @(
        'E:\Kodi\portable_data\addons',
        'E:\Kodi\addons',
        "$env:APPDATA\Kodi\addons"
    )
}

$AddonListFile = Join-Path $RepoRoot 'repo-addons.txt'
if (-not (Test-Path $AddonListFile)) {
    throw "repo-addons.txt not found: $AddonListFile"
}

$TargetAddonIds = Get-Content -LiteralPath $AddonListFile -Encoding UTF8 |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and -not $_.StartsWith('#') }

function Read-AddonXml($path) {
    [xml]$xml = Get-Content -LiteralPath $path -Encoding UTF8
    return $xml
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

Write-Host "Kodi add-on search paths:" -ForegroundColor Cyan
$KodiAddonsPaths | ForEach-Object { Write-Host "  - $_" }
Write-Host ""
Write-Host "Actual installed add-ons:" -ForegroundColor Cyan

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add("Kodi repository installed add-ons check - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
$lines.Add("Repo root: $RepoRoot")
$lines.Add("")

foreach ($addonId in $TargetAddonIds) {
    $source = Find-InstalledAddon $addonId
    if (-not $source) {
        $msg = "MISSING  $addonId"
        Write-Host "  $msg" -ForegroundColor Yellow
        $lines.Add($msg)
        continue
    }
    $addonXmlPath = Join-Path $source 'addon.xml'
    $xml = Read-AddonXml $addonXmlPath
    $actualId = [string]$xml.addon.id
    $version = [string]$xml.addon.version
    $name = [string]$xml.addon.name
    if ($actualId -ne $addonId) {
        $msg = "MISMATCH $addonId -> folder addon.xml id is '$actualId' v$version | $source"
        Write-Host "  $msg" -ForegroundColor Red
        $lines.Add($msg)
    } else {
        $msg = "FOUND    $addonId v$version | $name | $source"
        Write-Host "  $msg" -ForegroundColor Green
        $lines.Add($msg)
    }
}

$reportPath = Join-Path $RepoRoot 'installed-addons-report.txt'
Set-Content -LiteralPath $reportPath -Value ($lines -join "`r`n") -Encoding UTF8
Write-Host ""
Write-Host "Report saved:" -ForegroundColor Cyan
Write-Host "  $reportPath"
Write-Host ""
Write-Host "Note: Build-Repo.ps1 uses the same addon.xml versions shown above. No version is hardcoded." -ForegroundColor Cyan
