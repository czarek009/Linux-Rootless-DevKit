#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_TOP_DIR="${SCRIPT_DIR}"
ZSH_INSTALL_PATH="${PROJECT_TOP_DIR}/src/zsh/zsh_install.sh"
OMB_INSTALL_PATH="${PROJECT_TOP_DIR}/src/bash/omb_install.sh"
RUST_TOOLS_UTILS_PATH="${SCRIPT_DIR}/src/rust/rust_tools_utils.sh"
SETTING_MASTER_FILE="${PROJECT_TOP_DIR}/configs/.settings-master"
ENV_VARIABLES="${SCRIPT_DIR}/src/env_variables.sh"
source "${ENV_VARIABLES}"
source "${SETTING_MASTER_FILE}"

declare -A rust_tools_declared_versions
rust_tools_declared_versions[zoxide]="$ROOTLESS_CONFIG_MASTER_RUST_TOOLS_ZOXIDE_VERSION"
rust_tools_declared_versions[git-delta]="$ROOTLESS_CONFIG_MASTER_RUST_TOOLS_GIT_DELTA_VERSION"
rust_tools_declared_versions[atuin]="$ROOTLESS_CONFIG_MASTER_RUST_TOOLS_ATUIN_VERSION"
rust_tools_declared_versions[procs]="$ROOTLESS_CONFIG_MASTER_RUST_TOOLS_PROCS_VERSION"
rust_tools_declared_versions[du-dust]="$ROOTLESS_CONFIG_MASTER_RUST_TOOLS_DU_DUST_VERSION"
rust_tools_declared_versions[ripgrep]="$ROOTLESS_CONFIG_MASTER_RUST_TOOLS_RIPGREP_VERSION"
rust_tools_declared_versions[tealdeer]="$ROOTLESS_CONFIG_MASTER_RUST_TOOLS_TEALDEER_VERSION"
rust_tools_declared_versions[tokei]="$ROOTLESS_CONFIG_MASTER_RUST_TOOLS_TOKEI_VERSION"
rust_tools_declared_versions[gitui]="$ROOTLESS_CONFIG_MASTER_RUST_TOOLS_GITUI_VERSION"
rust_tools_declared_versions[eza]="$ROOTLESS_CONFIG_MASTER_RUST_TOOLS_EZA_VERSION"

