# ∞ Infinite Agents

> **Rode Claude Code & Codex CLI de graça — com balanceamento de carga entre múltiplas chaves NVIDIA NIM e failover automático. Custo zero. Totalmente autônomo.**

Construído sobre o incrível [free-claude-code](https://github.com/Alishahryar1/free-claude-code) por [@Alishahryar1](https://github.com/Alishahryar1). Este projeto adiciona uma camada de roteamento LiteLLM com resiliência multi-chave e serviços nativos de auto-start para Windows, macOS e Linux.

---

## 🌐 Traduções

| Idioma | Link |
|---|---|
| 🇧🇷 Português (principal) | Este arquivo |
| 🇺🇸 English | [docs/README.en.md](docs/README.en.md) |
| 🇨🇳 中文 | [docs/README.zh.md](docs/README.zh.md) |
| 🇮🇳 हिंदी | [docs/README.hi.md](docs/README.hi.md) |
| 🇪🇸 Español | [docs/README.es.md](docs/README.es.md) |
| 🇫🇷 Français | [docs/README.fr.md](docs/README.fr.md) |

---

## ✨ O Que Diferencia do free-claude-code?

| Funcionalidade | free-claude-code | infinite-agents |
|---|---|---|
| Roda Claude Code de graça | ✅ | ✅ |
| Roda Codex CLI de graça | ✅ | ✅ |
| Backend NVIDIA NIM | ✅ | ✅ |
| Balanceamento entre múltiplas chaves | ❌ | ✅ |
| Failover automático | ❌ | ✅ |
| Auto-start no boot | ❌ | ✅ |
| Suporte a Windows, Mac e Linux | ❌ | ✅ |
| Zero comandos manuais após instalação | ❌ | ✅ |

---

## 🧠 Arquitetura

```
Claude Code / Codex CLI
        │
        ▼
  fcc-server :8082          ← proxy do free-claude-code
  (Anthropic → OpenAI)
        │
        ▼
  LiteLLM Router :4000      ← balanceador de carga
  (round-robin entre chaves)
        │
    ┌───┴────────────────────┐
    │                        │
 Chave 1   Chave 2   Chave 3   Chave 4
    └──────── NVIDIA NIM ────────┘
           (inferência na nuvem)

Modelos:
  claude-3-5-sonnet → meta/llama-3.1-70b-instruct       (copy, marketing, frontend)
  gpt-4o            → mistralai/mistral-medium-3.5-128b  (código, lógica, backend)
```

---

## 📋 Requisitos

| | Windows | macOS | Linux |
|---|---|---|---|
| Python 3.10+ | ✅ | ✅ | ✅ |
| `uv` (auto-instalado) | ✅ | ✅ | ✅ |
| Auto-start | Pasta Startup | launchd | SystemD |

> 💡 Obtenha chaves NVIDIA NIM **grátis** em [build.nvidia.com](https://build.nvidia.com). Cada conta recebe créditos. Crie múltiplas contas para empilhar chaves.

---

## 🚀 Instalação

### 🐧 Linux

```bash
git clone https://github.com/kkayron/infinite-agents.git
cd infinite-agents
chmod +x install.sh
./install.sh
```

O script instala tudo e cria os serviços **SystemD** para auto-start no boot.

---

### 🍎 macOS

```bash
git clone https://github.com/kkayron/infinite-agents.git
cd infinite-agents
chmod +x install.sh
./install.sh
```

O mesmo script detecta o macOS automaticamente e usa **launchd** para auto-start.

---

### 🪟 Windows (via WSL2 — Recomendado)

> O `free-claude-code` e o `LiteLLM` dependem de recursos Unix. Use WSL2 para compatibilidade total.

**Passo 1:** Instale o WSL2 com Ubuntu
```powershell
# Abra o PowerShell como Administrador e execute:
wsl --install
# Reinicie o computador quando solicitado
```

**Passo 2:** Abra o terminal do Ubuntu (WSL) e execute:
```bash
git clone https://github.com/kkayron/infinite-agents.git
cd infinite-agents
chmod +x install.sh
./install.sh
```

> 💡 Após a instalação, use sempre o terminal Ubuntu (WSL) para rodar `fcc-claude` e `fcc-codex`.


---

## ⚙️ Configuração Manual (Pós-Instalação)

### 1. Editar as chaves NVIDIA NIM

Abra o arquivo `~/litellm_proxy/config.yaml` (Linux/Mac) ou `%USERPROFILE%\litellm_proxy\config.yaml` (Windows) e substitua os placeholders:

```yaml
model_list:
  - model_name: "claude-3-5-sonnet-20240620"
    litellm_params:
      model: "nvidia_nim/meta/llama-3.1-70b-instruct"
      api_key: "nvapi-SUA_CHAVE_REAL_AQUI"   # ← substitua aqui
  # ... (repita para cada chave)
```

### 2. Reiniciar os serviços

**Linux:**
```bash
systemctl --user restart litellm.service fcc-server.service
```

**macOS:**
```bash
launchctl stop com.infinite-agents.litellm && launchctl start com.infinite-agents.litellm
launchctl stop com.infinite-agents.fcc-server && launchctl start com.infinite-agents.fcc-server
```

**Windows:**
```batch
REM Feche e reabra os processos da pasta Startup
taskkill /IM litellm.exe /F
start %USERPROFILE%\litellm_proxy\start_litellm.bat
```

---

## 🚦 Usar os Agentes

```bash
fcc-claude   # Claude Code → Llama 3.1 70B (copy, frontend, criativo)
fcc-codex    # Codex CLI   → Mistral 128B  (código, backend, lógica)
```

Dentro do terminal, digite `/model` e selecione:
- `lmstudio/claude-3-5-sonnet-20240620` — para tarefas criativas
- `lmstudio/gpt-4o` — para código e lógica

---

## 🔍 Verificar Status / Logs

**Linux:**
```bash
systemctl --user status litellm.service fcc-server.service
journalctl --user -u litellm.service -n 50
```

**macOS:**
```bash
cat ~/litellm_proxy/litellm.log
cat ~/litellm_proxy/fcc-server.log
```

**Windows:**
```batch
type %USERPROFILE%\litellm_proxy\litellm.log
```

---

## 📁 Estrutura do Repositório

```
infinite-agents/
├── README.md                  ← Este arquivo (PT-BR)
├── install.sh                 ← Instalador Linux & macOS
├── install.bat                ← Instalador Windows
├── config.example.yaml        ← Config do LiteLLM (sem chaves reais)
├── .env.example               ← Config do fcc
├── .gitignore
├── docs/
│   ├── README.en.md           ← English
│   ├── README.zh.md           ← 中文
│   ├── README.hi.md           ← हिंदी
│   ├── README.es.md           ← Español
│   └── README.fr.md           ← Français
└── services/
    ├── litellm.service        ← SystemD (Linux)
    ├── fcc-server.service     ← SystemD (Linux)
    ├── litellm.plist          ← launchd (macOS)
    └── fcc-server.plist       ← launchd (macOS)
```

---

## 🤝 Créditos

- **[free-claude-code](https://github.com/Alishahryar1/free-claude-code)** por [@Alishahryar1](https://github.com/Alishahryar1) — o proxy original que faz Claude Code e Codex CLI funcionarem com provedores alternativos. Todo crédito pelo mecanismo de interceptação vai a eles.
- **[LiteLLM](https://github.com/BerriAI/litellm)** — roteador open-source multi-provedor.
- **[NVIDIA NIM](https://build.nvidia.com)** — API de inferência gratuita para modelos Llama e Mistral.

---

## 📄 Licença

MIT — livre para usar, modificar e distribuir.
