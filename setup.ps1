<#
.SYNOPSIS
  Setup script for Torify â€” Tor + Proxychains wrapper for Windows.
.DESCRIPTION
  Downloads Tor Expert Bundle + Proxychains-Windows, creates configs,
  and compiles the torify.exe menu launcher.
#>

$ErrorActionPreference = "Stop"
$Base = "$env:LOCALAPPDATA\Torify"
$ScriptDir = $PSScriptRoot

if (!(Test-Path $Base)) { New-Item -ItemType Directory -Path $Base -Force | Out-Null }

Write-Host "`n  ========================" -ForegroundColor Magenta
Write-Host "     TORIFY v1.2 - Setup" -ForegroundColor Magenta
Write-Host "  ========================" -ForegroundColor Magenta
Write-Host "`n"

# â”€â”€â”€ 1. Download Tor Expert Bundle â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
$TorDir    = "$Base\tor"
$TorTarball = "$Base\tor-expert.tar.gz"
$TorVer    = "15.0.18"
$TorUrl    = "https://www.torproject.org/dist/torbrowser/$TorVer/tor-expert-bundle-windows-x86_64-$TorVer.tar.gz"
$TorUrlMir = "https://archive.torproject.org/tor-package-archive/torbrowser/$TorVer/tor-expert-bundle-windows-x86_64-$TorVer.tar.gz"