Configurator::get_user_input_yn()
{
    local prompt="$1"
    local default_value="$2"
    if [[ -z "$default_value" ]]; then
        default_value="y"
    fi
    local possible_values=("y" "n")
    local possible_values_str=""
    local user_input
    local user_selected_correct_input="n"
    
    for value in "${possible_values[@]}"; do
        if [[ -n "$possible_values_str" ]]; then
            possible_values_str+="/"
        fi
        if [[ "$value" == "$default_value" ]]; then
            local value_str="${value^}" 
            possible_values_str+="\e[1m\e[4m$value_str\e[0m"
        else
            possible_values_str+="$value"
        fi
    done


   while [[ ! "$user_selected_correct_input" == "y" ]]; do
        read -r -p "$(printf "%b" "\e[1m$prompt\e[0m [$possible_values_str]: ")" user_input
        user_input="${user_input,,}" 
        if [[ -z "$user_input" ]]; then
            user_input="$default_value"
        fi
        local match_found="n"
        for value in "${possible_values[@]}"; do
            if [[ "$user_input" == "yes" || "$user_input" == "no" ]]; then
                user_input="${user_input:0:1}" 
            fi
            if [[ "$user_input" == "$value" ]]; then
                user_selected_correct_input="y"
            fi
        done
        if [[ "$user_selected_correct_input" == "y" ]]; then
            echo "$user_input"
        fi
    done
}

Configurator::get_user_input()
{
    local prompt="$1"
    local default_value="$2"
    local possible_values=("${@:3}")
    local user_input
    local user_selected_correct_input="n"
    local possible_values_str=""

    for value in "${possible_values[@]}"; do
        if [[ -n "$possible_values_str" ]]; then
            possible_values_str+=" / "
        fi
        if [[ "$value" == "$default_value" ]]; then
            local value_str="${value^}" 
            possible_values_str+="\e[1m\e[4m$value_str\e[0m"
        else
            possible_values_str+="$value"
        fi
    done

    while [[ ! "$user_selected_correct_input" == "y" ]]; do
        read -r -p "$(printf "%b" "\e[1m$prompt\e[0m [$possible_values_str]: ")" user_input
        user_input="${user_input,,}" 
        if [[ -z "$user_input" ]]; then
            user_input="$default_value"
        fi
        local match_found="n"
        for value in "${possible_values[@]}"; do
            if [[ "$user_input" == "$value" ]]; then
                user_selected_correct_input="y"
            fi
        done
        if [[ "$user_selected_correct_input" == "y" ]]; then
            echo "$user_input"
        fi
    done
}

Configurator::convert_yaml_to_settings_user()
{
    local SETTINGS_USER_YAML="$1"
    if [[ -z "$SETTINGS_USER_YAML" ]]; then
        SETTINGS_USER_YAML="configs/.settings-user.yml"
    fi

    if [[ ! -f "$SETTINGS_USER_YAML" ]]; then
        Logger::log_error "Missing config file: $SETTINGS_USER_YAML"
        return 1
    fi
    Logger::log_info "User .yaml config: $SETTINGS_USER_YAML"

    EnvConfigurator::create_file_if_not_exists "$USER_SETTINGS_FILE"
    : > "$USER_SETTINGS_FILE" # clear the file content

    EnvConfigurator::_write "$USER_SETTINGS_FILE" "# Generated from $SETTINGS_USER_YAML"

    ### TOP-LEVEL FIELDS ###
    for field in shell.name shell.install_oh_my install_rust install_go; do
        value=$(yq -r ".$field" "$SETTINGS_USER_YAML")
        if [[ "$value" != "null" ]]; then
        EnvConfigurator::_write "$USER_SETTINGS_FILE" "ROOTLESS_CONFIG_USER_$(echo "$field" | tr '.' '_' | tr '[:lower:]' '[:upper:]')=\"$value\""
        fi
    done
    EnvConfigurator::_write "$USER_SETTINGS_FILE" ""

    ### SHELL SETTINGS ###
    for ohmyopt in plugins fonts theme aliases; do
        value=$(yq -r ".shell.${ohmyopt}" "$SETTINGS_USER_YAML")
        if [[ "$value" != "null" ]]; then
            EnvConfigurator::_write "$USER_SETTINGS_FILE" "ROOTLESS_CONFIG_USER_OH_MY_$(echo "$ohmyopt" | tr '[:lower:]' '[:upper:]')=\"$value\""
        fi
    done

    EnvConfigurator::_write "$USER_SETTINGS_FILE" ""

    ### RUST CLI TOOLS ###
    rust_tools_keys=$(yq -r '.rust_tools | keys | .[]' "$SETTINGS_USER_YAML")
    for tool in $rust_tools_keys; do
        install=$(yq -r ".rust_tools.\"$tool\".install" "$SETTINGS_USER_YAML")
        if [[ "$install" != "null" ]]; then
            varname="ROOTLESS_CONFIG_USER_RUST_TOOLS_$(echo "$tool" | tr '[:lower:]-' '[:upper:]_')_INSTALL"
            EnvConfigurator::_write "$USER_SETTINGS_FILE" "$varname=\"$install\""
        fi
    done

  Logger::log_success "User settings written to $USER_SETTINGS_FILE"
}

Configurator::sanitize_line_input()
{
    local line="$1"
    # Allowed format: var="value" or var=value:
    if [[ ! "$line" =~ ^[A-Za-z_][A-Za-z0-9_]*=\"?[^\"]*\"?$ ]]; then
        return 1
    fi
    # Check for special characters:
    if echo "$line" | grep -q "[\`\$();|&]"; then
        return 1
    fi
    # Check for commands keywords:
    if [[ "$line" =~ ^[[:space:]]*(eval|source|\.) ]]; then
        return 1
    fi
    return 0
}

Configurator::process_settings_file() {
    local profile="$1"
    local file="$2"
    local meged_vars_map="$3"
    while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue
        Configurator::sanitize_line_input "$line" || continue
        if [[ "$line" =~ ^ROOTLESS_CONFIG_${profile}_.+ ]]; then
            # Strip profile from var name
            local new_line="${line/ROOTLESS_CONFIG_${profile}_/ROOTLESS_CONFIG_}"
            local var_name="${new_line%%=*}"
            merged_vars["$var_name"]="$new_line"
        fi
    done < "$file"
}


Configurator::generate_settings()
{
    local CHOSEN_PROFILE="${1^^}"  # Convert to uppercase for safety (e.g., user → USER)
    local SETTINGS_SOURCE_FILE
    declare -A merged_vars
    : > "$SETTINGS_FILE"

    EnvConfigurator::_write "$SETTINGS_FILE" "# AUTO-GENERATED FILE"
    EnvConfigurator::_write "$SETTINGS_FILE" "# Values are generated based on chosen profile USER/MASTER and used later on in the code"
    EnvConfigurator::_write "$SETTINGS_FILE" ""

    Configurator::process_settings_file "MASTER" "$MASTER_SETTINGS_FILE" merged_vars
    Configurator::process_settings_file "USER" "$USER_SETTINGS_FILE" merged_vars

    for var in $(printf "%s\n" "${!merged_vars[@]}" | sort); do
        echo "${merged_vars[$var]}" >> "$SETTINGS_FILE"
    done

    Logger::log_success "Generated profile-based config: $SETTINGS_FILE"
}

Configurator::get_initial_config() {
    if [[ "$SETTINGS_USER_YAML" == "" ]]; then
        SETTINGS_USER_YAML="configs/.settings-user.yml"
    fi

    printf "Welcome to your Linux Rootless DevKit setup\n"
    printf "You will be asked a few questions to set up your environment\n"
    printf "You are free to skip any step by pressing \"enter\" to use \e[1m\e[4m\"Recomended value\"\e[0m\n"
    local continueSetup
    continueSetup="$(Configurator::get_user_input_yn "Continue with the setup?")"
    if [[ "$continueSetup" == "n" ]]; then
        Logger::log_info "Setup cancelled by user"
        exit 0
    fi

    local shell_choice
    local use_default_install_configuration

    local install_rust="$ROOTLESS_CONFIG_MASTER_RUST_INSTALL"
    declare -A rust_tools_install
    declare -A rust_tools_versions

    local install_go="$ROOTLESS_CONFIG_MASTER_GO_INSTALL"
    local go_version="$ROOTLESS_CONFIG_MASTER_GO_VERSION"

    local zsh_install_version="$ROOTLESS_CONFIG_MASTER_ZSH_VERSION"
    local install_oh_my="$ROOTLESS_CONFIG_MASTER_OH_MY_X_INSTALL"
    local install_plugins="$ROOTLESS_CONFIG_MASTER_OH_MY_PLUGINS"
    local install_fonts="$ROOTLESS_CONFIG_MASTER_OH_MY_FONTS"
    local install_theme="$ROOTLESS_CONFIG_MASTER_OH_MY_THEME"
    local install_aliases="$ROOTLESS_CONFIG_MASTER_OH_MY_ALIASES"

    shell_choice=$(Configurator::get_user_input "Which shell do you want to use?" "bash" "bash" "zsh" "both")
    use_default_install_configuration=$(Configurator::get_user_input_yn "Do you want to apply the default full install configuration?")

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
            rust_tools_versions["$tool_name"]="${rust_tools_declared_versions[$tool_name]:-""}"
        done

    else
        # ---- Install Oh-My-X ----
        install_oh_my=$(Configurator::get_user_input_yn "Do you want to install oh-my-${shell_choice}?")

        if [[ "$shell_choice" == "zsh" && "$install_oh_my" == "y" ]]; then
            if [[ -f "${ZSH_INSTALL_PATH}" ]]; then
                source "${ZSH_INSTALL_PATH}"
            else
                Logger::log_error "Error: Could not find zsh_install.sh at ${ZSH_INSTALL_PATH}"
                exit 1
            fi

            Logger::log_userAction "Zsh was selected. Would you like to install the following components?"
            install_plugins=$(Configurator::get_user_input_yn "1/4 Install zsh plugins?")
            install_fonts=$(Configurator::get_user_input_yn "2/4 Install zsh fonts?")
            install_theme=$(Configurator::get_user_input_yn "3/4 Install zsh theme?")
            install_aliases=$(Configurator::get_user_input_yn "4/4 Install useful aliases for zsh?")
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
        install_rust=$(Configurator::get_user_input_yn "Do you want to install Rust?")
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
                tool_choice=$(Configurator::get_user_input_yn "$tools_counter/$tools_count Do you want to install Rust tool '$tool_name'?" "$ROOTLESS_CONFIG_MASTER_RUST_INSTALL" "y" "n")
                rust_tools_install["$tool_name"]="$tool_choice"
                rust_tools_versions["$tool_name"]="${rust_tools_declared_versions[$tool_name]:-""}"
                # if [[ "$tool_choice" == "y" ]]; then
                #     read -rp "  Which version of '$tool_name'? ('latest' or specific like '0.25.2'): " version
                #     rust_tools_versions["$tool_name"]="${version:-latest}"
                # fi
            done
        fi

        # ---- Install Go ----
        install_go=$(Configurator::get_user_input "Do you want to install Go?" "$ROOTLESS_CONFIG_MASTER_GO_INSTALL" "y" "n")
        go_version="$ROOTLESS_CONFIG_MASTER_GO_VERSION"
        # if [[ "$install_go" == "y" ]]; then
        #     read -rp "  Which version of Go? ('latest' or specific like '1.22.3'): " go_version
        #     go_version="${go_version:-latest}"
        # fi
    fi

    # ---- Output YAML Config ----
    for tool in "${!rust_tools_install[@]}"; do
        install="${rust_tools_install[$tool]}"
        version="${rust_tools_versions[$tool]:-""}"
        rust_tools_json+="
    $tool: 
        install: $install 
        version: $version"
    done
    rust_tools_json="${rust_tools_json%,}"

    cat <<EOF > "$SETTINGS_USER_YAML"
shell:
    name: $shell_choice
    install_version: $zsh_install_version
    install_oh_my: $install_oh_my
    plugins: $install_plugins
    fonts: $install_fonts
    theme: $install_theme
    aliases: $install_aliases
install_rust: $install_rust
rust_tools: $rust_tools_json
install_go: $install_go
go_version: $go_version

EOF

    Logger::log_success "Configuration saved to $SETTINGS_USER_YAML"
}
