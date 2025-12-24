#!/usr/bin/bash
# entrypoint.sh

CONFIG_DIR="/home/developer/.config/nvim"

# Check if config directory is empty (first run of container with this volume)
if [ -z "$(ls -A $CONFIG_DIR 2>/dev/null)" ]; then
  echo "=== First run: Initializing LazyVim with custom config ==="

  # Clone LazyVim
  git clone https://github.com/LazyVim/starter "$CONFIG_DIR"
  rm -rf "$CONFIG_DIR/.git"

  # Copy custom files if they exist
  if [ -d "/tmp/lua_saved" ]; then
    echo "Copying custom configuration from /tmp/lua_saved..."
    # Create lua directory if it doesn't exist
    mkdir -p "$CONFIG_DIR/lua"
    # Copy recursively
    cp -r /tmp/lua_saved/* "$CONFIG_DIR/lua/" 2>/dev/null || true
    echo "Custom config copied!"
  fi

  echo "=== Initialization complete! ==="
fi

# Execute the main command (nvim)
exec "$@"
