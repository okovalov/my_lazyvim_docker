#!/usr/bin/bash

CONFIG_DIR="/home/developer/.config/nvim"
SHARE_DIR="/home/developer/.local/share/nvim"
STATE_DIR="/home/developer/.local/state/nvim"
CACHE_DIR="/home/developer/.cache/nvim"

# We need to check if the volume was just created and needs initialization
if [ ! -d "$CONFIG_DIR/lua" ]; then
  echo "=== First run: Initializing LazyVim with default config ==="

  # Remove existing content if any (volume might be empty but dir exists)
  rm -rf "$CONFIG_DIR" 2>/dev/null || true
  rm -rf "$SHARE_DIR" 2>/dev/null || true
  rm -rf "$STATE_DIR" 2>/dev/null || true
  rm -rf "$CACHE_DIR" 2>/dev/null || true

  git clone https://github.com/LazyVim/starter "$CONFIG_DIR"

  rm -rf "$CONFIG_DIR/.git"

  echo "=== Default Initialization complete! ==="
fi

if [ -d "/tmp/lua_saved" ]; then
  echo "Copying custom configuration from /tmp/lua_saved..."
  mkdir -p "$CONFIG_DIR/lua"

  # Use rsync or copy with overwrite
  rsync -a /tmp/lua_saved/ "$CONFIG_DIR/lua/" 2>/dev/null ||
    cp -r /tmp/lua_saved/* "$CONFIG_DIR/lua/" 2>/dev/null || true

  # lazygit config
  mkdir -p "/home/developer/.config/lazygit"

  if [ -f "/tmp/lazygit_config.yml" ]; then
    cp /tmp/lazygit_config.yml "/home/developer/.config/lazygit/config.yml"
  fi

  echo "=== Custom Initialization complete! ==="
fi
