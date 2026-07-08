#!/usr/bin/env bash
# =============================================================
# infinite-agents — Automated Setup Script (Linux & macOS)
# https://github.com/kkayron/infinite-agents
# =============================================================
# Windows users: use WSL2 + run this script inside Ubuntu terminal
# https://learn.microsoft.com/windows/wsl/install

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "  ∞ infinite-agents"
echo "  NVIDIA NIM multi-key swarm — Linux & macOS installer"
echo -e "${NC}"

# Detect OS
OS="$(uname -s)"
case "$OS" in
  Linux*)   PLATFORM="linux" ;;
  Darwin*)  PLATFORM="mac" ;;
  *)        echo -e "${RED}Unsupported OS: $OS. Use install.bat on Windows.${NC}"; exit 1 ;;
esac
echo -e "${GREEN}Platform detected: $OS${NC}"

# ----- Check / Install uv -----
if ! command -v uv &>/dev/null; then
  echo -e "${YELLOW}[1/6] Installing uv...${NC}"
  curl -LsSf https://astral.sh/uv/install.sh | sh
  # Ensure uv is on PATH immediately
  export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
  source "$HOME/.bashrc" 2>/dev/null || source "$HOME/.zshrc" 2>/dev/null || true
else
  echo -e "${GREEN}[1/6] uv already installed ✓${NC}"
fi

# Ensure uv tools are on PATH
export PATH="$HOME/.local/bin:$PATH"

# ----- Install free-claude-code -----
echo -e "${YELLOW}[2/6] Installing free-claude-code...${NC}"
uv tool install free-claude-code
echo -e "${GREEN}✓ fcc-claude and fcc-codex installed${NC}"

# ----- Install LiteLLM -----
echo -e "${YELLOW}[3/6] Setting up LiteLLM proxy...${NC}"
mkdir -p "$HOME/litellm_proxy"
python3 -m venv "$HOME/litellm_proxy/venv"
"$HOME/litellm_proxy/venv/bin/pip" install --quiet "litellm[proxy]"
echo -e "${GREEN}✓ LiteLLM installed${NC}"

# ----- Config files -----
echo -e "${YELLOW}[4/6] Copying config files...${NC}"

if [ ! -f "$HOME/litellm_proxy/config.yaml" ]; then
  cp config.example.yaml "$HOME/litellm_proxy/config.yaml"
  echo -e "${GREEN}✓ config.yaml → ~/litellm_proxy/config.yaml${NC}"
  echo -e "${YELLOW}  ⚠ Replace YOUR_KEY_1..4 with your NVIDIA NIM keys${NC}"
else
  echo "  config.yaml already exists, skipping."
fi

mkdir -p "$HOME/.fcc"
if [ ! -f "$HOME/.fcc/.env" ]; then
  cp .env.example "$HOME/.fcc/.env"
  echo -e "${GREEN}✓ .env → ~/.fcc/.env${NC}"
else
  echo "  ~/.fcc/.env already exists, skipping."
fi

# ----- Auto-start services -----
echo -e "${YELLOW}[5/6] Configuring auto-start services...${NC}"

if [ "$PLATFORM" = "linux" ]; then
  mkdir -p "$HOME/.config/systemd/user"

  sed "s|%HOME%|$HOME|g" services/litellm.service > "$HOME/.config/systemd/user/litellm.service"
  sed "s|%HOME%|$HOME|g" services/fcc-server.service > "$HOME/.config/systemd/user/fcc-server.service"

  systemctl --user daemon-reload
  systemctl --user enable litellm.service fcc-server.service
  systemctl --user start litellm.service fcc-server.service
  # Enable linger so services survive after logout
  loginctl enable-linger "$(whoami)" 2>/dev/null || true
  echo -e "${GREEN}✓ SystemD services enabled and started (linger active)${NC}"

elif [ "$PLATFORM" = "mac" ]; then
  mkdir -p "$HOME/Library/LaunchAgents"

  sed "s|%HOME%|$HOME|g" services/litellm.plist > "$HOME/Library/LaunchAgents/com.infinite-agents.litellm.plist"
  sed "s|%HOME%|$HOME|g" services/fcc-server.plist > "$HOME/Library/LaunchAgents/com.infinite-agents.fcc-server.plist"

  launchctl load "$HOME/Library/LaunchAgents/com.infinite-agents.litellm.plist"
  launchctl load "$HOME/Library/LaunchAgents/com.infinite-agents.fcc-server.plist"
  echo -e "${GREEN}✓ launchd agents loaded${NC}"
  # macOS PATH fix: add uv tools to shell profile
  SHELL_RC="$HOME/.zshrc"
  [ -f "$HOME/.bash_profile" ] && SHELL_RC="$HOME/.bash_profile"
  if ! grep -q '.local/bin' "$SHELL_RC" 2>/dev/null; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_RC"
    echo -e "${YELLOW}  ⚠ PATH updated in $SHELL_RC — restart your terminal or run: source $SHELL_RC${NC}"
  fi
fi

# ----- Done -----
echo -e "${YELLOW}[6/6] Done!${NC}"
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  ∞ Setup complete!"
echo ""
echo "  NEXT STEP:"
echo "  Edit ~/litellm_proxy/config.yaml"
echo "  Replace YOUR_KEY_1..4 with real NVIDIA NIM keys"
echo "  Get free keys: https://build.nvidia.com"
echo ""
echo "  Then restart services:"
if [ "$PLATFORM" = "linux" ]; then
echo "  systemctl --user restart litellm.service fcc-server.service"
elif [ "$PLATFORM" = "mac" ]; then
echo "  launchctl stop com.infinite-agents.litellm"
echo "  launchctl start com.infinite-agents.litellm"
fi
echo ""
echo "  Launch:"
echo "  fcc-claude   ← Claude Code + Llama 70B"
echo "  fcc-codex    ← Codex CLI + Mistral 128B"
echo ""
echo "  Inside the agent: type /model → select lmstudio/*"
echo -e "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
