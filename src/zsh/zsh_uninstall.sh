#!/usr/bin/env bash
# This script uninstalls zsh + oh-my-zsh installed without sudo access.
LOGGER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../logger" && pwd)/script_logger.sh"
source "$LOGGER_PATH"

# Exit on error
set -e
#set -x

Logger::log_info "Starting uninstall of zsh and oh-my-zsh..."

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
    Logger::log_info "Removing oh-my-zsh..."
    rm -rf "${OH_MY_ZSH_DIR}"
else
     Logger::log_warning "Oh-my-zsh not found, skipping."
fi

# Remove custom zsh installation
if [[ -x "${ZSH_INSTALL_PATH}" ]]; then
    Logger::log_info "Removing custom zsh binaries..."
    rm -rf "${INSTALL_DIR}/bin/zsh"
    rm -rf "${INSTALL_DIR}/share/zsh"
    rm -rf "${INSTALL_DIR}/man/man1/zsh.1"
else
    Logger::log_warning "Zsh binary not found in ${INSTALL_DIR}/bin, skipping."
fi

# Remove source directory
if [[ -d "${SRC_DIR}/zsh-${ZSH_VERSION}" ]]; then
    Logger::log_info "Removing zsh source directory..."
    rm -rf "${SRC_DIR}/zsh-${ZSH_VERSION}"
fi

if [[ -f "${SRC_DIR}/zsh-${ZSH_VERSION}.tar.xz" ]]; then
    Logger::log_info "Removing zsh archive..."
    rm -f "${SRC_DIR}/zsh-${ZSH_VERSION}.tar.xz"
fi

# Clean up .bashrc and .zshrc

# Remove 'exec zsh' and 'local/bin' export from .bashrc
if [[ -f "${BASHRC}" ]]; then
    Logger::log_info "Cleaning up .bashrc..."
    sed -i '/# Start zsh if available/,/fi/d' "${BASHRC}"
    sed -i '/local\/bin/d' "${BASHRC}"
fi

# Remove .zshrc file
if [[ -f "${ZSHRC}" ]]; then
    Logger::log_info "Removing .zshrc..."
    rm -f "${ZSHRC}"
fi

# Remove zsh leftovers:
Logger::log_info "Removing zsh leftovers..."
rm -f ~/.zshrc ~/.zsh_history ~/.zshenv ~/.zprofile ~/.zlogin ~/.p10k.zsh

##### DONE:
Logger::log_info "Uninstall done - restart ur terminal"
