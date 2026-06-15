param(
    [Parameter(Mandatory=$true)]
    [string]$RepoRoot,

    [string]$Message = "Update Kodi repository"
)

$ErrorActionPreference = "Stop"

function Clean-PathArg([string]$p) {
    if ($null -eq $p) { return $p }
    return ($p.Trim() -replace '^[`" ]+', '' -replace '[`" ]+$', '')
}

$RepoRoot = Clean-PathArg $RepoRoot
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot ".git"))) {
    throw ".git folder not found in $RepoRoot. Reconnect this folder to GitHub first."
}

$oldLocation = Get-Location
try {
    Set-Location -LiteralPath $RepoRoot

    Write-Host ""
    Write-Host "============================================================"
    Write-Host "Uploading repository to GitHub"
    Write-Host "============================================================"

    & git add -A
    if ($LASTEXITCODE -ne 0) { throw "git add failed." }

    $changes = & git status --porcelain
    if ([string]::IsNullOrWhiteSpace(($changes -join "`n"))) {
        Write-Host "No changes to upload."
        return
    }

    & git commit -m $Message
    if ($LASTEXITCODE -ne 0) { throw "git commit failed." }

    & git push origin main
    if ($LASTEXITCODE -ne 0) { throw "git push failed." }

    Write-Host ""
    Write-Host "Upload complete."
} finally {
    Set-Location $oldLocation
}
