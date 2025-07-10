#!/usr/bin/env bash
# This script uninstalls zsh + oh-my-zsh installed without sudo access.
LOGGER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../logger" && pwd)/script_logger.sh"
ENV_CONFIGURATOR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../envConfigurator" && pwd)/envConfigurator.sh"
source "$LOGGER_PATH"
source "${ENV_CONFIGURATOR_PATH}"

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

##### UNINSTALL:

# Remove oh-my-zsh
Logger::log_info "Removing oh-my-zsh..."
EnvConfigurator::remove_dir_if_exists "${OH_MY_ZSH_DIR}" "y"


# Remove custom zsh installation
Logger::log_info "Removing custom zsh binaries..."
EnvConfigurator::remove_file_if_exists "${INSTALL_DIR}/bin/zsh"
EnvConfigurator::remove_file_if_exists "${INSTALL_DIR}/share/zsh"
EnvConfigurator::remove_file_if_exists "${INSTALL_DIR}/man/man1/zsh.1"


# Remove source directory
Logger::log_info "Removing zsh source directory..."
EnvConfigurator::remove_dir_if_exists "${SRC_DIR}/zsh-${ZSH_VERSION}" "y"

Logger::log_info "Removing zsh archive..."
EnvConfigurator::remove_file_if_exists "${SRC_DIR}/zsh-${ZSH_VERSION}.tar.xz"


# Remove .zshrc file
Logger::log_info "Removing .zshrc..."
EnvConfigurator::remove_file_if_exists "${ZSHRC}"


# Remove zsh leftovers:
Logger::log_info "Removing zsh leftovers..."
EnvConfigurator::remove_file_if_exists ~/.zshrc 
EnvConfigurator::remove_file_if_exists ~/.zsh_history
EnvConfigurator::remove_file_if_exists ~/.zshenv
EnvConfigurator::remove_file_if_exists ~/.zprofile 
EnvConfigurator::remove_file_if_exists ~/.zlogin
EnvConfigurator::remove_file_if_exists ~/.p10k.zsh

##### DONE:
Logger::log_info "Uninstall done - restart ur terminal"
