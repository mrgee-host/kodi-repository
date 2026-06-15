param(
    [Parameter(Position=0, ValueFromRemainingArguments=$true)]
    [string[]]$ZipPath,
    [string]$RepoRoot = "",
    [switch]$Upload,
    [switch]$KeepOld
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
function Read-AddonXmlFromZip([string]$zipPath) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
    $zip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
    try {
        $entry = $zip.Entries | Where-Object {
            $_.FullName -match '(^|/)addon\.xml$' -and $_.FullName -notmatch '^__MACOSX/'
        } | Select-Object -First 1
        if (-not $entry) { throw "addon.xml tidak ditemukan di zip." }
        $reader = New-Object System.IO.StreamReader($entry.Open())
        try { [xml]$xml = $reader.ReadToEnd() } finally { $reader.Close() }
        if (-not $xml.addon.id -or -not $xml.addon.version) { throw "addon.xml tidak valid: id/version kosong." }
        return $xml
    }
    finally { $zip.Dispose() }
}

$RepoRoot = Normalize-PathArg $RepoRoot
if ([string]::IsNullOrWhiteSpace($RepoRoot)) { $RepoRoot = Get-DefaultRepoRoot }
$RepoRoot = (Resolve-Path $RepoRoot).Path

if (-not $ZipPath -or $ZipPath.Count -eq 0) {
    throw "Tidak ada zip. Drag zip addon ke BAT, atau jalankan: Import-Addon-Zip.ps1 <file.zip>"
}

$scriptDir = Split-Path -Parent $PSCommandPath
$imported = @()

foreach ($zp in $ZipPath) {
    $zp = Normalize-PathArg $zp
    if ([string]::IsNullOrWhiteSpace($zp)) { continue }
    $zipFull = (Resolve-Path $zp).Path
    if (-not (Test-Path -LiteralPath $zipFull -PathType Leaf)) { throw "File tidak ditemukan: $zipFull" }

    $xml = Read-AddonXmlFromZip $zipFull
    $id = [string]$xml.addon.id
    $ver = [string]$xml.addon.version
    $destDir = Join-Path $RepoRoot $id
    if (-not (Test-Path -LiteralPath $destDir)) { New-Item -ItemType Directory -Path $destDir | Out-Null }

    if (-not $KeepOld) {
        Get-ChildItem -LiteralPath $destDir -Filter "$id-*.zip" -File -ErrorAction SilentlyContinue | Remove-Item -Force
    }

    $destZip = Join-Path $destDir ("$id-$ver.zip")
    Copy-Item -LiteralPath $zipFull -Destination $destZip -Force
    Write-Host ("[import] {0} v{1} -> {2}" -f $id, $ver, $destZip)
    $imported += [pscustomobject]@{ Id=$id; Version=$ver; Zip=$destZip }
}

& (Join-Path $scriptDir "Update-Repo-Index.ps1") -RepoRoot $RepoRoot
if ($LASTEXITCODE -ne 0) { throw "Update-Repo-Index gagal." }

if ($Upload) {
    $ids = ($imported | ForEach-Object { "$($_.Id) v$($_.Version)" }) -join ", "
    & (Join-Path $scriptDir "Upload-Repo.ps1") -RepoRoot $RepoRoot -Message "Import addon update: $ids"
}

Write-Host "Import selesai."
