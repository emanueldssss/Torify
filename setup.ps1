<#
.SYNOPSIS
  Setup script for Torify — Tor + Proxychains wrapper for opencode.
.DESCRIPTION
  Downloads Tor Expert Bundle + Proxychains-Windows, creates configs,
  and compiles the torify.exe menu launcher.
#>

$ErrorActionPreference = "Stop"
$Base = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "`n  ========================" -ForegroundColor Magenta
Write-Host "     TORIFY - Setup" -ForegroundColor Magenta
Write-Host "  ========================" -ForegroundColor Magenta
Write-Host "`n"

# ─── 1. Download Tor Expert Bundle ───────────────────────────────────
$TorDir    = "$Base\tor"
$TorZip    = "$Base\tor-win64.zip"
$TorUrl    = "https://www.torproject.org/dist/torbrowser/14.0.6/tor-win64-14.0.6.zip"
# Mirror fallback if primary fails
$TorUrlMir = "https://archive.torproject.org/tor-package-archive/torbrowser/14.0.6/tor-win64-14.0.6.zip"

if (!(Test-Path "$TorDir\tor.exe")) {
    Write-Host "  [*] Baixando Tor Expert Bundle...`n" -ForegroundColor Cyan

    try {
        Invoke-WebRequest -Uri $TorUrl -OutFile $TorZip -UseBasicParsing -TimeoutSec 120
    } catch {
        Write-Host "  [!] Primary URL failed, trying mirror..." -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri $TorUrlMir -OutFile $TorZip -UseBasicParsing -TimeoutSec 120
        } catch {
            Write-Host "  [!] Erro ao baixar Tor. Baixe manualmente de:" -ForegroundColor Red
            Write-Host "      $TorUrl" -ForegroundColor Red
            Write-Host "  [!] Extraia o conteudo para: $TorDir" -ForegroundColor Red
            exit 1
        }
    }

    Write-Host "  [*] Extraindo Tor..." -ForegroundColor Cyan
    Expand-Archive -Path $TorZip -DestinationPath $Base -Force
    # The zip extracts to a subfolder like "tor" — ensure structure
    if (Test-Path "$Base\tor") {
        Write-Host "  [+] Tor extraido em $TorDir" -ForegroundColor Green
    } else {
        # Find the extracted folder
        $extracted = Get-ChildItem "$Base\tor-win64-*" -Directory | Select-Object -First 1
        if ($extracted) {
            Move-Item $extracted.FullName $TorDir -Force
        } else {
            Write-Host "  [!] Extraido mas nao encontrei a pasta. Verifique manualmente." -ForegroundColor Red
        }
    }
    Remove-Item $TorZip -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "  [+] Tor ja baixado." -ForegroundColor Green
}

# ─── 2. Create torrc ─────────────────────────────────────────────────
$TorData = "$TorDir\Data\Tor"
if (!(Test-Path $TorData)) { New-Item -ItemType Directory -Path $TorData -Force | Out-Null }

$torrc = @"
SOCKSPort 127.0.0.1:9050
ControlPort 127.0.0.1:9051
CookieAuthentication 0
DataDirectory $TorData
GeoIPFile $TorDir\Data\Tor\geoip
GeoIPv6File $TorDir\Data\Tor\geoip6
Log notice stdout
"@

$torrc | Out-File -FilePath "$TorData\torrc" -Encoding ASCII -Force
Write-Host "  [+] torrc criado." -ForegroundColor Green

# ─── 3. Download Proxychains-Windows ─────────────────────────────────
$PcDir    = "$Base\proxychains"
$PcZip    = "$Base\proxychains.zip"
$PcUrl    = "https://github.com/Mr-xn/proxychains-windows/releases/download/0.6.8/proxychains_win32_x64.zip"

if (!(Test-Path "$PcDir\proxychains_win32_x64.exe")) {
    Write-Host "`n  [*] Baixando Proxychains-Windows..." -ForegroundColor Cyan

    try {
        Invoke-WebRequest -Uri $PcUrl -OutFile $PcZip -UseBasicParsing -TimeoutSec 60
    } catch {
        Write-Host "  [!] Erro ao baixar proxychains. Baixe manualmente:" -ForegroundColor Red
        Write-Host "      $PcUrl" -ForegroundColor Red
        Write-Host "      Extraia para: $PcDir" -ForegroundColor Red
        exit 1
    }

    Write-Host "  [*] Extraindo Proxychains..." -ForegroundColor Cyan
    Expand-Archive -Path $PcZip -DestinationPath $PcDir -Force
    Remove-Item $PcZip -Force -ErrorAction SilentlyContinue
    Write-Host "  [+] Proxychains extraido em $PcDir" -ForegroundColor Green
} else {
    Write-Host "  [+] Proxychains ja baixado." -ForegroundColor Green
}

# ─── 4. Create proxychains.conf ──────────────────────────────────────
$pcConf = @"
strict_chain
proxy_dns
tcp_read_time_out 15000
tcp_connect_time_out 8000
[ProxyList]
socks5 127.0.0.1 9050
"@

$pcConf | Out-File -FilePath "$PcDir\proxychains.conf" -Encoding ASCII -Force
Write-Host "  [+] proxychains.conf criado." -ForegroundColor Green

# ─── 5. Compile torify.exe ───────────────────────────────────────────
Write-Host "`n  [*] Compilando torify.exe..." -ForegroundColor Cyan

$csc = "${env:windir}\Microsoft.NET\Framework\v4.0.30319\csc.exe"
if (!(Test-Path $csc)) {
    # Try other versions
    $csc = Get-ChildItem "${env:windir}\Microsoft.NET\Framework" -Recurse -Filter "csc.exe" | Select-Object -First 1 -ExpandProperty FullName
}
if (!($csc) -or !(Test-Path $csc)) {
    Write-Host "  [!] C# compiler (csc.exe) nao encontrado." -ForegroundColor Red
    Write-Host "  [!] Instale .NET Framework 4.x ou compile manualmente:" -ForegroundColor Red
    Write-Host "      ${env:windir}\Microsoft.NET\Framework\v4.0.30319\csc.exe src\torify.cs /out:torify.exe" -ForegroundColor Red
    exit 1
}

& $csc /target:exe /out:"$Base\torify.exe" "$Base\src\torify.cs" 2>&1 | Out-Null
if (Test-Path "$Base\torify.exe") {
    Write-Host "  [+] torify.exe compilado! ($((Get-Item "$Base\torify.exe").Length / 1KB) KB)" -ForegroundColor Green
} else {
    Write-Host "  [!] Erro na compilacao." -ForegroundColor Red
    exit 1
}

# ─── 6. Cleanup ──────────────────────────────────────────────────────
# Remove old scripts folder if it exists (legacy)
if (Test-Path "$Base\scripts") {
    Remove-Item "$Base\scripts" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "`n  ========================" -ForegroundColor Magenta
Write-Host "     Setup concluido!" -ForegroundColor Magenta
Write-Host "  ========================" -ForegroundColor Magenta
Write-Host "`n  Execute torify.exe para iniciar o menu.`n" -ForegroundColor Cyan
