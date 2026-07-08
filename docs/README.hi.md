# ∞ Infinite Agents

> **Claude Code और Codex CLI को मुफ्त में चलाएं — 4 NVIDIA NIM कुंजियों के साथ लोड बैलेंसिंग और स्वचालित फेलओवर। शून्य लागत। पूरी तरह स्वायत्त।**

[@Alishahryar1](https://github.com/Alishahryar1) के [free-claude-code](https://github.com/Alishahryar1/free-claude-code) पर आधारित। यह प्रोजेक्ट मल्टी-की रेजिलिएंस और SystemD ऑटो-स्टार्ट के साथ LiteLLM राउटर लेयर जोड़ता है।

---

## 🌐 अनुवाद

| भाषा | लिंक |
|---|---|
| 🇧🇷 Português (मुख्य) | [README.md](../README.md) |
| 🇺🇸 English | [README.en.md](README.en.md) |
| 🇨🇳 中文 | [README.zh.md](README.zh.md) |
| 🇮🇳 हिंदी | वर्तमान फ़ाइल |
| 🇪🇸 Español | [README.es.md](README.es.md) |
| 🇫🇷 Français | [README.fr.md](README.fr.md) |

---

## ✨ free-claude-code से क्या अलग है?

| सुविधा | free-claude-code | infinite-agents |
|---|---|---|
| Claude Code मुफ्त में चलाएं | ✅ | ✅ |
| Codex CLI मुफ्त में चलाएं | ✅ | ✅ |
| NVIDIA NIM बैकएंड | ✅ | ✅ |
| मल्टी-की लोड बैलेंसिंग | ❌ | ✅ |
| स्वचालित फेलओवर (4 कुंजियां) | ❌ | ✅ |
| बूट पर ऑटो-स्टार्ट (SystemD) | ❌ | ✅ |
| सेटअप के बाद शून्य मैनुअल कमांड | ❌ | ✅ |

---

## 🧠 आर्किटेक्चर

```
Claude Code / Codex CLI
        │
        ▼
  fcc-server :8082          ← free-claude-code प्रॉक्सी
  (Anthropic → OpenAI रूपांतरण)
        │
        ▼
  LiteLLM Router :4000      ← लोड बैलेंसर
  (4-कुंजी राउंड-रॉबिन)
        │
    ┌───┴────────────────────┐
    │                        │
 कुंजी1  कुंजी2  कुंजी3  कुंजी4
    └──────── NVIDIA NIM ────────┘
           (क्लाउड इंफेरेंस)
```

---

## 🚀 इंस्टॉलेशन

### विकल्प A — स्वचालित (अनुशंसित)

```bash
git clone https://github.com/kkayron/infinite-agents.git
cd infinite-agents
chmod +x install.sh
./install.sh
```

फिर `~/litellm_proxy/config.yaml` संपादित करें और प्लेसहोल्डर को अपनी NVIDIA NIM कुंजियों से बदलें।

---

### विकल्प B — मैनुअल

#### चरण 1 — `uv` इंस्टॉल करें

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
source ~/.bashrc
```

#### चरण 2 — free-claude-code इंस्टॉल करें

```bash
uv tool install free-claude-code
```

#### चरण 3 — LiteLLM इंस्टॉल करें

```bash
mkdir -p ~/litellm_proxy && cd ~/litellm_proxy
python3 -m venv venv && source venv/bin/activate
pip install litellm[proxy]
```

#### चरण 4 — ~/.fcc/.env कॉन्फ़िगर करें

```env
LM_STUDIO_BASE_URL=http://127.0.0.1:4000/v1
MODEL=lmstudio/claude-3-5-sonnet-20240620
MODEL_OPUS=lmstudio/gpt-4o
MODEL_SONNET=lmstudio/claude-3-5-sonnet-20240620
MODEL_HAIKU=lmstudio/claude-3-5-sonnet-20240620
```

#### चरण 5 — एजेंट लॉन्च करें!

```bash
fcc-claude   # Claude Code + Llama 3.1 70B
fcc-codex    # Codex CLI + Mistral 128B
```

---

## 🤝 क्रेडिट

- **[free-claude-code](https://github.com/Alishahryar1/free-claude-code)** by [@Alishahryar1](https://github.com/Alishahryar1)
- **[LiteLLM](https://github.com/BerriAI/litellm)**
- **[NVIDIA NIM](https://build.nvidia.com)**

## 📄 लाइसेंस

MIT
