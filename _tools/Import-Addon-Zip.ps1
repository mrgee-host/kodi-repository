param(
    [Parameter(Mandatory=$true)]
    [string]$RepoRoot,

    [Parameter(Mandatory=$true)]
    [string[]]$ZipPath,

    [switch]$Upload
)

$ErrorActionPreference = "Stop"

function Clean-PathArg([string]$p) {
    if ($null -eq $p) { return $p }
    return ($p.Trim() -replace '^[`" ]+', '' -replace '[`" ]+$', '')
}

function New-TempFolder {
    $d = Join-Path $env:TEMP ("kodirepo_" + [Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $d -Force | Out-Null
    return $d
}

function Copy-DirectoryContents([string]$Source, [string]$Destination) {
    if (Test-Path -LiteralPath $Destination) {
        Remove-Item -LiteralPath $Destination -Recurse -Force
    }
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null
    Get-ChildItem -LiteralPath $Source -Force | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $Destination -Recurse -Force
    }
}

function Get-AddonInfo([string]$AddonXmlPath) {
    [xml]$x = Get-Content -LiteralPath $AddonXmlPath -Raw
    if ($null -eq $x.addon) {
        throw "Invalid addon.xml: no <addon> root in $AddonXmlPath"
    }
    $id = [string]$x.addon.id
    $version = [string]$x.addon.version
    if ([string]::IsNullOrWhiteSpace($id) -or [string]::IsNullOrWhiteSpace($version)) {
        throw "Invalid addon.xml: missing id/version in $AddonXmlPath"
    }
    return [PSCustomObject]@{
        Id = $id
        Version = $version
    }
}

function Import-OneZip([string]$InputZip) {
    $InputZip = Clean-PathArg $InputZip
    if (-not (Test-Path -LiteralPath $InputZip)) {
        throw "Zip not found: $InputZip"
    }

    $extractDir = New-TempFolder
    $normalizedRoot = New-TempFolder

    try {
        Expand-Archive -LiteralPath $InputZip -DestinationPath $extractDir -Force

        $addonXml = Get-ChildItem -LiteralPath $extractDir -Recurse -Force -Filter "addon.xml" | Select-Object -First 1
        if ($null -eq $addonXml) {
            throw "addon.xml not found inside zip: $InputZip"
        }

        $info = Get-AddonInfo $addonXml.FullName
        $id = $info.Id
        $version = $info.Version

        $sourceAddonFolder = Split-Path -Parent $addonXml.FullName
        $destAddonFolder = Join-Path $normalizedRoot $id
        Copy-DirectoryContents $sourceAddonFolder $destAddonFolder

        $normalizedAddonXml = Join-Path $destAddonFolder "addon.xml"
        if (-not (Test-Path -LiteralPath $normalizedAddonXml)) {
            throw "Normalized package still missing addon.xml for $id"
        }

        $addonRepoDir = Join-Path $RepoRoot $id
        New-Item -ItemType Directory -Path $addonRepoDir -Force | Out-Null

        Get-ChildItem -LiteralPath $addonRepoDir -Filter "$id-*.zip" -File -ErrorAction SilentlyContinue | Remove-Item -Force

        $outZip = Join-Path $addonRepoDir "$id-$version.zip"
        if (Test-Path -LiteralPath $outZip) {
            Remove-Item -LiteralPath $outZip -Force
        }

        $oldLocation = Get-Location
        try {
            Set-Location -LiteralPath $normalizedRoot
            Compress-Archive -LiteralPath $id -DestinationPath $outZip -Force
        } finally {
            Set-Location $oldLocation
        }

        # Validate the final zip exactly the way Kodi expects it: addon.id/addon.xml
        $validateDir = New-TempFolder
        try {
            Expand-Archive -LiteralPath $outZip -DestinationPath $validateDir -Force
            $expected = Join-Path (Join-Path $validateDir $id) "addon.xml"
            if (-not (Test-Path -LiteralPath $expected)) {
                throw "Created zip is invalid; missing $id/addon.xml"
            }
        } finally {
            Remove-Item -LiteralPath $validateDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        Write-Host "[import] $id v$version -> $outZip"
    } finally {
        Remove-Item -LiteralPath $extractDir -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -LiteralPath $normalizedRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$RepoRoot = Clean-PathArg $RepoRoot
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
$toolDir = Split-Path -Parent $MyInvocation.MyCommand.Path

foreach ($z in $ZipPath) {
    Write-Host ""
    Write-Host "============================================================"
    Write-Host "Importing: $(Split-Path -Leaf $z)"
    Write-Host "============================================================"
    Import-OneZip $z
}

& (Join-Path $toolDir "Update-Repo-Index.ps1") -RepoRoot $RepoRoot

if ($Upload) {
    & (Join-Path $toolDir "Upload-Repo.ps1") -RepoRoot $RepoRoot -Message "Update Kodi repository add-ons"
}

Write-Host ""
Write-Host "Done."