if (!(Test-Path "$TorDir\tor.exe")) {
    Write-Host "  [*] Baixando Tor Expert Bundle $TorVer...`n" -ForegroundColor Cyan

    $downloaded = $false
    foreach ($url in @($TorUrl, $TorUrlMir)) {
        try {
            Write-Host "      $url" -ForegroundColor DarkGray
            Invoke-WebRequest -Uri $url -OutFile $TorTarball -UseBasicParsing -TimeoutSec 120
            $downloaded = $true
            break
        } catch {
            Write-Host "      [!] falhou, tentando mirror..." -ForegroundColor Yellow
        }
    }

    if (-not $downloaded) {
        Write-Host "`n  [!] Erro ao baixar Tor. Baixe manualmente:" -ForegroundColor Red
        Write-Host "      $TorUrl" -ForegroundColor Red
        Write-Host "      Extraia o conteÃºdo para: $TorDir`n" -ForegroundColor Red
        Write-Host "      ApÃ³s baixar, extraia com:" -ForegroundColor Yellow
        Write-Host "      tar -xzf tor-expert-bundle-windows-x86_64-$TorVer.tar.gz -C `"$Base`"" -ForegroundColor Yellow
        exit 1
    }

    Write-Host "  [*] Extraindo Tor..." -ForegroundColor Cyan
    tar -xzf $TorTarball -C "$Base"
    if ($LASTEXITCODE -eq 0) {
        $extracted = Get-ChildItem "$Base\tor-expert-bundle-windows-*" -Directory | Select-Object -First 1
        if ($extracted) {
            if (Test-Path $TorDir) { Remove-Item $TorDir -Recurse -Force }
            Move-Item $extracted.FullName $TorDir -Force
            Write-Host "  [+] Tor extraÃ­do em $TorDir" -ForegroundColor Green
        } else {
            Write-Host "  [!] ExtraÃ­do mas pasta nÃ£o encontrada. Verifique manualmente." -ForegroundColor Red
        }
    } else {
        Write-Host "  [!] Erro na extraÃ§Ã£o. Tente manualmente." -ForegroundColor Red
        exit 1
    }
    Remove-Item $TorTarball -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "  [+] Tor jÃ¡ baixado." -ForegroundColor Green
}

# â”€â”€â”€ 2. Create torrc (sem GeoIP â€” bundle nÃ£o inclui esses arquivos) â”€â”€
$TorData = "$TorDir\Data\Tor"
if (!(Test-Path $TorData)) { New-Item -ItemType Directory -Path $TorData -Force | Out-Null }

$torrc = @"
SOCKSPort 127.0.0.1:9050
ControlPort 127.0.0.1:9051
CookieAuthentication 0
DataDirectory $TorData
Log notice stdout
"@

$torrc | Out-File -FilePath "$TorData\torrc" -Encoding ASCII -Force
Write-Host "  [+] torrc criado." -ForegroundColor Green

# â”€â”€â”€ 3. Download Proxychains-Windows â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
$PcDir    = "$Base\proxychains"
$PcZip    = "$Base\proxychains.zip"
$PcVer    = "0.6.8"
$PcUrl    = "https://github.com/shunf4/proxychains-windows/releases/download/$PcVer/proxychains_${PcVer}_win32_x64.zip"
$PcUrlMir = "https://github.com/shunf4/proxychains-windows/releases/download/$PcVer/proxychains_${PcVer}_win32_x64_debug.zip"

if (!(Test-Path "$PcDir\proxychains_win32_x64.exe")) {
    Write-Host "`n  [*] Baixando Proxychains-Windows $PcVer..." -ForegroundColor Cyan

    $downloaded = $false
    foreach ($url in @($PcUrl, $PcUrlMir)) {
        try {
            Write-Host "      $url" -ForegroundColor DarkGray
            Invoke-WebRequest -Uri $url -OutFile $PcZip -UseBasicParsing -TimeoutSec 60
            $downloaded = $true
            break
        } catch {
            Write-Host "      [!] falhou, tentando mirror..." -ForegroundColor Yellow
        }
    }

    if (-not $downloaded) {
        Write-Host "`n  [!] Erro ao baixar proxychains. Baixe manualmente:" -ForegroundColor Red
        Write-Host "      https://github.com/shunf4/proxychains-windows/releases" -ForegroundColor Red
        Write-Host "      Extraia para: $PcDir`n" -ForegroundColor Red
        exit 1
    }

    Write-Host "  [*] Extraindo Proxychains..." -ForegroundColor Cyan
    Expand-Archive -Path $PcZip -DestinationPath $PcDir -Force
    Remove-Item $PcZip -Force -ErrorAction SilentlyContinue
    Write-Host "  [+] Proxychains extraÃ­do em $PcDir" -ForegroundColor Green
} else {
    Write-Host "  [+] Proxychains jÃ¡ baixado." -ForegroundColor Green
}

# â”€â”€â”€ 4. Create proxychains.conf (dynamic_chain para resiliÃªncia) â”€â”€â”€â”€â”€
$pcConf = @"
dynamic_chain
proxy_dns
tcp_read_time_out 15000
tcp_connect_time_out 8000
[ProxyList]
socks5 127.0.0.1 9050
"@

$pcConf | Out-File -FilePath "$PcDir\proxychains.conf" -Encoding ASCII -Force
Write-Host "  [+] proxychains.conf criado (dynamic_chain)." -ForegroundColor Green

# â”€â”€â”€ 5. Compile torify.exe â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
Write-Host "`n  [*] Compilando torify.exe..." -ForegroundColor Cyan

# Fonte estÃ¡ no diretÃ³rio do script, nÃ£o no $Base!
$sourceFile = "$ScriptDir\src\torify.cs"
if (!(Test-Path $sourceFile)) {
    Write-Host "  [!] Fonte nÃ£o encontrado em: $sourceFile" -ForegroundColor Red
    Write-Host "  [!] Certifique-se de estar no diretÃ³rio do repositÃ³rio." -ForegroundColor Red
    exit 1
}

$csc = "${env:windir}\Microsoft.NET\Framework\v4.0.30319\csc.exe"
if (!(Test-Path $csc)) {
    $csc = Get-ChildItem "${env:windir}\Microsoft.NET\Framework" -Recurse -Filter "csc.exe" | Select-Object -First 1 -ExpandProperty FullName
}
if (!($csc) -or !(Test-Path $csc)) {
    Write-Host "  [!] Compilador C# (csc.exe) nÃ£o encontrado." -ForegroundColor Red
    Write-Host "  [!] Instale .NET Framework 4.x ou compile manualmente:" -ForegroundColor Red
    Write-Host "      ${env:windir}\Microsoft.NET\Framework\v4.0.30319\csc.exe src\torify.cs /out:torify.exe" -ForegroundColor Red
    exit 1
}

# Verifica se o Ã­cone existe antes de usÃ¡-lo
$iconFile = "$ScriptDir\torify.ico"
$iconArg = if (Test-Path $iconFile) { "/win32icon:`"$iconFile`"" } else { "" }

& $csc /target:exe /reference:System.Windows.Forms.dll $iconArg "/out:$Base\torify.exe" $sourceFile 2>&1 | Out-Null
if (Test-Path "$Base\torify.exe") {
    Write-Host "  [+] torify.exe compilado! ($((Get-Item "$Base\torify.exe").Length / 1KB) KB)" -ForegroundColor Green
} else {
    Write-Host "  [!] Erro na compilaÃ§Ã£o." -ForegroundColor Red
    exit 1
}

# â”€â”€â”€ 6. Cleanup â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
if (Test-Path "$Base\scripts") {
    Remove-Item "$Base\scripts" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "`n  ========================" -ForegroundColor Magenta
Write-Host "     Setup concluÃ­do!" -ForegroundColor Magenta
Write-Host "  ========================" -ForegroundColor Magenta
Write-Host "`n  Execute torify.exe para iniciar o menu.`n" -ForegroundColor Cyan
