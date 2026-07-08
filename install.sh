#!/usr/bin/env bash
# =============================================================
# infinite-agents — Automated Setup Script
# https://github.com/yourusername/infinite-agents
# =============================================================

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}"
echo "  ∞ infinite-agents setup"
echo "  NVIDIA NIM multi-key swarm for Claude Code & Codex"
echo -e "${NC}"

# ----- Check dependencies -----
command -v python3 >/dev/null 2>&1 || { echo -e "${RED}Python3 not found. Please install it.${NC}"; exit 1; }
command -v uv >/dev/null 2>&1 || {
  echo -e "${YELLOW}Installing uv...${NC}"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  source "$HOME/.bashrc" 2>/dev/null || source "$HOME/.profile" 2>/dev/null || true
}

# ----- Install free-claude-code -----
echo -e "${YELLOW}[1/5] Installing free-claude-code...${NC}"
uv tool install free-claude-code
echo -e "${GREEN}✓ fcc-claude and fcc-codex installed${NC}"

# ----- Install LiteLLM -----
echo -e "${YELLOW}[2/5] Setting up LiteLLM proxy...${NC}"
mkdir -p "$HOME/litellm_proxy"
python3 -m venv "$HOME/litellm_proxy/venv"
"$HOME/litellm_proxy/venv/bin/pip" install --quiet "litellm[proxy]"
echo -e "${GREEN}✓ LiteLLM installed${NC}"

# ----- Config files -----
echo -e "${YELLOW}[3/5] Copying config files...${NC}"

if [ ! -f "$HOME/litellm_proxy/config.yaml" ]; then
  cp config.example.yaml "$HOME/litellm_proxy/config.yaml"
  echo -e "${GREEN}✓ config.yaml copied to ~/litellm_proxy/${NC}"
  echo -e "${YELLOW}  ⚠ Open ~/litellm_proxy/config.yaml and replace YOUR_KEY_1..4 with your NVIDIA NIM keys${NC}"
else
  echo "  config.yaml already exists, skipping."
fi

if [ ! -f "$HOME/.fcc/.env" ]; then
  mkdir -p "$HOME/.fcc"
  cp .env.example "$HOME/.fcc/.env"
  echo -e "${GREEN}✓ .env copied to ~/.fcc/.env${NC}"
else
  echo "  ~/.fcc/.env already exists, skipping."
fi

# ----- SystemD services -----
echo -e "${YELLOW}[4/5] Creating SystemD services...${NC}"
mkdir -p "$HOME/.config/systemd/user"

cat > "$HOME/.config/systemd/user/litellm.service" << EOF
[Unit]
Description=LiteLLM Proxy Router (infinite-agents)
After=network.target

[Service]
WorkingDirectory=%h/litellm_proxy
ExecStart=%h/litellm_proxy/venv/bin/litellm --config %h/litellm_proxy/config.yaml --port 4000
Restart=always
RestartSec=5

[Install]
WantedBy=default.target
EOF

cat > "$HOME/.config/systemd/user/fcc-server.service" << EOF
[Unit]
Description=Free Claude Code Server (infinite-agents)
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
systemctl --user enable litellm.service fcc-server.service
systemctl --user start litellm.service fcc-server.service

echo -e "${GREEN}✓ Services enabled and started${NC}"

# ----- Done -----
echo -e "${YELLOW}[5/5] Done!${NC}"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ∞ Setup complete!"
echo ""
echo "  1. Edit ~/litellm_proxy/config.yaml"
echo "     Replace YOUR_KEY_1..4 with your NVIDIA NIM keys"
echo "     Get free keys at: https://build.nvidia.com"
echo ""
echo "  2. Restart services:"
echo "     systemctl --user restart litellm.service fcc-server.service"
echo ""
echo "  3. Launch:"
echo "     fcc-claude   ← Claude Code + Llama 70B"
echo "     fcc-codex    ← Codex CLI + Mistral 128B"
echo ""
echo "  4. Inside the terminal, type /model and select lmstudio/*"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
