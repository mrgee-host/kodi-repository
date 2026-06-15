param(
    [Parameter(Mandatory=$true)]
    [string]$RepoRoot
)

$ErrorActionPreference = "Stop"

function Clean-PathArg([string]$p) {
    if ($null -eq $p) { return $p }
    return ($p.Trim() -replace '^[`" ]+', '' -replace '[`" ]+$', '')
}

function New-TempFolder {
    $d = Join-Path $env:TEMP ("kodirepo_index_" + [Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $d -Force | Out-Null
    return $d
}

function Get-AddonInfoFromZip([string]$ZipFile) {
    $tmp = New-TempFolder
    try {
        Expand-Archive -LiteralPath $ZipFile -DestinationPath $tmp -Force
        $addonXml = Get-ChildItem -LiteralPath $tmp -Recurse -Force -Filter "addon.xml" | Select-Object -First 1
        if ($null -eq $addonXml) {
            Write-Warning "addon.xml not found inside zip: $ZipFile"
            return $null
        }

        [xml]$x = Get-Content -LiteralPath $addonXml.FullName -Raw
        if ($null -eq $x.addon) {
            Write-Warning "Invalid addon.xml inside zip: $ZipFile"
            return $null
        }

        $id = [string]$x.addon.id
        $version = [string]$x.addon.version
        if ([string]::IsNullOrWhiteSpace($id) -or [string]::IsNullOrWhiteSpace($version)) {
            Write-Warning "Missing id/version inside zip: $ZipFile"
            return $null
        }

        $rawXml = Get-Content -LiteralPath $addonXml.FullName -Raw
        $rawXml = [regex]::Replace($rawXml, '^\s*<\?xml[^>]*\?>\s*', '', 'IgnoreCase')

        $rel = $ZipFile.Substring($RepoRoot.Length).TrimStart('\','/')
        $rel = $rel -replace '\\','/'

        return [PSCustomObject]@{
            Id = $id
            Version = $version
            ZipPath = $ZipFile
            Rel = $rel
            Xml = $rawXml.Trim()
        }
    } finally {
        Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$RepoRoot = Clean-PathArg $RepoRoot
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
Write-Host "[repo] Updating index: $RepoRoot"

$items = New-Object System.Collections.Generic.List[object]

$addonDirs = Get-ChildItem -LiteralPath $RepoRoot -Directory -Force | Where-Object {
    $_.Name -ne ".git" -and
    $_.Name -ne "_tools" -and
    $_.Name -notlike "_*"
}

foreach ($dir in $addonDirs) {
    $zips = Get-ChildItem -LiteralPath $dir.FullName -Filter "*.zip" -File -ErrorAction SilentlyContinue
    foreach ($zip in $zips) {
        $info = Get-AddonInfoFromZip $zip.FullName
        if ($null -ne $info) {
            $items.Add($info) | Out-Null
            Write-Host "  OK $($info.Id) v$($info.Version)"
        }
    }
}

if ($items.Count -eq 0) {
    throw "No valid Kodi add-on zips found. addons.xml was not updated."
}

$addonsXmlPath = Join-Path $RepoRoot "addons.xml"
$md5Path = Join-Path $RepoRoot "addons.xml.md5"
$indexPath = Join-Path $RepoRoot "index.html"

$lines = New-Object System.Collections.Generic.List[string]
$lines.Add('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>') | Out-Null
$lines.Add('<addons>') | Out-Null
foreach ($item in ($items | Sort-Object Id, Version)) {
    $lines.Add($item.Xml) | Out-Null
}
$lines.Add('</addons>') | Out-Null
[System.IO.File]::WriteAllText($addonsXmlPath, ($lines -join "`n"), [System.Text.Encoding]::UTF8)

$hash = (Get-FileHash -LiteralPath $addonsXmlPath -Algorithm MD5).Hash.ToLowerInvariant()
[System.IO.File]::WriteAllText($md5Path, $hash, [System.Text.Encoding]::ASCII)

$html = New-Object System.Collections.Generic.List[string]
$html.Add('<!doctype html>') | Out-Null
$html.Add('<html><head><meta charset="utf-8"><title>MrGee Kodi Repository</title></head><body>') | Out-Null
$html.Add('<h1>MrGee Kodi Repository</h1>') | Out-Null
$html.Add('<p><a href="addons.xml">addons.xml</a> | <a href="addons.xml.md5">addons.xml.md5</a></p>') | Out-Null
$html.Add('<h2>Add-ons</h2><ul>') | Out-Null
foreach ($item in ($items | Sort-Object Id, Version)) {
    $line = '<li><a href="{0}">{1} v{2}</a></li>' -f $item.Rel, $item.Id, $item.Version
    $html.Add($line) | Out-Null
}
$html.Add('</ul></body></html>') | Out-Null
[System.IO.File]::WriteAllText($indexPath, ($html -join "`n"), [System.Text.Encoding]::UTF8)

Write-Host ""
Write-Host "[repo] Updated:"
Write-Host "  $addonsXmlPath"
Write-Host "  $md5Path"
Write-Host "  $indexPath"
Write-Host "[repo] Add-ons indexed: $($items.Count)"
