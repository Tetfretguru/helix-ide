#!/usr/bin/env bash

set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"
RUNTIME_DIR="$HOME/.local/share/helix/runtime"
CONFIG_DIR="$HOME/.config/helix"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

mkdir -p "$INSTALL_DIR"
mkdir -p "$RUNTIME_DIR"
mkdir -p "$CONFIG_DIR"

echo "Installing latest Helix binary and runtime..."
LATEST_URL="$(curl -s https://api.github.com/repos/helix-editor/helix/releases/latest | grep browser_download_url | grep linux-x86_64.tar.xz | cut -d '"' -f 4)"
TMP_DIR="$(mktemp -d)"

curl -L "$LATEST_URL" -o "$TMP_DIR/helix.tar.xz"
tar -xf "$TMP_DIR/helix.tar.xz" -C "$TMP_DIR"

HELIX_DIR="$(find "$TMP_DIR" -maxdepth 1 -type d -name 'helix-*' | head -n 1)"
cp "$HELIX_DIR/hx" "$INSTALL_DIR/hx"
cp -r "$HELIX_DIR/runtime/." "$RUNTIME_DIR/"

rm -rf "$TMP_DIR"

if ! grep -q 'export HELIX_RUNTIME=' "$HOME/.bashrc"; then
  {
    echo ''
    echo '# Helix runtime'
    echo 'export HELIX_RUNTIME="$HOME/.local/share/helix/runtime"'
  } >> "$HOME/.bashrc"
  echo "Added HELIX_RUNTIME export to ~/.bashrc"
fi

for file in config.toml languages.toml; do
  if [[ -f "$SCRIPT_DIR/$file" ]]; then
    cp "$CONFIG_DIR/$file" "$CONFIG_DIR/$file.bak" 2>/dev/null || true
    cp "$SCRIPT_DIR/$file" "$CONFIG_DIR/$file"
    echo "Copied $file -> $CONFIG_DIR/$file"
  else
    echo "Missing required file: $SCRIPT_DIR/$file"
    exit 1
  fi
done

echo "Installing language tooling (ruff, pylsp, shfmt)..."
python3 -m pip install --user ruff python-lsp-server

if command -v shfmt >/dev/null 2>&1; then
  echo "shfmt already installed"
else
  echo "Install shfmt manually for Bash formatting:"
  echo "  - apt: sudo apt install shfmt"
  echo "  - snap: sudo snap install shfmt"
fi

echo "Done. Restart shell or run: source ~/.bashrc"
echo "Then open Helix with: hx ."
