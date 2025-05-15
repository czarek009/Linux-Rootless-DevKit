#!/bin/bash
set -e

# Install Rust
bash ./src/install_rust.sh

# Verify installation
source ~/.bashrc
if command -v rustc >/dev/null 2>&1; then
  rustc --version
else
  echo "❌ rustc not found after install."
  exit 1
fi

# Uninstall Rust
bash ./src/uninstall_rust.sh

# Verify uninstallation
if [ ! -d "$HOME/.cargo" ] && [ ! -d "$HOME/.rustup" ]; then
  echo "✅ Rust successfully uninstalled."
else
  echo "❌ Rust files still exist after uninstall."
  exit 1
fi

