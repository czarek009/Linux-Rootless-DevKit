#!/usr/bin/env bash
set -e

LinuxRootlessDevKit::install()
{
  # Source user and master settings
  if [[ -f "${MASTER_SETTINGS_FILE}" ]]; then
    source "${MASTER_SETTINGS_FILE}"
  else
    echo "Error: Could not find ${MASTER_SETTINGS_FILE}"
    exit 1
  fi

  if [[ -f "${SETTINGS_FILE}" ]]; then
    source "${SETTINGS_FILE}"
  else
    echo "Error: Could not find ${SETTINGS_FILE}"
    exit 1
  fi

  SHELLRC_PATH="${HOME}/${ROOTLESS_CONFIG_SHELL}rc.user"

  if [[ $ROOTLESS_CONFIG_SHELL == "bash" ]]; then
    ################### BASH ###################
    # Install Oh My Bash
    if [[ -f "${PROJECT_TOP_DIR}/src/bash/omb_install.sh" ]]; then
      source "${PROJECT_TOP_DIR}/src/bash/omb_install.sh"
      Omb::install || exit 1
    else
      Logger::log_error "Error: Could not find omb_install.sh at ${PROJECT_TOP_DIR}/src/bash/omb_install.sh"
      exit 1
    fi
  elif [[ "$ROOTLESS_CONFIG_SHELL" == "zsh" ]]; then
    ################### ZSH ###################
    # Install zsh
    source "${PROJECT_TOP_DIR}/src/zsh/zsh_install.sh"
    Zsh::install
    Zsh::install_plugins
    Zsh::install_fonts
    Zsh::install_theme
    Zsh::configure
    Zsh::set_aliases
    Zsh::verify_installation
    export PATH="$HOME/.local/bin:$PATH"
  else
    Logger::log_error "Error: Unsupported shell '$1'. Use 'bash' or 'zsh'." >&2
    exit 1
  fi

  ### RUST ###
  # Source rust install file
  RUST_INSTALL_PATH="${PROJECT_TOP_DIR}/src/rust/rust_install.sh"
  if [[ -f "${RUST_INSTALL_PATH}" ]]; then
    source "${RUST_INSTALL_PATH}"
  else
      Logger::log_error "Error: Could not find rust_install.sh at ${RUST_INSTALL_PATH}"
      exit 1
  fi
  # Install rust with shell config file as an argument
  if [[ "${ROOTLESS_CONFIG_RUST_INSTALL}" == "y" ]]; then
    Rust::install "${SHELLRC_PATH}" "${ROOTLESS_CONFIG_MASTER_RUST_VERSION}" || exit 1
    source "${SHELLRC_PATH}"
  fi

  ### RUST TOOLS ###
  # Source Rust Cli tools install file
  RUST_TOOLS_INSTALL_PATH="${PROJECT_TOP_DIR}/src/rust/rust_install_cli_tools.sh"
  if [[ -f "${RUST_TOOLS_INSTALL_PATH}" ]]; then
    source "${RUST_TOOLS_INSTALL_PATH}"
  else
      Logger::log_error "Error: Could not find rust_install_cli_tools.sh at ${RUST_TOOLS_INSTALL_PATH}"
      exit 1
  fi
  # Make sure cargo exists
  Rust::Cli::check_cargo_available

  # Install all defined rust tools with shell config file as an argument
  for entry in "${RUST_CLI_TOOLS[@]}"; do
    read -r tool_name binary shell_init <<< "$(Rust::Cli::parse_tool_entry "$entry")"
    
    # Convert tool name to uppercase, replace dash with underscore
    tool_var_id="$(echo "$tool_name" | tr '[:lower:]-' '[:upper:]_')"

    # Check .settings file for user install flag
    user_flag_var="ROOTLESS_CONFIG_RUST_TOOLS_${tool_var_id}_INSTALL"
    if grep -q "^$user_flag_var=\"y\"" "$SETTINGS_FILE"; then
      echo "🔧 Preparing to install $tool_name"

      # Find version from .settings-master
      version_var="ROOTLESS_CONFIG_MASTER_RUST_TOOLS_${tool_var_id}_VERSION"
      version="--locked"  # default
      if grep -q "^$version_var=" "$MASTER_SETTINGS_FILE"; then
        version_val=$(grep "^$version_var=" "$MASTER_SETTINGS_FILE" | cut -d '=' -f2 | tr -d '"')
        version="--version $version_val"
      fi

      Rust::Cli::install_tool "$SHELLRC_PATH" "$tool_name" "$binary" "$shell_init" "$version"
    else
      echo "⏭️  Skipping $tool_name — not marked for install"
    fi
  done

  ### GO ###
  # Install Go
  source "${PROJECT_TOP_DIR}/src/golang/go_install.sh"
  Go::download "1.24.3"
  Go::install "1.24.3"
}

