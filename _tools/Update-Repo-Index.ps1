param(
    [Parameter(Mandatory=$true)][string]$RepoRoot
)

$ErrorActionPreference = 'Stop'

function Clean-PathArg([string]$p) {
    if ($null -eq $p) { return $p }
    return $p.Trim().Trim('"')
}

function Ensure-ZipFileSystem {
    if (-not ([System.Management.Automation.PSTypeName]'System.IO.Compression.ZipFile').Type) {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
    }
}

function Get-RelativeWebPath([string]$BaseDir, [string]$FullPath) {
    $base = (Resolve-Path $BaseDir).Path.TrimEnd('\') + '\'
    $full = (Resolve-Path $FullPath).Path
    $baseUri = New-Object System.Uri ($base.Replace('\','/'))
    $fullUri = New-Object System.Uri ($full.Replace('\','/'))
    $rel = $baseUri.MakeRelativeUri($fullUri).ToString()
    return [System.Uri]::UnescapeDataString($rel)
}

function Read-AddonXml-FromZip([string]$ZipFile) {
    Ensure-ZipFileSystem
    $temp = Join-Path $env:TEMP ("kodi_index_" + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Force -Path $temp | Out-Null
    try {
        [System.IO.Compression.ZipFile]::ExtractToDirectory($ZipFile, $temp)
        $addonXml = Get-ChildItem -LiteralPath $temp -Filter addon.xml -Recurse -Force |
            Where-Object { $_.FullName -notmatch '__MACOSX' } |
            Select-Object -First 1
        if (-not $addonXml) { return $null }
        [xml]$xml = Get-Content -LiteralPath $addonXml.FullName -Raw
        $id = [string]$xml.addon.id
        $version = [string]$xml.addon.version
        if ([string]::IsNullOrWhiteSpace($id) -or [string]::IsNullOrWhiteSpace($version)) { return $null }
        $raw = Get-Content -LiteralPath $addonXml.FullName -Raw
        $raw = $raw -replace '^\s*<\?xml[^>]*\?>\s*', ''
        return [pscustomobject]@{
            Id = $id
            Version = $version
            Xml = $raw.Trim()
            Zip = $ZipFile
        }
    }
    finally {
        if (Test-Path $temp) { Remove-Item -LiteralPath $temp -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

function Compare-VersionString([string]$a, [string]$b) {
    try {
        $va = [version]$a
        $vb = [version]$b
        return $va.CompareTo($vb)
    } catch {
        return [string]::Compare($a, $b, $true)
    }
}

$RepoRoot = Clean-PathArg $RepoRoot
$RepoRoot = (Resolve-Path $RepoRoot).Path
Write-Host "[repo] Updating index: $RepoRoot"

$all = @()
$dirs = Get-ChildItem -LiteralPath $RepoRoot -Directory -Force | Where-Object {
    $_.Name -notin @('_tools','.git','.github','_incoming_addons')
}

foreach ($dir in $dirs) {
    $zips = Get-ChildItem -LiteralPath $dir.FullName -Filter '*.zip' -File -ErrorAction SilentlyContinue
    foreach ($zip in $zips) {
        $item = Read-AddonXml-FromZip $zip.FullName
        if ($null -eq $item) {
            Write-Warning "addon.xml not found/readable inside zip: $($zip.FullName)"
        } else {
            $all += $item
        }
    }
}

if ($all.Count -lt 1) {
    Write-Error "No valid Kodi add-on zips found. addons.xml was not updated."
    exit 1
}

# Keep only latest per addon id.
$latest = @()
foreach ($group in ($all | Group-Object Id)) {
    $best = $group.Group | Sort-Object -Property @{ Expression = { $_.Version }; Descending = $true } | Select-Object -First 1
    foreach ($candidate in $group.Group) {
        if ((Compare-VersionString $candidate.Version $best.Version) -gt 0) { $best = $candidate }
    }
    $latest += $best
}
$latest = $latest | Sort-Object Id

$addonsXml = "<?xml version=`"1.0`" encoding=`"UTF-8`"?>`r`n<addons>`r`n"
foreach ($item in $latest) {
    Write-Host ("  OK {0} v{1}" -f $item.Id, $item.Version)
    $addonsXml += $item.Xml + "`r`n"
}
$addonsXml += "</addons>`r`n"

$addonsPath = Join-Path $RepoRoot 'addons.xml'
$md5Path = Join-Path $RepoRoot 'addons.xml.md5'
$indexPath = Join-Path $RepoRoot 'index.html'

[System.IO.File]::WriteAllText($addonsPath, $addonsXml, [System.Text.UTF8Encoding]::new($false))
$md5 = (Get-FileHash -LiteralPath $addonsPath -Algorithm MD5).Hash.ToLowerInvariant()
[System.IO.File]::WriteAllText($md5Path, $md5, [System.Text.UTF8Encoding]::new($false))

$repoZip = Get-ChildItem -LiteralPath (Join-Path $RepoRoot 'repository.mrgee.kodi') -Filter 'repository.mrgee.kodi-*.zip' -File -ErrorAction SilentlyContinue | Select-Object -First 1
$repoZipRel = if ($repoZip) { Get-RelativeWebPath $RepoRoot $repoZip.FullName } else { '' }

$itemsHtml = ""
foreach ($item in $latest) {
    $rel = Get-RelativeWebPath $RepoRoot $item.Zip
    $itemsHtml += "    <li><a href=`"$rel`">$($item.Id) v$($item.Version)</a></li>`r`n"
}

$repoLink = if ($repoZipRel) { "<p><a href=`"$repoZipRel`">Install repository zip</a></p>" } else { "" }
$html = @"
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <title>MrGee Kodi Repository</title>
</head>
<body>
  <h1>MrGee Kodi Repository</h1>
  $repoLink
  <p><a href="addons.xml">addons.xml</a> | <a href="addons.xml.md5">addons.xml.md5</a></p>
  <h2>Add-ons</h2>
  <ul>
$itemsHtml  </ul>
</body>
</html>
"@
[System.IO.File]::WriteAllText($indexPath, $html, [System.Text.UTF8Encoding]::new($false))

Write-Host ""
Write-Host "[repo] Updated:" -ForegroundColor Green
Write-Host "  $addonsPath"
Write-Host "  $md5Path"
Write-Host "  $indexPath"
Write-Host "[repo] Add-ons indexed: $($latest.Count)"
exit 0
