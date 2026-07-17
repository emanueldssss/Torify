# Torproxy-win

Roteie qualquer aplicativo Windows pelo Tor com um clique.

Inicia o Tor daemon, configura proxychains e abre programas selecionados passando pelo proxy — com rotacao automatica de IP a cada sessao. O terminal do menu nunca fecha; cada app abre em janela separada.

---

## Instalação

### Requisitos

- Windows 10 ou 11 (64-bit)
- .NET Framework 4.x (já vem instalado no Windows)

### Passo a passo

```powershell
# 1. Clone o repositorio
git clone https://github.com/emanueldssss/Torproxy-win.git
cd Torproxy-win

# 2. Execute o setup (baixa Tor + proxychains + compila o menu)
powershell -ExecutionPolicy Bypass -File setup.ps1
```

O setup baixa automaticamente o Tor Expert Bundle (~21 MB) e o Proxychains-Windows, cria os arquivos de configuracao (`torrc`, `proxychains.conf`) e compila o `torify.exe`. Nada manual, nada hardcoded.

### Opcional: atalho no desktop

```powershell
$ws = New-Object -ComObject WScript.Shell
$sc = $ws.CreateShortcut("$env:USERPROFILE\Desktop\Torproxy.lnk")
$sc.TargetPath = "C:\caminho\completo\ate\Torproxy-win\torify.exe"
$sc.WorkingDirectory = "C:\caminho\completo\ate\Torproxy-win"
$sc.Save()
```

---

## Como usar

Execute `torify.exe`. O menu:

```
  ========================
    TorProxy-Win v1.0
  ========================
  Tor + Proxychains for Windows
  ========================

  [1] Rodar TorProxy
  [2] Conferir IP
  [3] Configurar
  [4] Adicionar App
  [5] Abrir App com Tor
  [0] Sair

  ========================
```

### Primeiro uso: adicionar um aplicativo

**1. Menu > opcao 4 — Adicionar App**

Uma janela do Windows vai abrir para voce selecionar um arquivo `.exe`. Escolha o programa que voce quer rotear pelo Tor (navegador, cliente de chat, qualquer coisa).

Assim que selecionar, o programa:
- Salva o app numa lista (arquivo `apps.txt` na pasta do Torproxy)
- Inicia o Tor (se ainda nao tiver rodando)
- Abre o app via proxychains — o trafego dele vai passar pelo Tor

O terminal do menu continua aberto. Voce pode adicionar quantos apps quiser.

### Abrir um app salvo

**2. Menu > opcao 5 — Abrir App com Tor**

O menu mostra todos os apps que voce ja adicionou:

```
  Apps salvos:

  [1] Firefox
      C:\Program Files\Mozilla Firefox\firefox.exe
  [2] Discord
      C:\Users\voce\AppData\Local\Discord\Discord.exe
  [3] opencode
      C:\Users\voce\AppData\Roaming\npm\node_modules\opencode-ai\bin\opencode.exe

  [0] Voltar

  Escolha:
```

Digite o numero do app. O Torproxy:
1. Rotaciona o IP (SIGNAL NEWNYM)
2. Abre o app em janela separada com o trafego passando pelo Tor

### Verificar se o proxy esta funcionando

**3. Menu > opcao 2 — Conferir IP**

Mostra seu IP real (sem proxy) e o IP do Tor lado a lado. Se forem diferentes, esta roteando corretamente.

```
  IP real: 201.95.xx.xx
  IP Tor:  185.220.xxx.xxx

  [+] IPs DIFERENTES — Tor funcionando!
```

### Tudo de uma vez

**4. Menu > opcao 1 — Rodar TorProxy**

Faz tudo automatizado:
1. Inicia Tor
2. Rotaciona IP
3. Mostra IP real vs IP do Tor
4. Abre o aplicativo configurado (da opcao 3)

---

## Estrutura de arquivos

```
Torproxy-win/
├── src/torify.cs            # codigo fonte (C#)
├── setup.ps1                # instalacao completa
├── build.ps1                # compila o exe manualmente
├── .gitignore
├── README.md
│
├── torify.exe               # menu compilado (gerado pelo setup)
├── apps.txt                 # lista de apps que voce adicionou
├── target-app.txt           # caminho do app padrao (opcao 3)
│
├── tor/                     # Tor Expert Bundle (baixado pelo setup)
│   ├── tor.exe
│   └── Data/Tor/torrc
│
└── proxychains/             # proxychains-windows (baixado pelo setup)
    ├── proxychains_win32_x64.exe
    └── proxychains.conf
```

Tudo portatil. Nada registra no sistema. Copie a pasta inteira para outro PC que funciona — so rodar `setup.ps1` de novo para baixar as dependencias.

---

## Recompilar manualmente

Se quiser modificar o codigo e recompilar:

```powershell
.\build.ps1
```

Ou direto com o compilador C#:

```powershell
& "$env:windir\Microsoft.NET\Framework\v4.0.30319\csc.exe" `
    /target:exe `
    /reference:System.Windows.Forms.dll `
    /out:torify.exe `
    src\torify.cs
```

---

## Sobre

Ferramenta gratuita e open-source. Usa o [Tor Expert Bundle](https://www.torproject.org/) da comunidade Tor Project e o [proxychains-windows](https://github.com/shunf4/proxychains-windows) mantido por shunf4.
