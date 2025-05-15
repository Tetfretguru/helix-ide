#!/bin/bash

set -e

# Install directory and version
INSTALL_DIR="$HOME/.local/bin"
CONFIG_DIR="$HOME/.config/helix"
CONFIG_FILE="./config.toml"

# Ensure necessary dirs
mkdir -p "$INSTALL_DIR"
mkdir -p "$CONFIG_DIR"

# 1. Download and install latest Helix (Linux x86_64)
echo "Installing Helix..."
LATEST_URL=$(curl -s https://api.github.com/repos/helix-editor/helix/releases/latest | grep browser_download_url | grep linux-x86_64.tar.xz | cut -d '"' -f 4)
curl -L "$LATEST_URL" -o helix.tar.xz
tar -xf helix.tar.xz
cp -r helix-*/hx "$INSTALL_DIR/"
rm -rf helix-*/ helix.tar.xz

# 2. Set alias if not present
if ! grep -q "alias hx=" "$HOME/.bashrc"; then
  echo "export COLORTERM=truecolor" >> "$HOME/.bashrc"
  echo "alias hx='function _hx() { if [ $# -eq 0 ]; then helix "$(fzf)"; else helix "$@"; fi }; _hx'" >> "$HOME/.bashrc"
  echo "Added alias to ~/.bashrc. Run 'source ~/.bashrc' or restart your shell."
fi

# 3. Copy config.toml
if [[ -f "$CONFIG_FILE" ]]; then
  echo "Backing up existing config (if any)..."
  cp "$CONFIG_DIR/config.toml" "$CONFIG_DIR/config.toml.bak" 2>/dev/null || true
  cp "$CONFIG_FILE" "$CONFIG_DIR/config.toml"
  echo "Copied your config.toml into $CONFIG_DIR"
  pip install --user ruff jedi-language-server python-lsp-server
else
  echo "❌ config.toml not found in the current directory."
  exit 1
fi

echo "✅ Helix installed and configured. Run: hx ."
