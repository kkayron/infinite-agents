# ∞ Infinite Agents

> **Exécutez Claude Code et Codex CLI gratuitement — avec équilibrage de charge multi-clés NVIDIA NIM et basculement automatique. Coût zéro. Entièrement autonome.**

Construit sur l'incroyable [free-claude-code](https://github.com/Alishahryar1/free-claude-code) de [@Alishahryar1](https://github.com/Alishahryar1). Ce projet ajoute une couche de routage LiteLLM avec résilience multi-clés et services de démarrage automatique natifs pour Windows, macOS et Linux.

---

## 🌐 Traductions

| Langue | Lien |
|---|---|
| 🇧🇷 Português (principal) | [README.md](../README.md) |
| 🇺🇸 English | [README.en.md](README.en.md) |
| 🇨🇳 中文 | [README.zh.md](README.zh.md) |
| 🇮🇳 हिंदी | [README.hi.md](README.hi.md) |
| 🇪🇸 Español | [README.es.md](README.es.md) |
| 🇫🇷 Français | Fichier actuel |

---

## ✨ Qu'est-ce qui le distingue de free-claude-code ?

| Fonctionnalité | free-claude-code | infinite-agents |
|---|---|---|
| Exécute Claude Code gratuitement | ✅ | ✅ |
| Exécute Codex CLI gratuitement | ✅ | ✅ |
| Backend NVIDIA NIM | ✅ | ✅ |
| Équilibrage de charge multi-clés | ❌ | ✅ |
| Basculement automatique (4 clés) | ❌ | ✅ |
| Démarrage automatique au boot | ❌ | ✅ |
| Support Windows, Mac et Linux | ❌ | ✅ |
| Zéro commande manuelle après installation | ❌ | ✅ |

---

## 🧠 Architecture

```
Claude Code / Codex CLI
        │
        ▼
  fcc-server :8082          ← proxy de free-claude-code
  (Anthropic → OpenAI)
        │
        ▼
  LiteLLM Router :4000      ← équilibreur de charge
  (round-robin entre les clés)
        │
    ┌───┴────────────────────┐
    │                        │
 Clé 1   Clé 2   Clé 3   Clé 4
    └──────── NVIDIA NIM ────────┘
           (inférence cloud)

Modèles :
  claude-3-5-sonnet → meta/llama-3.1-70b-instruct       (copie, marketing, frontend)
  gpt-4o            → mistralai/mistral-medium-3.5-128b  (code, logique, backend)
```

---

## 🚀 Installation

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

> ⚠ Exécutez `install.bat` en tant qu'**Administrateur**.

---

## ⚙️ Configuration

Éditez `~/litellm_proxy/config.yaml` (Linux/Mac) ou `%USERPROFILE%\litellm_proxy\config.yaml` (Windows) :

```yaml
- model_name: "claude-3-5-sonnet-20240620"
  litellm_params:
    model: "nvidia_nim/meta/llama-3.1-70b-instruct"
    api_key: "nvapi-VOTRE_CLE_REELLE"
```

> 💡 Obtenez des clés NVIDIA NIM gratuites sur [build.nvidia.com](https://build.nvidia.com).

---

## 🚦 Utilisation

```bash
fcc-claude   # Claude Code → Llama 3.1 70B
fcc-codex    # Codex CLI   → Mistral 128B
```

Tapez `/model` et sélectionnez `lmstudio/gpt-4o` ou `lmstudio/claude-3-5-sonnet-20240620`.

---

## 🤝 Crédits

- **[free-claude-code](https://github.com/Alishahryar1/free-claude-code)** par [@Alishahryar1](https://github.com/Alishahryar1)
- **[LiteLLM](https://github.com/BerriAI/litellm)**
- **[NVIDIA NIM](https://build.nvidia.com)**

## 📄 Licence

MIT
