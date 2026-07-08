# ∞ Infinite Agents

> **Ejecuta Claude Code y Codex CLI gratis — con balanceo de carga entre múltiples claves NVIDIA NIM y conmutación automática por error. Costo cero. Totalmente autónomo.**

Construido sobre el increíble [free-claude-code](https://github.com/Alishahryar1/free-claude-code) de [@Alishahryar1](https://github.com/Alishahryar1). Este proyecto agrega una capa de enrutamiento LiteLLM con resiliencia multi-clave y servicios nativos de inicio automático para Windows, macOS y Linux.

---

## 🌐 Traducciones

| Idioma | Enlace |
|---|---|
| 🇧🇷 Português (principal) | [README.md](../README.md) |
| 🇺🇸 English | [README.en.md](README.en.md) |
| 🇨🇳 中文 | [README.zh.md](README.zh.md) |
| 🇮🇳 हिंदी | [README.hi.md](README.hi.md) |
| 🇪🇸 Español | Archivo actual |
| 🇫🇷 Français | [README.fr.md](README.fr.md) |

---

## ✨ ¿Qué lo diferencia de free-claude-code?

| Característica | free-claude-code | infinite-agents |
|---|---|---|
| Ejecuta Claude Code gratis | ✅ | ✅ |
| Ejecuta Codex CLI gratis | ✅ | ✅ |
| Backend NVIDIA NIM | ✅ | ✅ |
| Balanceo de carga multi-clave | ❌ | ✅ |
| Conmutación automática (4 claves) | ❌ | ✅ |
| Inicio automático al arrancar | ❌ | ✅ |
| Soporte Windows, Mac y Linux | ❌ | ✅ |
| Cero comandos manuales tras instalar | ❌ | ✅ |

---

## 🧠 Arquitectura

```
Claude Code / Codex CLI
        │
        ▼
  fcc-server :8082          ← proxy de free-claude-code
  (Anthropic → OpenAI)
        │
        ▼
  LiteLLM Router :4000      ← balanceador de carga
  (round-robin entre claves)
        │
    ┌───┴────────────────────┐
    │                        │
 Clave1  Clave2  Clave3  Clave4
    └──────── NVIDIA NIM ────────┘
           (inferencia en la nube)

Modelos:
  claude-3-5-sonnet → meta/llama-3.1-70b-instruct       (copy, marketing, frontend)
  gpt-4o            → mistralai/mistral-medium-3.5-128b  (código, lógica, backend)
```

---

## 🚀 Instalación

### 🐧 Linux / 🍎 macOS

```bash
git clone https://github.com/kkayron/infinite-agents.git
cd infinite-agents
chmod +x install.sh
./install.sh
```

### 🪟 Windows

```batch
git clone https://github.com/kkayron/infinite-agents.git
cd infinite-agents
install.bat
```

> ⚠ Ejecuta `install.bat` como **Administrador**.

---

## ⚙️ Configuración

Edita `~/litellm_proxy/config.yaml` (Linux/Mac) o `%USERPROFILE%\litellm_proxy\config.yaml` (Windows):

```yaml
- model_name: "claude-3-5-sonnet-20240620"
  litellm_params:
    model: "nvidia_nim/meta/llama-3.1-70b-instruct"
    api_key: "nvapi-TU_CLAVE_REAL_AQUI"
```

> 💡 Obtén claves NVIDIA NIM gratis en [build.nvidia.com](https://build.nvidia.com).

---

## 🚦 Uso

```bash
fcc-claude   # Claude Code → Llama 3.1 70B
fcc-codex    # Codex CLI   → Mistral 128B
```

Escribe `/model` y selecciona `lmstudio/gpt-4o` o `lmstudio/claude-3-5-sonnet-20240620`.

---

## 🤝 Créditos

- **[free-claude-code](https://github.com/Alishahryar1/free-claude-code)** por [@Alishahryar1](https://github.com/Alishahryar1)
- **[LiteLLM](https://github.com/BerriAI/litellm)**
- **[NVIDIA NIM](https://build.nvidia.com)**

## 📄 Licencia

MIT
