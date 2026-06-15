param(
    [string]$RepoRoot = "",
    [string]$Message = "Update Kodi repository"
)

$ErrorActionPreference = "Stop"

function Normalize-PathArg([string]$p) {
    if ([string]::IsNullOrWhiteSpace($p)) { return $p }
    return $p.Trim().Trim('"')
}
function Get-DefaultRepoRoot {
    $scriptDir = Split-Path -Parent $PSCommandPath
    if ((Split-Path -Leaf $scriptDir) -ieq "_tools") { return (Resolve-Path (Join-Path $scriptDir "..")).Path }
    return (Resolve-Path $scriptDir).Path
}

$RepoRoot = Normalize-PathArg $RepoRoot
if ([string]::IsNullOrWhiteSpace($RepoRoot)) { $RepoRoot = Get-DefaultRepoRoot }
$RepoRoot = (Resolve-Path $RepoRoot).Path

Write-Host "[git] Repo root:" $RepoRoot
Push-Location $RepoRoot
try {
    $inside = git rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -ne 0 -or $inside.Trim() -ne "true") { throw "Folder ini bukan Git working tree: $RepoRoot" }

    $name = (git config user.name) 2>$null
    $email = (git config user.email) 2>$null
    if ([string]::IsNullOrWhiteSpace($name) -or [string]::IsNullOrWhiteSpace($email)) {
        Write-Host "[git] user.name / user.email belum diset. Jalankan sekali:" -ForegroundColor Yellow
        Write-Host "git config --global user.name \"Miftahul Ginda\""
        Write-Host "git config --global user.email \"miftahulginda01@gmail.com\""
        throw "Git identity belum lengkap."
    }

    git add -A
    $status = git status --porcelain
    if ([string]::IsNullOrWhiteSpace($status)) {
        Write-Host "[git] Tidak ada perubahan untuk diupload."
    }
    else {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        git commit -m "$Message - $timestamp"
        if ($LASTEXITCODE -ne 0) { throw "git commit gagal." }
    }

    git push origin main
    if ($LASTEXITCODE -ne 0) { throw "git push gagal." }
    Write-Host "[git] Upload selesai."
}
finally {
    Pop-Location
}
