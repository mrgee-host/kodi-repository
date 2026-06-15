param(
    [Parameter(Mandatory=$true)]
    [string]$RepoRoot
)
$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path -LiteralPath ($RepoRoot.Trim().Trim('"'))).Path
$repoAddonDir = Join-Path $RepoRoot "repository.mrgee.kodi"
$addonXml = Join-Path $repoAddonDir "addon.xml"
if (-not (Test-Path -LiteralPath $addonXml)) { throw "repository.mrgee.kodi\addon.xml not found" }
[xml]$xml = Get-Content -LiteralPath $addonXml -Raw -Encoding UTF8
$version = [string]$xml.addon.version
$zip = Join-Path $repoAddonDir ("repository.mrgee.kodi-$version.zip")
Get-ChildItem -LiteralPath $repoAddonDir -File -Filter "repository.mrgee.kodi-*.zip" -ErrorAction SilentlyContinue | Remove-Item -Force
Compress-Archive -LiteralPath $repoAddonDir -DestinationPath $zip -Force
Write-Host "[repair] repository.mrgee.kodi v$version -> $zip"
$toolDir = Split-Path -Parent $MyInvocation.MyCommand.Path
& (Join-Path $toolDir "Update-Repo-Index.ps1") -RepoRoot $RepoRoot
