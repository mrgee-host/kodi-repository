param([string]$BaseUrl = 'https://mrgee-host.github.io/kodi-repository')
$ErrorActionPreference = 'Stop'
$urls = @("$BaseUrl/", "$BaseUrl/addons.xml", "$BaseUrl/addons.xml.md5", "$BaseUrl/repository.mrgee.kodi/repository.mrgee.kodi-1.0.0.zip")
foreach ($u in $urls) {
    try {
        $r = Invoke-WebRequest -Uri $u -UseBasicParsing -Method Head -TimeoutSec 20
        Write-Host "OK $($r.StatusCode) $u" -ForegroundColor Green
    } catch {
        Write-Host "FAIL $u" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor DarkRed
    }
}