LinuxRootlessDevKit::verify_installation()
{
  source "${SHELLRC_PATH}"
  source ~/.bashrc.user

  if [[ "$1" == "bash" ]]; then
    ################### BASH ###################
    # Verify Oh My Bash
    if [[ -f "${PROJECT_TOP_DIR}/src/bash/omb_install.sh" ]]; then
      source "${PROJECT_TOP_DIR}/src/bash/omb_install.sh"
      Omb::verify_installation || exit 1
    else
      Logger::log_error "Error: Could not find omb_install.sh at ${PROJECT_TOP_DIR}/src/bash/omb_install.sh"
      exit 1
    fi
  elif [[ "$1" == "zsh" ]]; then
    ################### ZSH ###################
    # Verify installation
    if command -v zsh >/dev/null 2>&1; then
      zsh --version
      Logger::log_success "✅ zsh successfully installed."
    else
      Logger::log_error "❌ zsh not found after install."
      exit 1
    fi
  else
    Logger::log_error "Error: Unsupported shell '$1'. Use 'bash' or 'zsh'." >&2
    exit 1
  fi

  ### RUST ###
  # Verify installation
  if command -v rustc >/dev/null 2>&1; then
    rustc --version
    Logger::log_success "✅ rust successfully installed."
  else
    Logger::log_error "❌ rustc not found after install."
    exit 1
  fi

  ### RUST TOOLS ###
  # Verify installation of rust tools
  Rust::Cli::verify_installed || exit 1

  ### GO ###
  # Verify Go installation
  if command -v go >/dev/null 2>&1; then
    go version
    Logger::log_success "✅ Go successfully installed."
  else
    Logger::log_error "❌ Go not found after install."
    exit 1
  fi
}

LinuxRootlessDevKit::uninstall()
{
  source "${SHELLRC_PATH}"
  source ~/.bashrc.user

  if [[ "$1" == "bash" ]]; then
    ################### BASH ###################
    # Remove Oh My Bash
    if [[ -f "${PROJECT_TOP_DIR}/src/bash/omb_uninstall.sh" ]]; then
      source "${PROJECT_TOP_DIR}/src/bash/omb_uninstall.sh"
      Omb::uninstall || exit 1
    else
      Logger::log_error "Error: Could not find omb_uninstall.sh at ${PROJECT_TOP_DIR}/src/bash/omb_uninstall.sh"
      exit 1
    fi
  elif [[ "$1" == "zsh" ]]; then
    ################### ZSH ###################
    # Uninstall zsh
    source "${PROJECT_TOP_DIR}/src/zsh/zsh_uninstall.sh"
    Zsh::uninstall
  else
    Logger::log_error "Error: Unsupported shell '$1'. Use 'bash' or 'zsh'." >&2
    exit 1
  fi

  ### RUST TOOLS ###
  # Source Rust Cli tools uninstall file
  RUST_TOOLS_UNINSTALL_PATH="${PROJECT_TOP_DIR}/src/rust/rust_uninstall_cli_tools.sh"
  if [[ -f "${RUST_TOOLS_UNINSTALL_PATH}" ]]; then
      source "${RUST_TOOLS_UNINSTALL_PATH}"
  else
      Logger::log_error "Error: Could not find rust_uninstall_cli_tools.sh at ${RUST_TOOLS_UNINSTALL_PATH}"
      exit 1
  fi
  # Uninstall all defined rust tools with shell config file as an argument
  Rust::Cli::uninstall_all_tools "${SHELLRC_PATH}" || exit 1

  ### RUST ###
  # Source rust uninstall file
  RUST_UNINSTALL_PATH="${PROJECT_TOP_DIR}/src/rust/rust_uninstall.sh"
  if [[ -f "${RUST_UNINSTALL_PATH}" ]]; then
      source "${RUST_UNINSTALL_PATH}"
  else
      Logger::log_error "Error: Could not find rust_uninstall.sh at ${RUST_UNINSTALL_PATH}"
      exit 1
  fi
  # Uninstall Rust with shell config file as an argument
  Rust::uninstall "${SHELLRC_PATH}" || exit 1

  ### GO ###
  # Uninstall Go
  source "${PROJECT_TOP_DIR}/src/golang/go_uninstall.sh"
  Go::remove_dirs
  Go::clean_bashrc
}

