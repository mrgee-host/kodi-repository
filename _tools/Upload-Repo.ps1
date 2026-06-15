param(
    [string]$RepoRoot = "",
    [string]$Message = "Update Kodi repository"
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
Write-Host "[git] Repo root: $RepoRoot"
Push-Location $RepoRoot
try {
    git status --short
    if ($LASTEXITCODE -ne 0) { throw "git status gagal." }

    git add -A
    if ($LASTEXITCODE -ne 0) { throw "git add gagal." }

    $changes = git status --porcelain
    if ([string]::IsNullOrWhiteSpace(($changes -join "`n"))) {
        Write-Host "[git] No changes to commit."
    } else {
        git commit -m $Message
        if ($LASTEXITCODE -ne 0) { throw "git commit gagal." }
    }

    git push origin main
    if ($LASTEXITCODE -ne 0) { throw "git push gagal." }

    Write-Host "[git] Upload complete."
}
finally {
    Pop-Location
}
