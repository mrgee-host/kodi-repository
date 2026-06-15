param(
    [string]$RepoRoot = ""
)

$ErrorActionPreference = "Stop"

function Normalize-PathArg([string]$p) {
    if ([string]::IsNullOrWhiteSpace($p)) { return "" }
    $x = $p.Trim()
    $x = $x.Trim('"')
    $x = $x.Trim("'")
    return $x
}

function Get-ThisScriptDir {
    if ($PSScriptRoot) { return $PSScriptRoot }
    return Split-Path -Parent $MyInvocation.MyCommand.Path
}

function Get-RepoRoot([string]$arg) {
    $clean = Normalize-PathArg $arg
    if ($clean -and (Test-Path -LiteralPath $clean)) {
        return (Resolve-Path -LiteralPath $clean).Path
    }

    $scriptDir = Get-ThisScriptDir
    if ((Split-Path -Leaf $scriptDir) -ieq "_tools") {
        return (Resolve-Path -LiteralPath (Join-Path $scriptDir "..")).Path
    }

    return (Resolve-Path -LiteralPath $scriptDir).Path
}

function Escape-Html([string]$s) {
    if ($null -eq $s) { return "" }
    $r = [string]$s
    $r = $r -replace '&', '&amp;'
    $r = $r -replace '<', '&lt;'
    $r = $r -replace '>', '&gt;'
    $r = $r -replace '"', '&quot;'
    return $r
}