LinuxRootlessDevKit::verify_uninstallation()
{
  source "${SHELLRC_PATH}"
  source ~/.bashrc.user

  if [[ "$1" == "bash" ]]; then
    ################### BASH ###################
    # Remove Oh My Bash
    if [[ -f "${PROJECT_TOP_DIR}/src/bash/omb_uninstall.sh" ]]; then
      source "${PROJECT_TOP_DIR}/src/bash/omb_uninstall.sh"
      Omb::verify_uninstallation || exit 1
    else
      Logger::log_error "Error: Could not find omb_uninstall.sh at ${PROJECT_TOP_DIR}/src/bash/omb_uninstall.sh"
      exit 1
    fi
  elif [[ "$1" == "zsh" ]]; then
    ################### ZSH ###################
    # Verify uninstallation
    if [ ! -d "$HOME/.oh-my-zsh" ] && [ ! -d "$HOME/.local/bin/zsh" ]; then
      Logger::log_success "✅ zsh successfully uninstalled."
    else
      Logger::log_error "❌ zsh files still exist after uninstall."
      exit 1
    fi
  else
    Logger::log_error "Error: Unsupported shell '$1'. Use 'bash' or 'zsh'." >&2
    exit 1
  fi

  ### RUST TOOLS ###
  # Verify uninstallation of rust tools
  Rust::Cli::verify_uninstalled || exit 1

  ### RUST ###
  # Verify Rust uninstallation
  if [ ! -d "$HOME/.cargo" ] && [ ! -d "$HOME/.rustup" ]; then
    Logger::log_success "✅ Rust successfully uninstalled."
  else
    Logger::log_error "❌ Rust files still exist after uninstall."
    exit 1
  fi

  ### GO ###
  # Verify Go uninstallation
  if [ ! -d "$HOME/go" ] && [ ! -d "$HOME/.local/go" ]; then
    Logger::log_success "✅ Go successfully uninstalled."
  else
    Logger::log_error "❌ Go files still exist after uninstall."
    exit 1
  fi
}

