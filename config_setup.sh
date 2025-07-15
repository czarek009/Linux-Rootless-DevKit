#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_TOP_DIR="${SCRIPT_DIR}"
ZSH_INSTALL_PATH="${PROJECT_TOP_DIR}/src/zsh/zsh_install.sh"
OMB_INSTALL_PATH="${PROJECT_TOP_DIR}/src/bash/omb_install.sh"
RUST_TOOLS_UTILS_PATH="${SCRIPT_DIR}/src/rust/rust_tools_utils.sh"
SETTING_MASTER_FILE="${PROJECT_TOP_DIR}/configs/.settings-master"
source "${SETTING_MASTER_FILE}"

Configurator::get_user_input()
{
    local prompt="$1"
    local default_value="$2"
    local possible_values=("${@:3}")
    local user_input
    local user_selected_corret_input="n"
    local possible_values_str=""

    for value in "${possible_values[@]}"; do
        if [[ -n "$possible_values_str" ]]; then
            possible_values_str+=" / "
        fi
        if [[ "$value" == "$default_value" ]]; then
            possible_values_str+="\e[1m\e[4m$value\e[0m"
        else
            possible_values_str+="$value"
        fi
    done

    while [[ ! "$user_selected_corret_input" == "y" ]]; do
        read -r -p "$(printf "%b" "\e[1m$prompt\e[0m ($possible_values_str): ")" user_input
        user_input="${user_input,,}" 
        if [[ -z "$user_input" ]]; then
            user_input="$default_value"
        fi
        local match_found="n"
        for value in "${possible_values[@]}"; do
            if [[ "$user_input" == "$value" ]]; then
                user_selected_corret_input="y"
            fi
        done
        if [[ "$user_selected_corret_input" == "y" ]]; then
            echo "$user_input"
        fi
    done
}

Configurator::get_initial_config() {
    printf "Welcome to your Linux Rootless DevKit setup\n"
    printf "You will be asked a few questions to set up your environment\n"
    printf "You are free to skip any step by pressing \"enter\" to use \e[1m\e[4mdrecomended value\e[0m\n"
    Configurator::get_user_input "Continue with the setup?" "yes" "yes" "no" > /dev/null

    local shell_choice
    local use_default_install_configuration

    local install_rust="$ROOTLESS_CONFIG_MASTER_RUST_INSTALL"
    declare -A rust_tools_install
    declare -A rust_tools_versions

    local install_go="$ROOTLESS_CONFIG_MASTER_GO_INSTALL"
    local go_version="$ROOTLESS_CONFIG_MASTER_GO_VERSION"

    local zsh_install_version="$ROOTLESS_CONFIG_MASTER_ZSH_VERSION"
    local install_oh_my="$ROOTLESS_CONFIG_MASTER_OH_MY_X_INSTALL"
    local install_plugins="$ROOTLESS_CONFIG_MASTER_ZSH_PLUGINS"
    local install_fonts="$ROOTLESS_CONFIG_MASTER_ZSH_FONTS"
    local install_theme="$ROOTLESS_CONFIG_MASTER_ZSH_THEME"
    local install_aliases="$ROOTLESS_CONFIG_MASTER_ZSH_ALIASES"

    shell_choice=$(Configurator::get_user_input "Which shell do you want to use?" "bash" "bash" "zsh")
    use_default_install_configuration=$(Configurator::get_user_input "Do you want to apply the default full install configuration?" "y" "y" "n")

    if [[ "$use_default_install_configuration" == "y" ]]; then
        if [[ -f "${RUST_TOOLS_UTILS_PATH}" ]]; then
            source "${RUST_TOOLS_UTILS_PATH}"
        else
            Logger::log_error "Error: Could not find rust_tools_utils.sh at ${RUST_TOOLS_UTILS_PATH}"
            exit 1
        fi

        for entry in "${RUST_CLI_TOOLS[@]}"; do
            tool_name=$(Rust::Cli::parse_tool_entry "$entry" | awk '{print $1}')
            rust_tools_install["$tool_name"]="y"
            rust_tools_versions["$tool_name"]="latest"
        done

    else
        # ---- Install Oh-My-X ----
        install_oh_my=$(Configurator::get_user_input "Do you want to install oh-my-${shell_choice}?" "y" "y" "n")

        if [[ "$shell_choice" == "zsh" && "$install_oh_my" == "y" ]]; then
            if [[ -f "${ZSH_INSTALL_PATH}" ]]; then
                source "${ZSH_INSTALL_PATH}"
            else
                Logger::log_error "Error: Could not find zsh_install.sh at ${ZSH_INSTALL_PATH}"
                exit 1
            fi

            Logger::log_userAction "Zsh was selected. Would you like to install the following components?"
            install_plugins=$(Configurator::get_user_input "1/4 Install zsh plugins?" "y" "y" "n")
            install_fonts=$(Configurator::get_user_input "2/4 Install zsh fonts?" "y" "y" "n")
            install_theme=$(Configurator::get_user_input "3/4 Install zsh theme?" "y" "y" "n")
            install_aliases=$(Configurator::get_user_input "4/4 Install useful aliases for zsh?" "y" "y" "n")
        elif [[ "$shell_choice" == "bash" ]]; then
            Logger::log_info "Bash was selected. No additional components to install."
            install_plugins="n"
            install_fonts="n"
            install_theme="n"
            install_aliases="n"
        elif [[ "$shell_choice" != "bash" && "$shell_choice" != "zsh" ]]; then
            Logger::log_error "Invalid shell choice. Please run the script again"
            exit 1
        fi

        # ---- Install Rust ----
        install_rust=$(Configurator::get_user_input "Do you want to install Rust?" "y" "y" "n")
        if [[ "$install_rust" == "y" ]]; then
            Logger::log_info "Checking each Rust CLI tool..."

            if [[ -f "${RUST_TOOLS_UTILS_PATH}" ]]; then
                source "${RUST_TOOLS_UTILS_PATH}"
            else
                Logger::log_error "Error: Could not find rust_tools_utils.sh at ${RUST_TOOLS_UTILS_PATH}"
                exit 1
            fi

            local tools_count=${#RUST_CLI_TOOLS[@]}
            local tools_counter=0
            for entry in "${RUST_CLI_TOOLS[@]}"; do
                tools_counter=$((tools_counter + 1))
                tool_name=$(Rust::Cli::parse_tool_entry "$entry" | awk '{print $1}')
                tool_choice=$(Configurator::get_user_input "$tools_counter/$tools_count Do you want to install Rust tool '$tool_name'?" "$ROOTLESS_CONFIG_MASTER_RUST_INSTALL" "y" "n")
                rust_tools_install["$tool_name"]="$tool_choice"

                if [[ "$tool_choice" == "y" ]]; then
                    read -rp "  Which version of '$tool_name'? ('latest' or specific like '0.25.2'): " version
                    rust_tools_versions["$tool_name"]="${version:-latest}"
                fi
            done
        fi

        # ---- Install Go ----
        install_go=$(Configurator::get_user_input "Do you want to install Go?" "$ROOTLESS_CONFIG_MASTER_GO_INSTALL" "y" "n")
        if [[ "$install_go" == "y" ]]; then
            read -rp "  Which version of Go? ('latest' or specific like '1.22.3'): " go_version
            go_version="${go_version:-latest}"
        fi
    fi

    # ---- Output JSON Config ----
    rust_tools_json="{"
    for tool in "${!rust_tools_install[@]}"; do
        install="${rust_tools_install[$tool]}"
        version="${rust_tools_versions[$tool]:-""}"
        rust_tools_json+="\"$tool\": {\"install\": \"$install\", \"version\": \"$version\"},"
    done
    rust_tools_json="${rust_tools_json%,}}"

    cat <<EOF > "$CONFIG_FILE"
{
  "shell": {
    "name": "$shell_choice",
    "install_version": "$zsh_install_version",
    "install_oh_my": "$install_oh_my",
    "plugins": "$install_plugins",
    "fonts": "$install_fonts",
    "theme": "$install_theme",
    "aliases": "$install_aliases"
  },
  "install_rust": "$install_rust",
  "rust_tools": $rust_tools_json,
  "install_go": "$install_go",
  "go_version": "$go_version"
}
EOF

    Logger::log_success "Configuration saved to $CONFIG_FILE"
}
