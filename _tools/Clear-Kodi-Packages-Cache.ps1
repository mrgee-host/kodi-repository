
$ErrorActionPreference = 'Continue'
$paths = @(
  'E:\Kodi\portable_data\addons\packages',
  "$env:APPDATA\Kodi\addons\packages"
)
$patterns = @(
  'context.tpdb.artwork-*.zip',
  'script.library.ratings.scraper-*.zip',
  'script.artwork.curator-*.zip',
  'script.akl.texture.cache.cleaner-*.zip',
  'repository.mrgee.kodi-*.zip'
)
foreach ($p in $paths) {
    if (-not (Test-Path -LiteralPath $p)) { continue }
    Write-Host "[cache] $p"
    foreach ($pat in $patterns) {
        Get-ChildItem -LiteralPath $p -Filter $pat -File -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "  delete $($_.Name)"
            Remove-Item -LiteralPath $_.FullName -Force -ErrorAction SilentlyContinue
        }
    }
}
Write-Host "Done. Restart Kodi or run Check for updates again."
