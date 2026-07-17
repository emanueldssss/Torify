# Torproxy-win

Tor + Proxychains wrapper para opencode.  
Roteia o trafego do opencode pelo Tor com rotacao automatica de IP.

---

## Como funciona

- **Tor daemon** roda localmente (SOCKS5 `127.0.0.1:9050`)
- **Proxychains-Windows** hookeia Winsock e redireciona conexoes
- **torify.exe** (menu em C#) coordena tudo: inicia Tor, rotaciona IP, abre opencode em janela separada

O terminal do menu **nao fecha** — o opencode abre numa janela nova independente.

---

## Instalacao

### Requisitos
- Windows 10/11 (64-bit)
- Node.js + npm
- opencode instalado globalmente: `npm install -g opencode-ai`
- .NET Framework 4.x (ja vem instalado)

### Setup

```powershell
git clone https://github.com/emanueldssss/Torproxy-win.git
cd Torproxy-win
powershell -ExecutionPolicy Bypass -File setup.ps1
```

O setup baixa Tor Expert Bundle + Proxychains-Windows, cria as configs e compila o `torify.exe`.

---

## Uso

Execute `torify.exe`. Menu:

```
  [1] Rodar TorProxy
  [2] Conferir IP
  [3] Configurar
  [0] Sair
```

### Opcao 1
1. Inicia Tor (se necessario)
2. Rotaciona IP via SIGNAL NEWNYM
3. Mostra IP real vs IP do Tor
4. Abre opencode em nova janela

### Opcao 2
Verifica se o proxy esta funcionando (IP real vs IP Tor).

### Opcao 3
Configura caminho personalizado do opencode. Digite `auto` para detectar automaticamente.

---

## Estrutura

```
Torproxy-win/
├── src/torify.cs          # codigo fonte (C#)
├── setup.ps1              # instalacao completa
├── build.ps1              # compila o exe
├── .gitignore
├── README.md
├── torify.exe             # compilado
├── tor/                   # Tor Expert Bundle
└── proxychains/           # proxychains-windows
```

Paths sao detectados automaticamente — funciona em qualquer maquina.

---

## Compilar manualmente

```powershell
.\build.ps1
```

Ou:

```powershell
& "$env:windir\Microsoft.NET\Framework\v4.0.30319\csc.exe" /target:exe /out:torify.exe src\torify.cs
```

---

## Descricao curta (para o repo)

> Tor + Proxychains wrapper for opencode. Roteia o trafego do opencode pelo Tor com rotacao automatica de IP. Menu em C# com Windows translucido. Nao fecha o terminal ao abrir o opencode. Portatil — paths detectados automaticamente.
