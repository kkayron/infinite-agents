# ∞ Infinite Agents

> **免费运行 Claude Code 和 Codex CLI — 支持 4 密钥 NVIDIA NIM 负载均衡与自动故障转移。零成本，完全自主。**

基于 [@Alishahryar1](https://github.com/Alishahryar1) 的 [free-claude-code](https://github.com/Alishahryar1/free-claude-code) 构建。本项目新增了 LiteLLM 路由层，支持多密钥弹性与 SystemD 自动启动。

---

## 🌐 语言版本

| 语言 | 链接 |
|---|---|
| 🇧🇷 Português（主文档） | [README.md](../README.md) |
| 🇺🇸 English | [README.en.md](README.en.md) |
| 🇨🇳 中文 | 当前文件 |
| 🇮🇳 हिंदी | [README.hi.md](README.hi.md) |
| 🇪🇸 Español | [README.es.md](README.es.md) |
| 🇫🇷 Français | [README.fr.md](README.fr.md) |

---

## ✨ 与 free-claude-code 的区别

| 功能 | free-claude-code | infinite-agents |
|---|---|---|
| 免费运行 Claude Code | ✅ | ✅ |
| 免费运行 Codex CLI | ✅ | ✅ |
| NVIDIA NIM 后端 | ✅ | ✅ |
| 多密钥负载均衡 | ❌ | ✅ |
| 自动故障转移（4 个密钥） | ❌ | ✅ |
| 开机自动启动（SystemD） | ❌ | ✅ |
| 安装后零手动操作 | ❌ | ✅ |

---

## 🧠 架构

```
Claude Code / Codex CLI
        │
        ▼
  fcc-server :8082          ← free-claude-code 代理
  （Anthropic → OpenAI 格式转换）
        │
        ▼
  LiteLLM Router :4000      ← 负载均衡器
  （4 密钥轮询）
        │
    ┌───┴────────────────────┐
    │                        │
 密钥1  密钥2  密钥3  密钥4
    └──────── NVIDIA NIM ────────┘
           （云端推理）

模型映射：
  claude-3-5-sonnet → meta/llama-3.1-70b-instruct       （文案、营销、前端）
  gpt-4o            → mistralai/mistral-medium-3.5-128b  （代码、逻辑、后端）
```

---

## 📋 系统要求

- Linux（推荐 Ubuntu 20.04+）
- Python 3.10+
- `uv` 包管理器
- 至少 1 个 NVIDIA NIM API 密钥（免费获取：[build.nvidia.com](https://build.nvidia.com)）
- `systemd`（用户会话）

---

## 🚀 安装步骤

### 方式 A — 自动安装（推荐）

```bash
git clone https://github.com/kkayron/infinite-agents.git
cd infinite-agents
chmod +x install.sh
./install.sh
```

然后编辑 `~/litellm_proxy/config.yaml`，将占位符替换为您的密钥。

---

### 方式 B — 手动安装

#### 第 1 步 — 安装 `uv`

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc
```

#### 第 2 步 — 安装 free-claude-code

```bash
uv tool install free-claude-code
```

#### 第 3 步 — 安装 LiteLLM

```bash
mkdir -p ~/litellm_proxy && cd ~/litellm_proxy
python3 -m venv venv && source venv/bin/activate
pip install litellm[proxy]
```

#### 第 4 步 — 配置 LiteLLM

将 `config.example.yaml` 复制到 `~/litellm_proxy/config.yaml`，并将 `YOUR_KEY_1..4` 替换为您的 NVIDIA NIM 密钥。

> 💡 在 [build.nvidia.com](https://build.nvidia.com) 免费获取 NVIDIA NIM API 密钥。

#### 第 5 步 — 配置 free-claude-code

编辑 `~/.fcc/.env`：

```env
LM_STUDIO_BASE_URL=http://127.0.0.1:4000/v1
MODEL=lmstudio/claude-3-5-sonnet-20240620
MODEL_OPUS=lmstudio/gpt-4o
MODEL_SONNET=lmstudio/claude-3-5-sonnet-20240620
MODEL_HAIKU=lmstudio/claude-3-5-sonnet-20240620
```

#### 第 6 步 — 创建 SystemD 服务

```bash
systemctl --user daemon-reload
systemctl --user enable --now litellm.service fcc-server.service
```

详细的 service 文件请参考英文文档。

#### 第 7 步 — 启动！

```bash
fcc-claude   # Claude Code + Llama 3.1 70B
fcc-codex    # Codex CLI + Mistral 128B
```

输入 `/model` 并选择 `lmstudio/gpt-4o` 或 `lmstudio/claude-3-5-sonnet-20240620`。

---

## 🤝 致谢

- **[free-claude-code](https://github.com/Alishahryar1/free-claude-code)** by [@Alishahryar1](https://github.com/Alishahryar1)
- **[LiteLLM](https://github.com/BerriAI/litellm)** — 开源多提供商路由器
- **[NVIDIA NIM](https://build.nvidia.com)** — 免费推理 API

## 📄 许可证

MIT
