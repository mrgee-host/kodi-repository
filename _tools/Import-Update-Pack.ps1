param(
  [string]$RepoRoot = ".",
  [Parameter(Mandatory=$true)][string]$SourcePath,
  [switch]$Upload
)
$ErrorActionPreference = "Stop"
$RepoRoot = (Resolve-Path $RepoRoot.Trim('"')).Path
$SourcePath = (Resolve-Path $SourcePath.Trim('"')).Path
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$temp = $null
try {
  if ((Get-Item $SourcePath).PSIsContainer) {
    $work = $SourcePath
  } else {
    $temp = Join-Path $env:TEMP ("chatgpt-kodi-update-" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Force -Path $temp | Out-Null
    Expand-Archive -Force -LiteralPath $SourcePath -DestinationPath $temp
    $work = $temp
  }
  $zips = Get-ChildItem -Path $work -Recurse -File -Filter "*.zip" | Where-Object { $_.Name -notmatch '^repository\.' }
  if ($zips.Count -lt 1) { throw "Tidak ada addon zip di update pack: $SourcePath" }
  foreach ($z in $zips) {
    & (Join-Path $scriptDir 'Import-Addon-Zip.ps1') -RepoRoot $RepoRoot -ZipPath $z.FullName -Upload:$false
  }
  if ($Upload) {
    Push-Location $RepoRoot
    try {
      git add -A
      git commit -m "Update Kodi repository from ChatGPT pack"
      git push origin main
      Write-Host "[upload] pushed to GitHub."
    } finally { Pop-Location }
  }
} finally {
  if ($temp -and (Test-Path $temp)) { Remove-Item -Recurse -Force $temp }
}
