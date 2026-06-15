param(
    [Parameter(Mandatory=$true)][string]$RepoRoot,
    [string]$Message = 'Update Kodi repository'
)

$ErrorActionPreference = 'Stop'

function Clean-PathArg([string]$p) {
    if ($null -eq $p) { return $p }
    return $p.Trim().Trim('"')
}

$RepoRoot = Clean-PathArg $RepoRoot
$RepoRoot = (Resolve-Path $RepoRoot).Path
Set-Location $RepoRoot

if (-not (Test-Path (Join-Path $RepoRoot '.git'))) {
    throw "This folder is not a git repository: $RepoRoot. Clone https://github.com/mrgee-host/kodi-repository first, or keep the .git folder."
}

$git = Get-Command git -ErrorAction SilentlyContinue
if (-not $git) { throw "git.exe not found. Install Git for Windows first." }

Write-Host "[git] add -A"
& git add -A
if ($LASTEXITCODE -ne 0) { throw "git add failed" }

$changes = & git diff --cached --name-only
if ([string]::IsNullOrWhiteSpace(($changes -join ''))) {
    Write-Host "[git] No local changes to commit. Pushing anyway..."
} else {
    Write-Host "[git] commit"
    & git commit -m $Message
    if ($LASTEXITCODE -ne 0) {
        Write-Host ""
        Write-Host "If this is author identity error, run once:" -ForegroundColor Yellow
        Write-Host 'git config --global user.name "Miftahul Ginda"'
        Write-Host 'git config --global user.email "miftahulginda01@gmail.com"'
        throw "git commit failed"
    }
}

Write-Host "[git] push origin main"
& git push origin main
if ($LASTEXITCODE -ne 0) { throw "git push failed" }

Write-Host "[git] Upload complete." -ForegroundColor Green
Write-Host "Check: https://mrgee-host.github.io/kodi-repository/addons.xml"
