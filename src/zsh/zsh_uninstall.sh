#!/usr/bin/env bash

# This script uninstalls zsh + oh-my-zsh installed without sudo access.

# Exit on error
#set -e
#set -x

echo "ℹ️ Starting uninstall of zsh and oh-my-zsh..."

# Variables
ZSH_VERSION="5.9"
INSTALL_DIR="${HOME}/.local"
SRC_DIR="${HOME}/src"
ZSH_INSTALL_PATH="${INSTALL_DIR}/bin/zsh"
OH_MY_ZSH_DIR="${HOME}/.oh-my-zsh"
ZSHRC="${HOME}/.zshrc"
BASHRC="${HOME}/.bashrc"

##### UNINSTALL:

# Remove oh-my-zsh
if [[ -d "${OH_MY_ZSH_DIR}" ]]; then
    echo "ℹ️ Removing oh-my-zsh..."
    rm -rf "${OH_MY_ZSH_DIR}"
else
    echo "⚠️ Oh-my-zsh not found, skipping."
fi

# Remove custom zsh installation
if [[ -x "${ZSH_INSTALL_PATH}" ]]; then
    echo "ℹ️ Removing custom zsh binaries..."
    rm -rf "${INSTALL_DIR}/bin/zsh"
    rm -rf "${INSTALL_DIR}/share/zsh"
    rm -rf "${INSTALL_DIR}/man/man1/zsh.1"
else
    echo "⚠️ Zsh binary not found in ${INSTALL_DIR}/bin, skipping."
fi

# Remove source directory
if [[ -d "${SRC_DIR}/zsh-${ZSH_VERSION}" ]]; then
    echo "ℹ️ Removing zsh source directory..."
    rm -rf "${SRC_DIR}/zsh-${ZSH_VERSION}"
fi

if [[ -f "${SRC_DIR}/zsh-${ZSH_VERSION}.tar.xz" ]]; then
    echo "ℹ️ Removing zsh archive..."
    rm -f "${SRC_DIR}/zsh-${ZSH_VERSION}.tar.xz"
fi

# Clean up .bashrc and .zshrc

# Remove 'exec zsh' and 'local/bin' export from .bashrc
if [[ -f "${BASHRC}" ]]; then
    echo "ℹ️ Cleaning up .bashrc..."
    sed -i '/# Start zsh if available/,/fi/d' "${BASHRC}"
    sed -i '/local\/bin/d' "${BASHRC}"
fi

# Remove .zshrc file
if [[ -f "${ZSHRC}" ]]; then
    echo "ℹ️ Removing .zshrc..."
    rm -f "${ZSHRC}"
fi

# Remove zsh leftovers:
echo "ℹ️ Removing zsh leftovers..."
rm -f ~/.zshrc ~/.zsh_history ~/.zshenv ~/.zprofile ~/.zlogin ~/.p10k.zsh

##### DONE:
echo "✔ Uninstall done - restart ur terminal"

