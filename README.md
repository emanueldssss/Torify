# Torify.Route

Roteamento anonimo via Tor com interface web e proxy local para outros apps.
Criado e mantido por Emanuel D. (eds / emanueldssss).

## O que ha aqui
- `torify.exe` — aplicativo (launcher + servidor + proxy Tor). autossuficiente.
- `torify.route.cmd` / `torify.route.ps1` — abrem um terminal ja com o proxy Tor aplicado.

## Uso rapido
1. rode `torify.exe` (baixa o Tor sozinho na primeira vez).
2. clique **start tor**, depois **check ip**.
3. para rotear OUTROS apps (opencode, curl...) pelo Tor: use os scripts
   `torify.route.cmd` / `torify.route.ps1`, ou defina
   `HTTPS_PROXY=http://127.0.0.1:8080` antes de abrir o app.

Codigo protegido. copia nao autorizada e roubo.
