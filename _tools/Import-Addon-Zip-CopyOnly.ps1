param(
    [Parameter(Mandatory=$true)][string]$RepoRoot,
    [Parameter(Mandatory=$true)][string]$ZipPath
)

$ErrorActionPreference = 'Stop'

function Clean-Arg([string]$s) {
    if ($null -eq $s) { return $null }
    return $s.Trim().Trim('"')
}

$RepoRoot = Clean-Arg $RepoRoot
$ZipPath  = Clean-Arg $ZipPath

if ([string]::IsNullOrWhiteSpace($RepoRoot)) { throw "RepoRoot is empty." }
if ([string]::IsNullOrWhiteSpace($ZipPath))  { throw "ZipPath is empty. Drag the addon ZIP onto the BAT file." }

$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
if (-not (Test-Path -LiteralPath $ZipPath -PathType Leaf)) {
    throw "ZIP not found: $ZipPath"
}

$temp = Join-Path $env:TEMP ("kodi_import_" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $temp -Force | Out-Null

try {
    Expand-Archive -LiteralPath $ZipPath -DestinationPath $temp -Force

    $addonXmlCandidates = Get-ChildItem -LiteralPath $temp -Filter 'addon.xml' -Recurse -File -ErrorAction SilentlyContinue
    if (-not $addonXmlCandidates -or $addonXmlCandidates.Count -lt 1) {
        throw "addon.xml not found inside ZIP: $ZipPath"
    }

    $chosen = $null
    $chosenXml = $null
    foreach ($candidate in $addonXmlCandidates) {
        try {
            [xml]$x = Get-Content -LiteralPath $candidate.FullName -Raw
            if ($x.addon -and $x.addon.id -and $x.addon.version) {
                $chosen = $candidate
                $chosenXml = $x
                break
            }
        } catch { }
    }

    if (-not $chosen) {
        throw "No valid Kodi addon.xml found inside ZIP: $ZipPath"
    }

    $id = [string]$chosenXml.addon.id
    $version = [string]$chosenXml.addon.version
    if ([string]::IsNullOrWhiteSpace($id) -or [string]::IsNullOrWhiteSpace($version)) {
        throw "Invalid addon.xml: missing id/version in $($chosen.FullName)"
    }

    $destDir = Join-Path $RepoRoot $id
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null

    # Keep only one ZIP for this addon id. The copied bytes are the ORIGINAL source zip; no repack.
    Get-ChildItem -LiteralPath $destDir -Filter "$id-*.zip" -File -ErrorAction SilentlyContinue | Remove-Item -Force

    $destZip = Join-Path $destDir ("$id-$version.zip")
    Copy-Item -LiteralPath $ZipPath -Destination $destZip -Force

    Write-Host "[import] $id v$version"
    Write-Host "[copy]   $ZipPath"
    Write-Host "[repo]   $destZip"

    $indexScript = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) 'Update-Repo-Index.ps1'
    & $indexScript -RepoRoot $RepoRoot
    if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
}
finally {
    if (Test-Path -LiteralPath $temp) {
        Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
    }
}
