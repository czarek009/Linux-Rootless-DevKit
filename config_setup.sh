#!/usr/bin/env bash

get_initial_config() {

  echo "Welcome to your Linux Rootless DevKit setup."

  # ---- 1. Choose Shell ----
  read -rp "Which shell do you want to use? (bash/zsh): " shell_choice
  while [[ "$shell_choice" != "bash" && "$shell_choice" != "zsh" ]]; do
      echo "Please choose either 'bash' or 'zsh'."
      read -rp "Which shell do you want to use? (bash/zsh): " shell_choice
  done

  # ---- 2. Ask for default setup ----
  read -rp "Do you want to apply the default full install configuration? (Y/n): " default_choice
  default_choice="${default_choice,,}"
  [[ -z "$default_choice" || "$default_choice" == "y" ]] && default_choice="y" || default_choice="n"

  declare -A rust_tools_install
  declare -A rust_tools_versions
  go_version=""
  install_go="n"

  if [[ "$default_choice" == "y" ]]; then
      install_oh_my="y"
      install_plugins="y"
      install_fonts="y"
      install_theme="y"
      install_aliases="y"
      install_rust="y"
      install_go="y"
      go_version="latest"

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
          rust_tools_versions["$tool_name"]="latest"
      done

  else
      # ---- 3. Install Oh-My-X ----
      read -rp "Do you want to install oh-my-${shell_choice}? (Y/n): " install_oh_my
      install_oh_my="${install_oh_my,,}"
      [[ -z "$install_oh_my" || "$install_oh_my" == "y" ]] && install_oh_my="y" || install_oh_my="n"

      # Default zsh fields
      install_plugins="n"
      install_fonts="n"
      install_theme="n"
      install_aliases="n"

      if [[ "$shell_choice" == "zsh" ]]; then
          echo "Zsh was selected. Would you like to install the following components?"
          echo "1. Plugins (autosuggestions, syntax highlighting, history search, etc.)"
          echo "2. Fonts (Nerd Fonts: UbuntuMono, Powerline fonts)"
          echo "3. Theme (Powerlevel10k)"
          echo "4. Helpful Aliases"

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
      fi

      # ---- 4. Install Rust ----
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

              read -rp "Do you want to install Rust tool '$tool_name'? (Y/n): " tool_choice
              tool_choice="${tool_choice,,}"
              [[ -z "$tool_choice" || "$tool_choice" == "y" ]] && tool_choice="y" || tool_choice="n"
              rust_tools_install["$tool_name"]="$tool_choice"

              if [[ "$tool_choice" == "y" ]]; then
                  read -rp "  Which version of '$tool_name'? ('latest' or specific like '0.25.2'): " version
                  rust_tools_versions["$tool_name"]="${version:-latest}"
              fi
          done
      fi

      # ---- 5. Install Go ----
      read -rp "Do you want to install Go? (Y/n): " install_go
      install_go="${install_go,,}"
      [[ -z "$install_go" || "$install_go" == "y" ]] && install_go="y" || install_go="n"

      if [[ "$install_go" == "y" ]]; then
          read -rp "  Which version of Go? ('latest' or specific like '1.22.3'): " go_version
          go_version="${go_version:-latest}"
      fi
  fi

  # ---- 6. Output JSON Config ----

  rust_tools_json="{"
  for tool in "${!rust_tools_install[@]}"; do
      install="${rust_tools_install[$tool]}"
      version="${rust_tools_versions[$tool]:-""}"
      rust_tools_json+="\"$tool\": {\"install\": \"$install\", \"version\": \"$version\"},"
  done
  rust_tools_json="${rust_tools_json%,}}"

  cat <<EOF > "$CONFIG_FILE"
{
  "shell": "$shell_choice",
  "install_oh_my": "$install_oh_my",
  "zsh": {
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

  echo -e "\n✅ Configuration saved to $CONFIG_FILE."
}
