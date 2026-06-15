param(
    [Parameter(Mandatory=$true)][string]$RepoRoot
)

$ErrorActionPreference = 'Stop'

function Clean-Arg([string]$s) {
    if ($null -eq $s) { return $null }
    return $s.Trim().Trim('"')
}

function Get-RelPath([string]$Root, [string]$Path) {
    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\','/')
    $pathFull = [System.IO.Path]::GetFullPath($Path)
    if ($pathFull.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $pathFull.Substring($rootFull.Length).TrimStart('\','/').Replace('\','/')
    }
    return $pathFull.Replace('\','/')
}

function Get-AddonXmlFromZip([string]$ZipPath) {
    $temp = Join-Path $env:TEMP ("kodi_index_" + [guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $temp -Force | Out-Null
    try {
        Expand-Archive -LiteralPath $ZipPath -DestinationPath $temp -Force
        $candidates = Get-ChildItem -LiteralPath $temp -Filter 'addon.xml' -Recurse -File -ErrorAction SilentlyContinue
        foreach ($candidate in $candidates) {
            try {
                [xml]$x = Get-Content -LiteralPath $candidate.FullName -Raw
                if ($x.addon -and $x.addon.id -and $x.addon.version) {
                    return @{ XmlFile = $candidate.FullName; Xml = $x; Raw = (Get-Content -LiteralPath $candidate.FullName -Raw) }
                }
            } catch { }
        }
        return $null
    }
    finally {
        if (Test-Path -LiteralPath $temp) {
            Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

$RepoRoot = Clean-Arg $RepoRoot
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
Write-Host "[repo] Updating index: $RepoRoot"

$items = @()
$addonXmlBlocks = @()

$zipFiles = Get-ChildItem -LiteralPath $RepoRoot -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -notin @('_tools', '.git') -and -not $_.Name.StartsWith('_') } |
    ForEach-Object { Get-ChildItem -LiteralPath $_.FullName -Filter '*.zip' -File -ErrorAction SilentlyContinue }

foreach ($zip in $zipFiles) {
    $info = Get-AddonXmlFromZip -ZipPath $zip.FullName

    if (-not $info) {
        # Fallback: repository folder may also contain a sibling addon.xml next to the zip.
        $fallbackXml = Join-Path $zip.DirectoryName 'addon.xml'
        if (Test-Path -LiteralPath $fallbackXml -PathType Leaf) {
            try {
                [xml]$x = Get-Content -LiteralPath $fallbackXml -Raw
                if ($x.addon -and $x.addon.id -and $x.addon.version) {
                    $info = @{ XmlFile = $fallbackXml; Xml = $x; Raw = (Get-Content -LiteralPath $fallbackXml -Raw) }
                }
            } catch { }
        }
    }

    if (-not $info) {
        Write-Warning "Skipping invalid zip, addon.xml not readable: $($zip.FullName)"
        continue
    }

    $id = [string]$info.Xml.addon.id
    $version = [string]$info.Xml.addon.version
    $rel = Get-RelPath -Root $RepoRoot -Path $zip.FullName

    $raw = [string]$info.Raw
    $raw = $raw -replace '^\s*<\?xml[^>]*\?>\s*', ''
    $addonXmlBlocks += $raw.Trim()

    $items += [pscustomobject]@{ Id = $id; Version = $version; Rel = $rel; Zip = $zip.FullName }
    Write-Host "  OK $id v$version"
}

if ($items.Count -lt 1) {
    Write-Error "No valid Kodi addon zips found. addons.xml was not updated."
    exit 1
}

$addonsXml = New-Object System.Collections.Generic.List[string]
$addonsXml.Add('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>') | Out-Null
$addonsXml.Add('<addons>') | Out-Null
foreach ($block in $addonXmlBlocks) {
    $addonsXml.Add($block) | Out-Null
}
$addonsXml.Add('</addons>') | Out-Null

$addonsXmlPath = Join-Path $RepoRoot 'addons.xml'
$md5Path = Join-Path $RepoRoot 'addons.xml.md5'
$indexPath = Join-Path $RepoRoot 'index.html'

[System.IO.File]::WriteAllText($addonsXmlPath, ($addonsXml -join "`n"), [System.Text.UTF8Encoding]::new($false))
$md5 = (Get-FileHash -LiteralPath $addonsXmlPath -Algorithm MD5).Hash.ToLowerInvariant()
[System.IO.File]::WriteAllText($md5Path, $md5, [System.Text.UTF8Encoding]::new($false))

$html = New-Object System.Collections.Generic.List[string]
$html.Add('<!doctype html>') | Out-Null
$html.Add('<html><head><meta charset="utf-8"><title>MrGee Kodi Repository</title></head><body>') | Out-Null
$html.Add('<h1>MrGee Kodi Repository</h1>') | Out-Null
$html.Add('<p><a href="addons.xml">addons.xml</a> | <a href="addons.xml.md5">addons.xml.md5</a></p>') | Out-Null
$html.Add('<ul>') | Out-Null
foreach ($item in ($items | Sort-Object Id, Version)) {
    $line = '<li><a href="{0}">{1} v{2}</a></li>' -f $item.Rel, $item.Id, $item.Version
    $html.Add($line) | Out-Null
}
$html.Add('</ul></body></html>') | Out-Null
[System.IO.File]::WriteAllText($indexPath, ($html -join "`n"), [System.Text.UTF8Encoding]::new($false))

Write-Host ""
Write-Host "[repo] Updated:"
Write-Host "  $addonsXmlPath"
Write-Host "  $md5Path"
Write-Host "  $indexPath"
Write-Host "[repo] Add-ons indexed: $($items.Count)"
exit 0
