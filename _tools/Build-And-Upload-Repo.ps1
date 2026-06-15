# Build and upload MrGee Kodi repository.
$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'Build-Repo.ps1')
& (Join-Path $PSScriptRoot 'Upload-Repo.ps1')
