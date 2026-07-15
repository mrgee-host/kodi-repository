param(
    [Parameter(Mandatory=$true)][string]$RepoRoot,
    [int]$WriteRetryCount = 20,
    [int]$WriteRetryDelayMs = 500
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

function Get-Md5HexFromText {
    param(
        [Parameter(Mandatory=$true)][string]$Content,
        [Parameter(Mandatory=$true)][System.Text.Encoding]$Encoding
    )

    $bytes = $Encoding.GetBytes($Content)
    $md5 = [System.Security.Cryptography.MD5]::Create()
    try {
        $hash = $md5.ComputeHash($bytes)
        return ([System.BitConverter]::ToString($hash)).Replace('-', '').ToLowerInvariant()
    }
    finally {
        $md5.Dispose()
    }
}

function Write-TextFileWithRetry {
    param(
        [Parameter(Mandatory=$true)][string]$Path,
        [Parameter(Mandatory=$true)][string]$Content,
        [Parameter(Mandatory=$true)][System.Text.Encoding]$Encoding,
        [int]$MaxAttempts = 20,
        [int]$DelayMilliseconds = 500
    )

    if ($MaxAttempts -lt 1) { $MaxAttempts = 1 }
    if ($DelayMilliseconds -lt 0) { $DelayMilliseconds = 0 }

    $directory = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $directory -PathType Container)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
    }

    # Avoid touching a mapped/open file when the generated content is unchanged.
    if (Test-Path -LiteralPath $Path -PathType Leaf) {
        try {
            $existing = [System.IO.File]::ReadAllText($Path, $Encoding)
            if ($existing -ceq $Content) {
                Write-Host "  unchanged: $Path"
                return
            }
        }
        catch {
            # Reading may also be blocked briefly. Continue into the retry loop.
        }
    }

    $lastError = $null

    for ($attempt = 1; $attempt -le $MaxAttempts; $attempt++) {
        $tempPath = Join-Path $directory ('.' + [System.IO.Path]::GetFileName($Path) + '.' + [guid]::NewGuid().ToString('N') + '.tmp')

        try {
            # Build the new file beside the destination first, so readers never see
            # a partially written addons.xml/index.html.
            [System.IO.File]::WriteAllText($tempPath, $Content, $Encoding)

            if (Test-Path -LiteralPath $Path -PathType Leaf) {
                try {
                    # Atomic replacement is preferred. On Windows this also avoids
                    # truncating the currently mapped destination in place.
                    [System.IO.File]::Replace($tempPath, $Path, $null, $true)
                }
                catch {
                    # Some filesystems do not support File.Replace. Fall back to a
                    # normal forced move before counting the attempt as failed.
                    Move-Item -LiteralPath $tempPath -Destination $Path -Force
                }
            }
            else {
                Move-Item -LiteralPath $tempPath -Destination $Path -Force
            }

            Write-Host "  wrote: $Path"
            return
        }
        catch [System.IO.IOException] {
            $lastError = $_.Exception
        }
        catch [System.UnauthorizedAccessException] {
            $lastError = $_.Exception
        }
        catch {
            $lastError = $_.Exception
        }
        finally {
            if (Test-Path -LiteralPath $tempPath) {
                Remove-Item -LiteralPath $tempPath -Force -ErrorAction SilentlyContinue
            }
        }

        if ($attempt -lt $MaxAttempts) {
            Write-Warning ("File busy: {0}. Retry {1}/{2} in {3} ms. {4}" -f $Path, $attempt, $MaxAttempts, $DelayMilliseconds, $lastError.Message)

            # Release any transient handles created by PowerShell/.NET before retrying.
            [System.GC]::Collect()
            [System.GC]::WaitForPendingFinalizers()
            Start-Sleep -Milliseconds $DelayMilliseconds
        }
    }

    throw ("Unable to write '{0}' after {1} attempts. Close Kodi, editors, preview panes, web servers, sync tools, or antivirus processes that keep the file mapped/open. Last error: {2}" -f $Path, $MaxAttempts, $lastError.Message)
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
$utf8NoBom = [System.Text.UTF8Encoding]::new($false)

$addonsXmlContent = $addonsXml -join "`n"
$md5Content = Get-Md5HexFromText -Content $addonsXmlContent -Encoding $utf8NoBom

Write-TextFileWithRetry -Path $addonsXmlPath -Content $addonsXmlContent -Encoding $utf8NoBom -MaxAttempts $WriteRetryCount -DelayMilliseconds $WriteRetryDelayMs
Write-TextFileWithRetry -Path $md5Path -Content $md5Content -Encoding $utf8NoBom -MaxAttempts $WriteRetryCount -DelayMilliseconds $WriteRetryDelayMs

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

$indexContent = $html -join "`n"
Write-TextFileWithRetry -Path $indexPath -Content $indexContent -Encoding $utf8NoBom -MaxAttempts $WriteRetryCount -DelayMilliseconds $WriteRetryDelayMs

Write-Host ""
Write-Host "[repo] Updated:"
Write-Host "  $addonsXmlPath"
Write-Host "  $md5Path"
Write-Host "  $indexPath"
Write-Host "[repo] Add-ons indexed: $($items.Count)"
exit 0
