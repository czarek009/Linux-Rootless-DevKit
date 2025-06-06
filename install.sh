#!/usr/bin/env bash

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_TOP_DIR="${SCRIPT_DIR}"

CONFIG_SETUP_PATH="${PROJECT_TOP_DIR}/config_setup.sh"
if [[ -f "${CONFIG_SETUP_PATH}" ]]; then
    source "${CONFIG_SETUP_PATH}"
else
    echo "Error: Could not find config_setup.sh at ${CONFIG_SETUP_PATH}"
    exit 1
fi
# Run the install configuration setup script
get_initial_config



# Check if the first argument is provided
if [ -z "$1" ]; then
    echo "❌ Error: No config file path provided."
    echo "Usage: $0 <path-to-config.json>"
    exit 1
fi

CONFIG_FILE="$1"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "❌ Error: Config file not found at '$CONFIG_FILE'"
    exit 1
fi

# Read a chosen shell from the config file
SHELL_CHOICE=$(jq -r '.shell' "$CONFIG_FILE")

# --- Apply Shell Setup ---

# Parameter for setting shell config file that will be used by a user (bashrc/zshrc)
SHELLRC_PATH="$HOME/.${SHELL_CHOICE}rc"
echo "$SHELLRC_PATH"

ZSH_INSTALL_PATH="${PROJECT_TOP_DIR}/src/zsh/zshInstall.sh"
if [[ "$SHELL_CHOICE" == "zsh" ]]; then
    if [[ -f "${ZSH_INSTALL_PATH}" ]]; then
        source "${ZSH_INSTALL_PATH}"
    else
        echo "Error: Could not find zshInstall.sh at ${ZSH_INSTALL_PATH}"
        exit 1
    fi

    PRECONFIGURED_DIR="${PROJECT_TOP_DIR}/src/zsh/preconfigured"
    INSTALL_DIR="$HOME/.local"
    SRC_DIR="$HOME/src"
    ZSH_VERSION="$(Zsh::get_latest_available_zsh_version)"

    Utils::create_dir_if_not_exists "$INSTALL_DIR"
    Utils::create_dir_if_not_exists "$SRC_DIR"
    
    # Read Zsh customizations from config
    ZSH_PLUGINS=$(jq -r '.zsh.plugins' "$CONFIG_FILE")
    ZSH_FONTS=$(jq -r '.zsh.fonts' "$CONFIG_FILE")
    ZSH_THEME=$(jq -r '.zsh.theme' "$CONFIG_FILE")
    ZSH_ALIASES=$(jq -r '.zsh.aliases' "$CONFIG_FILE")
    
    # Install base Zsh + oh-my-zsh
    # TODO: Create seperate functions for installing zsh and oh-my-zsh in order to call them based on config
    Zsh::install
    
    # Optional extras
    [[ "$ZSH_PLUGINS" == "y" ]] && Zsh::install_plugins
    [[ "$ZSH_FONTS" == "y" ]] && Zsh::install_fonts
    [[ "$ZSH_THEME" == "y" ]] && Zsh::install_theme
    [[ "$ZSH_ALIASES" == "y" ]] && Zsh::set_aliases

    export PATH="$HOME/.local/bin:$PATH"
    source $HOME/.bashrc

    Zsh::verify_installation | exit 1
fi

