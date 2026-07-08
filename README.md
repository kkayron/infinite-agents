# ∞ Infinite Agents

> **Run Claude Code & Codex CLI for free — with 4-key NVIDIA NIM load balancing and automatic failover. Zero cost. Fully autonomous.**

Built on top of the incredible [free-claude-code](https://github.com/Alishahryar1/free-claude-code) by [@Alishahryar1](https://github.com/Alishahryar1). This project adds a production-grade LiteLLM router layer with multi-key resilience and SystemD auto-start.

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
    ┌───┴───┐
    │       │
 Key 1   Key 2   Key 3   Key 4
    └──────NVIDIA NIM──────┘
         (cloud inference)

Models:
  claude-3-5-sonnet → meta/llama-3.1-70b-instruct  (copy, marketing, frontend)
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

### Step 1 — Install `uv`

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc
```

### Step 2 — Install free-claude-code

```bash
uv tool install free-claude-code
```

This gives you the `fcc-claude` and `fcc-codex` commands.

### Step 3 — Install LiteLLM

```bash
mkdir -p ~/litellm_proxy
cd ~/litellm_proxy
python3 -m venv venv
source venv/bin/activate
pip install litellm[proxy]
```

### Step 4 — Configure LiteLLM

Create `~/litellm_proxy/config.yaml`:

```yaml
model_list:
  # ==========================================
  # CLAUDE CODE (Llama 3.1 70B via NVIDIA NIM)
  # ==========================================
  - model_name: "claude-3-5-sonnet-20240620"
    litellm_params:
      model: "nvidia_nim/meta/llama-3.1-70b-instruct"
      api_key: "nvapi-YOUR_KEY_1"
  - model_name: "claude-3-5-sonnet-20240620"
    litellm_params:
      model: "nvidia_nim/meta/llama-3.1-70b-instruct"
      api_key: "nvapi-YOUR_KEY_2"
  - model_name: "claude-3-5-sonnet-20240620"
    litellm_params:
      model: "nvidia_nim/meta/llama-3.1-70b-instruct"
      api_key: "nvapi-YOUR_KEY_3"
  - model_name: "claude-3-5-sonnet-20240620"
    litellm_params:
      model: "nvidia_nim/meta/llama-3.1-70b-instruct"
      api_key: "nvapi-YOUR_KEY_4"

  # ==========================================
  # CODEX (Mistral 128B via NVIDIA NIM)
  # ==========================================
  - model_name: "gpt-4o"
    litellm_params:
      model: "nvidia_nim/mistralai/mistral-medium-3.5-128b"
      api_key: "nvapi-YOUR_KEY_1"
  - model_name: "gpt-4o"
    litellm_params:
      model: "nvidia_nim/mistralai/mistral-medium-3.5-128b"
      api_key: "nvapi-YOUR_KEY_2"
  - model_name: "gpt-4o"
    litellm_params:
      model: "nvidia_nim/mistralai/mistral-medium-3.5-128b"
      api_key: "nvapi-YOUR_KEY_3"
  - model_name: "gpt-4o"
    litellm_params:
      model: "nvidia_nim/mistralai/mistral-medium-3.5-128b"
      api_key: "nvapi-YOUR_KEY_4"

litellm_settings:
  drop_params: True

router_settings:
  routing_strategy: "usage-based-routing-v2"
  num_retries: 3
```

> 💡 Get free NVIDIA NIM API keys at [build.nvidia.com](https://build.nvidia.com). Each account gets credits. Create multiple accounts to stack keys.

### Step 5 — Configure free-claude-code

Edit `~/.fcc/.env`:

```env
LM_STUDIO_BASE_URL=http://127.0.0.1:4000/v1

MODEL=lmstudio/claude-3-5-sonnet-20240620
MODEL_OPUS=lmstudio/gpt-4o
MODEL_SONNET=lmstudio/claude-3-5-sonnet-20240620
MODEL_HAIKU=lmstudio/claude-3-5-sonnet-20240620
```

### Step 6 — Create SystemD Services (Auto-start on boot)

**LiteLLM service:**

```bash
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
```

**fcc-server service:**

```bash
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
```

**Enable and start:**

```bash
systemctl --user daemon-reload
systemctl --user enable litellm.service fcc-server.service
systemctl --user start litellm.service fcc-server.service
```

### Step 7 — Launch your agents!

```bash
fcc-claude   # Claude Code with Llama 3.1 70B
fcc-codex    # OpenAI Codex with Mistral 128B
```

Inside the terminal, type `/model` and select `lmstudio/gpt-4o` or `lmstudio/claude-3-5-sonnet-20240620`.

---

## 🔍 Check Status

```bash
systemctl --user status litellm.service
systemctl --user status fcc-server.service

# View logs
journalctl --user -u litellm.service -n 50
journalctl --user -u fcc-server.service -n 50
```

---

## 🧩 Model Guide

| Model alias | Backend | Best for |
|---|---|---|
| `lmstudio/claude-3-5-sonnet-20240620` | Llama 3.1 70B | Marketing, copy, frontend, creative |
| `lmstudio/gpt-4o` | Mistral 128B | Code, logic, backend, debugging |

---

## 🤝 Credits

This project is a layer built on top of:

- **[free-claude-code](https://github.com/Alishahryar1/free-claude-code)** by [@Alishahryar1](https://github.com/Alishahryar1) — the core proxy that makes Claude Code and Codex CLI work with alternative providers. All credit for the original interception mechanism goes to them.
- **[LiteLLM](https://github.com/BerriAI/litellm)** — the open-source router that powers the multi-key balancing.
- **[NVIDIA NIM](https://build.nvidia.com)** — free inference API for Llama and Mistral models.

---

## 📄 License

MIT — free to use, modify, and distribute.
