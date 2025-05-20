#!/usr/bin/env bash
set -Eu

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_TOP_DIR="${SCRIPT_DIR}"

# Source rust install file
RUST_INSTALL_PATH="${PROJECT_TOP_DIR}/src/install_rust.sh"
if [[ -f "${RUST_INSTALL_PATH}" ]]; then
    source "${RUST_INSTALL_PATH}"
else
    echo "Error: Could not find install_rust.sh at ${RUST_INSTALL_PATH}"
    exit 1
fi

# Install rust
install_rust || exit 1

# Verify installation
source $HOME/.bashrc
if command -v rustc >/dev/null 2>&1; then
  rustc --version
else
  echo "❌ rustc not found after install."
  exit 1
fi

# Source rust uninstall file
RUST_UNINSTALL_PATH="${PROJECT_TOP_DIR}/src/uninstall_rust.sh"
if [[ -f "${RUST_UNINSTALL_PATH}" ]]; then
    source "${RUST_UNINSTALL_PATH}"
else
    echo "Error: Could not find uninstall_rust.sh at ${RUST_UNINSTALL_PATH}"
    exit 1
fi

# Uninstall Rust
uninstall_rust || exit 1

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


