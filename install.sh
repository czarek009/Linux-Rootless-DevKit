#!/usr/bin/env bash
set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_TOP_DIR="${SCRIPT_DIR}"
ENV_CONFIGURATOR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/src/envConfigurator" && pwd)/envConfigurator.sh"
ENV_VARIABLES="$(cd "$(dirname "${BASH_SOURCE[0]}")/src" && pwd)/env_variables.sh"
source "${ENV_CONFIGURATOR_PATH}"
source "${ENV_VARIABLES}"

CONFIG_SETUP_PATH="${PROJECT_TOP_DIR}/config_setup.sh"
if [[ -f "${CONFIG_SETUP_PATH}" ]]; then
    source "${CONFIG_SETUP_PATH}"
else
    Logger::log_error "Error: Could not find config_setup.sh at ${CONFIG_SETUP_PATH}"
    exit 1
fi
# Run the install configuration setup script
CONFIG_FILE="$1"
if [[ "$CONFIG_FILE" == "" ]]; then
    CONFIG_FILE="$SETTINGS_USER_YAML"
fi
EnvConfigurator::create_file_if_not_exists "$SETTINGS_USER_YAML"
Configurator::get_initial_config
Configurator::convert_yaml_to_settings_user
Configurator::generate_settings
source "${SETTINGS_FILE}"

# Read a chosen shell from the config file
SHELL_CHOICE="$ROOTLESS_CONFIG_SHELL_NAME"
# --- Apply Shell Setup ---

# Parameter for setting shell config file that will be used by a user (bashrc/zshrc)
SHELLRC_PATH="$HOME/.${SHELL_CHOICE}rc"
Logger::log_info "Using shell config file: ${SHELLRC_PATH}"

ZSH_INSTALL_PATH="${PROJECT_TOP_DIR}/src/zsh/zsh_install.sh"
if [[ "$SHELL_CHOICE" == "zsh" ]]; then
    if [[ -f "${ZSH_INSTALL_PATH}" ]]; then
        source "${ZSH_INSTALL_PATH}"
    else
        Logger::log_error "Error: Could not find zsh_install.sh at ${ZSH_INSTALL_PATH}"
        exit 1
    fi

    PRECONFIGURED_DIR="${PROJECT_TOP_DIR}/src/zsh/preconfigured"
    INSTALL_DIR="$HOME/.local"
    SRC_DIR="$HOME/src"
    ZSH_VERSION="$(Zsh::get_latest_available_zsh_version)"

    EnvConfigurator::create_dir_if_not_exists "$INSTALL_DIR"
    EnvConfigurator::create_dir_if_not_exists "$SRC_DIR"

    # Read Zsh customizations from config
    ZSH_INSTALL_OH_MY_ZSH="$ROOTLESS_CONFIG_SHELL_INSTALL_OH_MY"
    ZSH_PLUGINS="$ROOTLESS_CONFIG_OH_MY_PLUGINS"
    ZSH_FONTS="$ROOTLESS_CONFIG_OH_MY_FONTS"
    ZSH_THEME="$ROOTLESS_CONFIG_OH_MY_THEME"
    ZSH_ALIASES="$ROOTLESS_CONFIG_OH_MY_ALIASES"
    ZSH_INSTALL_VERSION="$ROOTLESS_CONFIG_ZSH_VERSION"
    
    # Install base Zsh + oh-my-zsh
    Zsh::install_with_config "$ZSH_INSTALL_OH_MY_ZSH" "$ZSH_PLUGINS" "$ZSH_FONTS" "$ZSH_THEME" "$ZSH_ALIASES" "$ZSH_INSTALL_VERSION"
    export PATH="$HOME/.local/bin:$PATH"

    Zsh::verify_installation | exit 1
elif [[ "$SHELL_CHOICE" == "bash" ]]; then
    # Install Oh My Bash
    OMB_INSTALL_PATH="${PROJECT_TOP_DIR}/src/bash/omb_install.sh"
    if [[ -f "${OMB_INSTALL_PATH}" ]]; then
        source "${OMB_INSTALL_PATH}"
    else
        Logger::log_error "Error: Could not find omb_install.sh at ${OMB_INSTALL_PATH}"
        exit 1
    fi

    Omb::install
    Omb::verify_installation | exit 1
else
    Logger::log_error "Invalid shell choice '$SHELL_CHOICE'. Please run the script again."
    exit 1
fi

Logger::log_success "$SHELL_CHOICE installation completed successfully."

