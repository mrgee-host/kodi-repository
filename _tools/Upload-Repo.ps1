param(
    [Parameter(Mandatory=$true)][string]$RepoRoot
)

$ErrorActionPreference = 'Stop'

function Clean-Arg([string]$s) {
    if ($null -eq $s) { return $null }
    return $s.Trim().Trim('"')
}

$RepoRoot = Clean-Arg $RepoRoot
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path

if (-not (Test-Path -LiteralPath (Join-Path $RepoRoot '.git') -PathType Container)) {
    throw ".git not found in $RepoRoot. Restore/clone the GitHub repo first."
}

Push-Location $RepoRoot
try {
    git add -A
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    $status = git status --porcelain
    if (-not [string]::IsNullOrWhiteSpace(($status -join "`n"))) {
        $stamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        git commit -m "Update Kodi repository $stamp"
        if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
    } else {
        Write-Host "[git] Nothing to commit."
    }

    git push origin main
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

    Write-Host "[git] Upload complete."
    exit 0
}
finally {
    Pop-Location
}