function Get-RelativePathCompat([string]$BasePath, [string]$FullPath) {
    $baseFull = (Resolve-Path -LiteralPath $BasePath).Path
    if (-not $baseFull.EndsWith([IO.Path]::DirectorySeparatorChar)) {
        $baseFull += [IO.Path]::DirectorySeparatorChar
    }
    $baseUri = New-Object System.Uri($baseFull)
    $fileUri = New-Object System.Uri((Resolve-Path -LiteralPath $FullPath).Path)
    $rel = $baseUri.MakeRelativeUri($fileUri).ToString()
    return [Uri]::UnescapeDataString($rel).Replace('\','/')
}

function Read-AddonXmlFromZip([string]$ZipPath) {
    Add-Type -AssemblyName System.IO.Compression.FileSystem | Out-Null
    $zip = [System.IO.Compression.ZipFile]::OpenRead($ZipPath)
    try {
        $entry = $zip.Entries | Where-Object {
            $_.FullName -match '(^|/)addon\.xml$'
        } | Select-Object -First 1

        if (-not $entry) {
            throw "addon.xml not found inside zip: $ZipPath"
        }

        $reader = New-Object System.IO.StreamReader($entry.Open(), [Text.Encoding]::UTF8, $true)
        try {
            return $reader.ReadToEnd()
        }
        finally {
            $reader.Close()
        }
    }
    finally {
        $zip.Dispose()
    }
}

function Read-TextUtf8([string]$Path) {
    return [IO.File]::ReadAllText($Path, [Text.Encoding]::UTF8)
}

function Strip-XmlDeclaration([string]$Text) {
    return ($Text -replace '^\s*<\?xml[^>]*\?>\s*', '').Trim()
}

function Parse-AddonItem([string]$XmlText, [string]$SourcePath, [string]$ZipPath) {
    $clean = Strip-XmlDeclaration $XmlText
    [xml]$doc = $clean
    if (-not $doc.addon) {
        throw "Not an addon.xml: $SourcePath"
    }

    $id = [string]$doc.addon.id
    $version = [string]$doc.addon.version
    $name = [string]$doc.addon.name

    if ([string]::IsNullOrWhiteSpace($id)) {
        throw "addon id missing: $SourcePath"
    }
    if ([string]::IsNullOrWhiteSpace($version)) {
        $version = "0.0.0"
    }
    if ([string]::IsNullOrWhiteSpace($name)) {
        $name = $id
    }

    return [pscustomobject]@{
        Id = $id
        Version = $version
        Name = $name
        Xml = $clean
        SourcePath = $SourcePath
        ZipPath = $ZipPath
    }
}

$RepoRoot = Get-RepoRoot $RepoRoot
Write-Host "[repo] Updating index: $RepoRoot"

$items = @()
$seen = @{}

# Prefer repository add-on XML from its folder, so Kodi can install the repo itself cleanly.
$repoAddonXmlFiles = Get-ChildItem -LiteralPath $RepoRoot -Directory -ErrorAction SilentlyContinue |
    Where-Object { $_.Name -like "repository.*" } |
    ForEach-Object { Join-Path $_.FullName "addon.xml" } |
    Where-Object { Test-Path -LiteralPath $_ }

foreach ($xmlFile in $repoAddonXmlFiles) {
    try {
        $xmlText = Read-TextUtf8 $xmlFile
        $item = Parse-AddonItem $xmlText $xmlFile $null
        $key = $item.Id.ToLowerInvariant()
        if (-not $seen.ContainsKey($key)) {
            $seen[$key] = $true
            $items += $item
            Write-Host ("  OK {0} v{1}" -f $item.Id, $item.Version)
        }
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}

# Add every addon zip in addon-id folders. Keep only one version per id, normally the one just imported.
$zipFiles = Get-ChildItem -LiteralPath $RepoRoot -Directory -ErrorAction SilentlyContinue |
    Where-Object {
        $_.Name -notin @("_tools", "_incoming_addons", ".git", ".github") -and
        $_.Name -notlike "_*" -and
        $_.Name -ne "zips"
    } |
    ForEach-Object {
        Get-ChildItem -LiteralPath $_.FullName -Filter "*.zip" -File -ErrorAction SilentlyContinue
    } |
    Sort-Object FullName

foreach ($zip in $zipFiles) {
    try {
        $xmlText = Read-AddonXmlFromZip $zip.FullName
        $item = Parse-AddonItem $xmlText $zip.FullName $zip.FullName
        $key = $item.Id.ToLowerInvariant()

        if ($seen.ContainsKey($key)) {
            # Repository add-on XML already added from folder. Skip duplicate zip copy.
            continue
        }

        $seen[$key] = $true
        $items += $item
        Write-Host ("  OK {0} v{1}" -f $item.Id, $item.Version)
    }
    catch {
        Write-Warning $_.Exception.Message
    }
}

$items = $items | Sort-Object Id

if ($items.Count -eq 0) {
    throw "No valid add-ons found. Nothing to write."
}

$addonsXmlLines = New-Object System.Collections.Generic.List[string]
$addonsXmlLines.Add('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>')
$addonsXmlLines.Add('<addons>')
foreach ($item in $items) {
    $addonsXmlLines.Add($item.Xml)
}
$addonsXmlLines.Add('</addons>')

$addonsXml = ($addonsXmlLines -join "`n") + "`n"
$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
$addonsXmlPath = Join-Path $RepoRoot "addons.xml"
[IO.File]::WriteAllText($addonsXmlPath, $addonsXml, $utf8NoBom)

$md5 = (Get-FileHash -LiteralPath $addonsXmlPath -Algorithm MD5).Hash.ToLowerInvariant()
[IO.File]::WriteAllText((Join-Path $RepoRoot "addons.xml.md5"), $md5, $utf8NoBom)

# Simple GitHub Pages index.
$indexLines = New-Object System.Collections.Generic.List[string]
$indexLines.Add('<!doctype html>')
$indexLines.Add('<html lang="en">')
$indexLines.Add('<head>')
$indexLines.Add('  <meta charset="utf-8">')
$indexLines.Add('  <meta name="viewport" content="width=device-width, initial-scale=1">')
$indexLines.Add('  <title>MrGee Kodi Repository</title>')
$indexLines.Add('  <style>body{font-family:Arial,sans-serif;margin:32px;line-height:1.5} code{background:#eee;padding:2px 5px;border-radius:4px}</style>')
$indexLines.Add('</head>')
$indexLines.Add('<body>')
$indexLines.Add('  <h1>MrGee Kodi Repository</h1>')
$indexLines.Add('  <p>Kodi repository files:</p>')
$indexLines.Add('  <ul>')
$indexLines.Add('    <li><a href="addons.xml">addons.xml</a></li>')
$indexLines.Add('    <li><a href="addons.xml.md5">addons.xml.md5</a></li>')

$repoZip = Get-ChildItem -LiteralPath (Join-Path $RepoRoot "repository.mrgee.kodi") -Filter "repository.mrgee.kodi-*.zip" -File -ErrorAction SilentlyContinue |
    Sort-Object Name -Descending |
    Select-Object -First 1
if ($repoZip) {
    $repoRel = Get-RelativePathCompat $RepoRoot $repoZip.FullName
    $repoRelHtml = Escape-Html $repoRel
    $indexLines.Add("    <li><a href=""$repoRelHtml"">Install repository zip</a></li>")
}
$indexLines.Add('  </ul>')

$indexLines.Add('  <h2>Add-ons</h2>')
$indexLines.Add('  <ul>')
foreach ($item in $items) {
    if ($item.ZipPath) {
        $rel = Get-RelativePathCompat $RepoRoot $item.ZipPath
        $relHtml = Escape-Html $rel
        $label = Escape-Html ("{0} v{1}" -f $item.Id, $item.Version)
        $indexLines.Add("    <li><a href=""$relHtml"">$label</a></li>")
    }
}
$indexLines.Add('  </ul>')
$indexLines.Add('</body>')
$indexLines.Add('</html>')

[IO.File]::WriteAllText((Join-Path $RepoRoot "index.html"), (($indexLines -join "`n") + "`n"), $utf8NoBom)

Write-Host ""
Write-Host "[repo] Updated:"
Write-Host "  $addonsXmlPath"
Write-Host ("  {0}" -f (Join-Path $RepoRoot "addons.xml.md5"))
Write-Host ("  {0}" -f (Join-Path $RepoRoot "index.html"))
Write-Host ("[repo] Add-ons indexed: {0}" -f $items.Count)