LinuxRootlessDevKit::configuration_setup() {
  echo "Welcome to your Linux Rootless DevKit setup."

  ### CHOOSE SHELL ###
  read -rp "Which shell do you want to use? (bash/zsh): " shell_choice
  while [[ "$shell_choice" != "bash" && "$shell_choice" != "zsh" ]]; do
    echo "Please choose either 'bash' or 'zsh'."
    read -rp "Which shell do you want to use? (bash/zsh): " shell_choice
  done

  ### ASK FOR DEFAULT FULL SETUP ###
  read -rp "Do you want to apply the default full install configuration? (Y/n): " default_choice
  default_choice="${default_choice,,}"
  [[ -z "$default_choice" || "$default_choice" == "y" ]] && default_choice="y" || default_choice="n"

  declare -A rust_tools_install
  install_oh_my="n"
  install_plugins="n"
  install_fonts="n"
  install_theme="n"
  install_aliases="n"
  install_rust="n"
  install_go="n"

  if [[ "$default_choice" == "y" ]]; then
    install_oh_my="y"
    install_plugins="y"
    install_fonts="y"
    install_theme="y"
    install_aliases="y"
    install_rust="y"
    install_go="y"

    local SCRIPT_CURR_DIR
    SCRIPT_CURR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local RUST_TOOLS_UTILS_PATH="${SCRIPT_CURR_DIR}/src/rust/rust_tools_utils.sh"

    if [[ -f "${RUST_TOOLS_UTILS_PATH}" ]]; then
      source "${RUST_TOOLS_UTILS_PATH}"
    else
      echo "Error: Could not find rust_tools_utils.sh at ${RUST_TOOLS_UTILS_PATH}"
      exit 1
    fi

    for entry in "${RUST_CLI_TOOLS[@]}"; do
      tool_name=$(Rust::Cli::parse_tool_entry "$entry" | awk '{print $1}')
      rust_tools_install["$tool_name"]="y"
    done

  else
    ### OH-MY-X CONFIG ###
    read -rp "Do you want to install oh-my-${shell_choice}? (Y/n): " install_oh_my
    install_oh_my="${install_oh_my,,}"
    [[ -z "$install_oh_my" || "$install_oh_my" == "y" ]] && install_oh_my="y" || install_oh_my="n"

    if [[ "$shell_choice" == "zsh" ]]; then
      echo "Zsh was selected. Would you like to install the following components?"

      read -rp "Install Zsh plugins? [Y/n]: " install_plugins
      install_plugins="${install_plugins,,}"
      install_plugins="${install_plugins:-y}"

      read -rp "Install fonts for Zsh? [Y/n]: " install_fonts
      install_fonts="${install_fonts,,}"
      install_fonts="${install_fonts:-y}"

      read -rp "Install Powerlevel10k theme? [Y/n]: " install_theme
      install_theme="${install_theme,,}"
      install_theme="${install_theme:-y}"

      read -rp "Install useful aliases for Zsh? [Y/n]: " install_aliases
      install_aliases="${install_aliases,,}"
      install_aliases="${install_aliases:-y}"

    elif [[ "$shell_choice" == "bash" ]]; then
      echo "Bash was selected. Would you like to install the following components?"

      read -rp "Install fonts for Bash? [Y/n]: " install_fonts
      install_fonts="${install_fonts,,}"
      install_fonts="${install_fonts:-y}"
    fi

    ### RUST CONFIG ###
    read -rp "Do you want to install Rust? (Y/n): " install_rust
    install_rust="${install_rust,,}"
    [[ -z "$install_rust" || "$install_rust" == "y" ]] && install_rust="y" || install_rust="n"

    if [[ "$install_rust" == "y" ]]; then
      echo "Checking each Rust CLI tool..."

      local SCRIPT_CURR_DIR
      SCRIPT_CURR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
      local RUST_TOOLS_UTILS_PATH="${SCRIPT_CURR_DIR}/src/rust/rust_tools_utils.sh"

      if [[ -f "${RUST_TOOLS_UTILS_PATH}" ]]; then
        source "${RUST_TOOLS_UTILS_PATH}"
      else
        echo "Error: Could not find rust_tools_utils.sh at ${RUST_TOOLS_UTILS_PATH}"
        exit 1
      fi

      for entry in "${RUST_CLI_TOOLS[@]}"; do
        tool_name=$(Rust::Cli::parse_tool_entry "$entry" | awk '{print $1}')
        read -rp "Install Rust tool '$tool_name'? (Y/n): " tool_choice
        tool_choice="${tool_choice,,}"
        [[ -z "$tool_choice" || "$tool_choice" == "y" ]] && tool_choice="y" || tool_choice="n"
        rust_tools_install["$tool_name"]="$tool_choice"
      done
    fi

    ### GO CONFIG ###
    read -rp "Do you want to install Go? (Y/n): " install_go
    install_go="${install_go,,}"
    [[ -z "$install_go" || "$install_go" == "y" ]] && install_go="y" || install_go="n"
  fi

  ### OUTPUT YAML CONFIG ###
  
  # Clear the file first (truncate)
  : > "$SETTINGS_USER_YAML"

  EnvConfigurator::_write "$SETTINGS_USER_YAML" "shell: $shell_choice"
  EnvConfigurator::_write "$SETTINGS_USER_YAML" "oh_my_x_install: $install_oh_my"
  EnvConfigurator::_write "$SETTINGS_USER_YAML" "zsh:"
  EnvConfigurator::_write "$SETTINGS_USER_YAML" "  plugins: $install_plugins"
  EnvConfigurator::_write "$SETTINGS_USER_YAML" "  fonts: $install_fonts"
  EnvConfigurator::_write "$SETTINGS_USER_YAML" "  theme: $install_theme"
  EnvConfigurator::_write "$SETTINGS_USER_YAML" "  aliases: $install_aliases"
  EnvConfigurator::_write "$SETTINGS_USER_YAML" "rust_install: $install_rust"
  EnvConfigurator::_write "$SETTINGS_USER_YAML" "rust_tools:"
  for tool in "${!rust_tools_install[@]}"; do
    EnvConfigurator::_write "$SETTINGS_USER_YAML" "  $tool:"
    EnvConfigurator::_write "$SETTINGS_USER_YAML" "    install: ${rust_tools_install[$tool]}" 
  done
  EnvConfigurator::_write "$SETTINGS_USER_YAML" "go_install: $install_go"

  echo -e "\n✅ Configuration saved to $SETTINGS_USER_YAML"
}

