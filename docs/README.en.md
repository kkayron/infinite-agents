# ∞ Infinite Agents

> **Run Claude Code & Codex CLI for free — with 4-key NVIDIA NIM load balancing and automatic failover. Zero cost. Fully autonomous.**

Built on top of the incredible [free-claude-code](https://github.com/Alishahryar1/free-claude-code) by [@Alishahryar1](https://github.com/Alishahryar1). This project adds a production-grade LiteLLM router layer with multi-key resilience and SystemD auto-start.

---

## 🌐 Translations

| Language | Link |
|---|---|
| 🇧🇷 Português (main) | [README.md](../README.md) |
| 🇺🇸 English | This file |
| 🇨🇳 中文 | [README.zh.md](README.zh.md) |
| 🇮🇳 हिंदी | [README.hi.md](README.hi.md) |
| 🇪🇸 Español | [README.es.md](README.es.md) |
| 🇫🇷 Français | [README.fr.md](README.fr.md) |

---

## ✨ What's Different From free-claude-code?

| Feature | free-claude-code | infinite-agents |
|---|---|---|
| Runs Claude Code for free | ✅ | ✅ |
| Runs Codex CLI for free | ✅ | ✅ |
| NVIDIA NIM backend | ✅ | ✅ |
| Multi-key load balancing | ❌ | ✅ |
| Automatic failover (4 keys) | ❌ | ✅ |
| Auto-start on boot (SystemD) | ❌ | ✅ |
| Zero manual commands after setup | ❌ | ✅ |

---

## 🧠 Architecture

```
Claude Code / Codex CLI
        │
        ▼
  fcc-server :8082          ← free-claude-code proxy
  (Anthropic → OpenAI)
        │
        ▼
  LiteLLM Router :4000      ← load balancer
  (4-key round-robin)
        │
    ┌───┴────────────────────┐
    │                        │
 Key 1   Key 2   Key 3   Key 4
    └──────── NVIDIA NIM ────────┘
           (cloud inference)

Models:
  claude-3-5-sonnet → meta/llama-3.1-70b-instruct       (copy, marketing, frontend)
  gpt-4o            → mistralai/mistral-medium-3.5-128b  (code, logic, backend)
```

---

## 📋 Requirements

- Linux (Ubuntu 20.04+ recommended)
- Python 3.10+
- `uv` package manager
- At least 1 NVIDIA NIM API key (free at [build.nvidia.com](https://build.nvidia.com))
- `systemd` (user session)

---

## 🚀 Installation

### Option A — Automatic (recommended)

```bash
git clone https://github.com/kkayron/infinite-agents.git
cd infinite-agents
chmod +x install.sh
./install.sh
```

Then edit `~/litellm_proxy/config.yaml` and replace the placeholders with your keys.

---

### Option B — Manual

#### Step 1 — Install `uv`

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc
```

#### Step 2 — Install free-claude-code

```bash
uv tool install free-claude-code
```

#### Step 3 — Install LiteLLM

```bash
mkdir -p ~/litellm_proxy && cd ~/litellm_proxy
python3 -m venv venv && source venv/bin/activate
pip install litellm[proxy]
```

#### Step 4 — Configure LiteLLM

Copy `config.example.yaml` to `~/litellm_proxy/config.yaml` and replace `YOUR_KEY_1..4` with your NVIDIA NIM keys.

> 💡 Get free NVIDIA NIM API keys at [build.nvidia.com](https://build.nvidia.com).

#### Step 5 — Configure free-claude-code

Edit `~/.fcc/.env`:

```env
LM_STUDIO_BASE_URL=http://127.0.0.1:4000/v1
MODEL=lmstudio/claude-3-5-sonnet-20240620
MODEL_OPUS=lmstudio/gpt-4o
MODEL_SONNET=lmstudio/claude-3-5-sonnet-20240620
MODEL_HAIKU=lmstudio/claude-3-5-sonnet-20240620
```

#### Step 6 — Create SystemD Services

```bash
# LiteLLM
cat > ~/.config/systemd/user/litellm.service << 'EOF'
[Unit]
Description=LiteLLM Proxy Router
After=network.target
[Service]
WorkingDirectory=%h/litellm_proxy
ExecStart=%h/litellm_proxy/venv/bin/litellm --config %h/litellm_proxy/config.yaml --port 4000
Restart=always
RestartSec=5
[Install]
WantedBy=default.target
EOF

# fcc-server
cat > ~/.config/systemd/user/fcc-server.service << 'EOF'
[Unit]
Description=Free Claude Code Server
After=litellm.service
Requires=litellm.service
[Service]
ExecStart=%h/.local/bin/fcc-server
Restart=always
RestartSec=5
[Install]
WantedBy=default.target
EOF

systemctl --user daemon-reload
systemctl --user enable --now litellm.service fcc-server.service
```

#### Step 7 — Launch!

```bash
fcc-claude   # Claude Code + Llama 3.1 70B
fcc-codex    # Codex CLI + Mistral 128B
```

Type `/model` and select `lmstudio/gpt-4o` or `lmstudio/claude-3-5-sonnet-20240620`.

---

## 🧩 Model Guide

| Alias | Backend | Best for |
|---|---|---|
| `lmstudio/claude-3-5-sonnet-20240620` | Llama 3.1 70B | Marketing, copy, frontend, creative |
| `lmstudio/gpt-4o` | Mistral 128B | Code, logic, backend, debugging |

---

## 🤝 Credits

- **[free-claude-code](https://github.com/Alishahryar1/free-claude-code)** by [@Alishahryar1](https://github.com/Alishahryar1)
- **[LiteLLM](https://github.com/BerriAI/litellm)** — open-source multi-provider router
- **[NVIDIA NIM](https://build.nvidia.com)** — free inference API

## 📄 License

MIT
