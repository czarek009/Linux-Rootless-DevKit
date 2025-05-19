#!/bin/bash
set -e

# Install Rust
bash ./src/install_rust.sh

export PATH="$HOME/.cargo/bin:$PATH"

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

# Intall zsh
bash ./src/zsh/zshInstall.sh
export PATH="$HOME/.local/bin:$PATH"
source $HOME/.bashrc

# Verify installation
if command -v zsh >/dev/null 2>&1; then
  zsh --version
  echo "✅ zsh successfully installed."
else
  echo "❌ zsh not found after install."
  exit 1
fi

# Uninstall zsh
bash ./src/zsh/zshUninstall.sh
source $HOME/.bashrc

# Verify uninstallation
if [ ! -d "$HOME/.oh-my-zsh" ] && [ ! -d "$HOME/.local/bin/zsh" ]; then
  echo "✅ zsh successfully uninstalled."
else
  echo "❌ zsh files still exist after uninstall."
  exit 1
fi