LinuxRootlessDevKit::parse_config() {
  if [[ ! -f "$SETTINGS_USER_YAML" ]]; then
    echo "Missing config file: $SETTINGS_USER_YAML"
    return 1
  fi
  echo "$SETTINGS_USER_YAML"

  # Clear the file
  : > "$USER_SETTINGS_FILE"

  EnvConfigurator::_write "$USER_SETTINGS_FILE" "# Generated from $SETTINGS_USER_YAML"

  ### TOP-LEVEL FIELDS ###
  for field in shell oh_my_x_install rust_install go_install; do
    value=$(yq e ".$field" "$SETTINGS_USER_YAML")
    if [[ "$value" != "null" ]]; then
      EnvConfigurator::_write "$USER_SETTINGS_FILE" "ROOTLESS_CONFIG_USER_$(echo "$field" | tr '[:lower:]' '[:upper:]')=\"$value\""
    fi
  done
  EnvConfigurator::_write "$USER_SETTINGS_FILE" ""

  ### ZSH SECTION ###
  for zopt in plugins fonts theme aliases; do
    value=$(yq e ".zsh.${zopt}" "$SETTINGS_USER_YAML")
    if [[ "$value" != "null" ]]; then
      EnvConfigurator::_write "$USER_SETTINGS_FILE" "ROOTLESS_CONFIG_USER_ZSH_$(echo "$zopt" | tr '[:lower:]' '[:upper:]')=\"$value\""
    fi
  done

  EnvConfigurator::_write "$USER_SETTINGS_FILE" ""

  ### RUST CLI TOOLS ###
  rust_tools_keys=$(yq e '.rust_tools | keys | .[]' "$SETTINGS_USER_YAML")
  for tool in $rust_tools_keys; do
    install=$(yq e ".rust_tools.\"$tool\".install" "$SETTINGS_USER_YAML")
    if [[ "$install" != "null" ]]; then
      varname="ROOTLESS_CONFIG_USER_RUST_TOOLS_$(echo "$tool" | tr '[:lower:]-' '[:upper:]_')_INSTALL"
      EnvConfigurator::_write "$USER_SETTINGS_FILE" "$varname=\"$install\""
    fi
  done

  echo "✅ User settings written to $USER_SETTINGS_FILE"
}

LinuxRootlessDevKit::generate_profile_settings() {
    local CHOSEN_PROFILE="${1^^}"  # Convert to uppercase for safety (e.g., user → USER)
    local SETTINGS_PATH="${PROJECT_TOP_DIR}/configs/.settings"
    local SETTINGS_SOURCE_FILE

    # Determine source file
    if [[ "$CHOSEN_PROFILE" == "MASTER" ]]; then
        SETTINGS_SOURCE_FILE=$MASTER_SETTINGS_FILE
    elif [[ "$CHOSEN_PROFILE" == "USER" ]]; then
        SETTINGS_SOURCE_FILE=$USER_SETTINGS_FILE
    else
        echo "❌ Invalid config scope: $CHOSEN_PROFILE. Use USER or MASTER."
        return 1
    fi

    if [[ ! -f "$SETTINGS_SOURCE_FILE" ]]; then
        echo "❌ Source file not found: $SETTINGS_SOURCE_FILE"
        return 1
    fi

    # Clear the file
    : > "$SETTINGS_PATH"

    EnvConfigurator::_write "$SETTINGS_PATH" "# AUTO-GENERATED FILE"
    EnvConfigurator::_write "$SETTINGS_PATH" "# Values are generated based on chosen profile USER/MASTER and used later on in the code"
    EnvConfigurator::_write "$SETTINGS_PATH" ""

    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue

        # Match lines starting with ROOTLESS_CONFIG_${CHOSEN_PROFILE}_ and NOT *_VERSION=
        if [[ "$line" =~ ^ROOTLESS_CONFIG_${CHOSEN_PROFILE}_.+ ]]; then
            if [[ "$line" =~ _VERSION= ]]; then
                continue  # Skip version lines
            fi

            # Strip CHOSEN_PROFILE from var name (keep ROOTLESS_CONFIG_*)
            local new_line
            new_line="${line//ROOTLESS_CONFIG_${CHOSEN_PROFILE}_/ROOTLESS_CONFIG_}"
            EnvConfigurator::_write "$SETTINGS_PATH" "$new_line"
        fi
    done < "$SETTINGS_SOURCE_FILE"

    echo "✅ Generated profile-based config: $SETTINGS_PATH"
}
