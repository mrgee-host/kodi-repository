# Upload current repository folder to GitHub.
# Requires Git and GitHub login/credential already configured.
param([string]$RepoRoot)
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
Set-Location $RepoRoot

if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    throw "Git is not installed or not in PATH. Install Git for Windows first."
}

if (-not (Test-Path (Join-Path $RepoRoot '.git'))) {
    git init
    git branch -M main
}

$remote = ''
try { $remote = git remote get-url origin 2>$null } catch { $remote = '' }
if ([string]::IsNullOrWhiteSpace($remote)) {
    git remote add origin https://github.com/mrgee-host/kodi-repository.git
}

git add -A
$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "No changes to upload." -ForegroundColor Yellow
} else {
    $msg = "Update Kodi repository " + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    git commit -m $msg
}

git push -u origin main
Write-Host "Upload complete. Check: https://mrgee-host.github.io/kodi-repository/addons.xml" -ForegroundColor Green
