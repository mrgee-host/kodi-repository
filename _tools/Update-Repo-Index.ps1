param(
    [Parameter(Mandatory=$true)]
    [string]$RepoRoot
)

$ErrorActionPreference = "Stop"

function Clean-PathArg([string]$p) {
    if ($null -eq $p) { return $p }
    return $p.Trim().Trim('"')
}

function Get-RelativePathPs51([string]$BasePath, [string]$TargetPath) {
    $base = [System.IO.Path]::GetFullPath($BasePath).TrimEnd('\','/') + [System.IO.Path]::DirectorySeparatorChar
    $target = [System.IO.Path]::GetFullPath($TargetPath)
    $baseUri = New-Object System.Uri($base)
    $targetUri = New-Object System.Uri($target)
    $relUri = $baseUri.MakeRelativeUri($targetUri)
    return [System.Uri]::UnescapeDataString($relUri.ToString()).Replace('\\','/')
}

function Get-AddonXmlFromZip([string]$ZipPath) {
    $tmp = Join-Path $env:TEMP ("kodi_repo_zipread_" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Force -Path $tmp | Out-Null
    try {
        Expand-Archive -LiteralPath $ZipPath -DestinationPath $tmp -Force
        $xmlFile = Get-ChildItem -LiteralPath $tmp -Recurse -File -Filter "addon.xml" -ErrorAction SilentlyContinue |
            Sort-Object { $_.FullName.Length } |
            Select-Object -First 1
        if (-not $xmlFile) { return $null }
        [xml]$xml = Get-Content -LiteralPath $xmlFile.FullName -Raw -Encoding UTF8
        if (-not $xml.addon -or -not $xml.addon.id -or -not $xml.addon.version) { return $null }
        return [pscustomobject]@{
            Xml = $xml
            XmlPath = $xmlFile.FullName
            Id = [string]$xml.addon.id
            Version = [string]$xml.addon.version
            Source = $ZipPath
        }
    }
    finally {
        Remove-Item -LiteralPath $tmp -Recurse -Force -ErrorAction SilentlyContinue
    }
}

function Get-AddonXmlFromFolder([string]$FolderPath) {
    $xmlPath = Join-Path $FolderPath "addon.xml"
    if (-not (Test-Path -LiteralPath $xmlPath)) { return $null }
    [xml]$xml = Get-Content -LiteralPath $xmlPath -Raw -Encoding UTF8
    if (-not $xml.addon -or -not $xml.addon.id -or -not $xml.addon.version) { return $null }
    return [pscustomobject]@{
        Xml = $xml
        XmlPath = $xmlPath
        Id = [string]$xml.addon.id
        Version = [string]$xml.addon.version
        Source = $xmlPath
    }
}

function Compare-KodiVersion([string]$A, [string]$B) {
    try {
        $va = New-Object System.Version($A)
        $vb = New-Object System.Version($B)
        return $va.CompareTo($vb)
    } catch {
        return [string]::Compare($A, $B, $true)
    }
}

function Strip-XmlDeclaration([string]$s) {
    return ($s -replace '^\s*<\?xml[^>]*\?>\s*', '').Trim()
}

$RepoRoot = Clean-PathArg $RepoRoot
$RepoRoot = (Resolve-Path -LiteralPath $RepoRoot).Path
Write-Host "[repo] Updating index: $RepoRoot"

$excludeNames = @('_tools', '_incoming_addons', '.git', '.github', '__pycache__')
$itemsById = @{}
$warnings = New-Object System.Collections.Generic.List[string]

# Scan immediate add-on folders only. Kodi repo layout = repoRoot\addon.id\addon.id-version.zip
$folders = Get-ChildItem -LiteralPath $RepoRoot -Directory -ErrorAction SilentlyContinue |
    Where-Object { $excludeNames -notcontains $_.Name -and -not $_.Name.StartsWith('.') }

foreach ($folder in $folders) {
    $candidates = New-Object System.Collections.Generic.List[object]

    $folderXml = Get-AddonXmlFromFolder $folder.FullName
    if ($folderXml) { $candidates.Add($folderXml) | Out-Null }

    $zips = Get-ChildItem -LiteralPath $folder.FullName -File -Filter "*.zip" -ErrorAction SilentlyContinue |
        Sort-Object Name

    foreach ($zip in $zips) {
        $zi = Get-AddonXmlFromZip $zip.FullName
        if ($zi) {
            $candidates.Add($zi) | Out-Null
        } else {
            $warnings.Add("WARNING: addon.xml not found/readable inside zip: $($zip.FullName)") | Out-Null
        }
    }

    if ($candidates.Count -eq 0) { continue }

    # For this folder, choose highest version. Prefer zip over folder when equal, because zip is the downloadable artifact.
    $best = $null
    foreach ($c in $candidates) {
        if (-not $best) { $best = $c; continue }
        $cmp = Compare-KodiVersion $c.Version $best.Version
        if ($cmp -gt 0) { $best = $c; continue }
        if ($cmp -eq 0 -and $c.Source.ToLowerInvariant().EndsWith('.zip')) { $best = $c }
    }

    if (-not $itemsById.ContainsKey($best.Id)) {
        $itemsById[$best.Id] = $best
    } else {
        $old = $itemsById[$best.Id]
        if ((Compare-KodiVersion $best.Version $old.Version) -gt 0) { $itemsById[$best.Id] = $best }
    }
}

foreach ($w in $warnings) { Write-Warning $w }

if ($itemsById.Count -eq 0) {
    Write-Error "No valid Kodi add-on zips/folders found. addons.xml was not updated."
    exit 1
}

$ordered = $itemsById.Values | Sort-Object Id
$addonXmlParts = New-Object System.Collections.Generic.List[string]
$linkItems = New-Object System.Collections.Generic.List[string]

foreach ($item in $ordered) {
    $addonXmlParts.Add((Strip-XmlDeclaration $item.Xml.OuterXml)) | Out-Null

    # Find downloadable zip for the same add-on/version if possible.
    $folder = Join-Path $RepoRoot $item.Id
    $zipFile = $null
    if (Test-Path -LiteralPath $folder) {
        $zipFile = Get-ChildItem -LiteralPath $folder -File -Filter "*.zip" -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like "$($item.Id)-*.zip" } |
            Sort-Object Name -Descending |
            Select-Object -First 1
    }
    if ($zipFile) {
        $rel = Get-RelativePathPs51 $RepoRoot $zipFile.FullName
        $safeRel = [System.Net.WebUtility]::HtmlEncode($rel)
        $safeText = [System.Net.WebUtility]::HtmlEncode("$($item.Id) v$($item.Version)")
        $linkItems.Add("<li><a href=""$safeRel"">$safeText</a></li>") | Out-Null
    }

    Write-Host ("  OK {0} v{1}" -f $item.Id, $item.Version)
}

$addonsXml = "<addons>`n" + (($addonXmlParts | ForEach-Object { $_ }) -join "`n") + "`n</addons>`n"
$addonsPath = Join-Path $RepoRoot "addons.xml"
$md5Path = Join-Path $RepoRoot "addons.xml.md5"
$indexPath = Join-Path $RepoRoot "index.html"

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($addonsPath, $addonsXml, $utf8NoBom)

$md5 = (Get-FileHash -LiteralPath $addonsPath -Algorithm MD5).Hash.ToLowerInvariant()
[System.IO.File]::WriteAllText($md5Path, $md5, $utf8NoBom)

$links = ($linkItems -join "`n")
$indexHtml = @"
<!doctype html>
<html>
<head><meta charset="utf-8"><title>MrGee Kodi Repository</title></head>
<body>
<h1>MrGee Kodi Repository</h1>
<ul>
<li><a href="addons.xml">addons.xml</a></li>
<li><a href="addons.xml.md5">addons.xml.md5</a></li>
</ul>
<h2>Add-ons</h2>
<ul>
$links
</ul>
</body>
</html>
"@
[System.IO.File]::WriteAllText($indexPath, $indexHtml, $utf8NoBom)

Write-Host ""
Write-Host "[repo] Updated:"
Write-Host "  $addonsPath"
Write-Host "  $md5Path"
Write-Host "  $indexPath"
Write-Host ("[repo] Add-ons indexed: {0}" -f $itemsById.Count)
exit 0
