param(
    [string]$RepoRoot = ""
)
$ErrorActionPreference = "Stop"
function Normalize-PathArg([string]$p) { if ([string]::IsNullOrWhiteSpace($p)) { return $p }; return $p.Trim().Trim('"') }
function Get-DefaultRepoRoot { $scriptDir = Split-Path -Parent $PSCommandPath; if ((Split-Path -Leaf $scriptDir) -ieq "_tools") { return (Resolve-Path (Join-Path $scriptDir "..")).Path }; return (Resolve-Path $scriptDir).Path }
$scriptDir = Split-Path -Parent $PSCommandPath
$RepoRoot = Normalize-PathArg $RepoRoot
if ([string]::IsNullOrWhiteSpace($RepoRoot)) { $RepoRoot = Get-DefaultRepoRoot }
$RepoRoot = (Resolve-Path $RepoRoot).Path
& (Join-Path $scriptDir "Build-Repo.ps1") -RepoRoot $RepoRoot
& (Join-Path $scriptDir "Upload-Repo.ps1") -RepoRoot $RepoRoot -Message "Build Kodi repository"
