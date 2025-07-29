#!/usr/bin/env bash
set -e

LinuxRootlessDevKit::install()
{
  if [[ "$1" == "bash" ]]; then
    ################### BASH ###################
    # Install Oh My Bash
    if [[ -f "${PROJECT_TOP_DIR}/src/bash/omb_install.sh" ]]; then
      source "${PROJECT_TOP_DIR}/src/bash/omb_install.sh"
      Omb::install || exit 1
    else
      Logger::log_error "Error: Could not find omb_install.sh at ${PROJECT_TOP_DIR}/src/bash/omb_install.sh"
      exit 1
    fi
  elif [[ "$1" == "zsh" ]]; then
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
  Rust::install "${SHELLRC_PATH}" || exit 1
  source "${SHELLRC_PATH}"

  ### RUST TOOLS ###
  # Source Rust Cli tools install file
  RUST_TOOLS_INSTALL_PATH="${PROJECT_TOP_DIR}/src/rust/rust_install_cli_tools.sh"
  if [[ -f "${RUST_TOOLS_INSTALL_PATH}" ]]; then
      source "${RUST_TOOLS_INSTALL_PATH}"
  else
      Logger::log_error "Error: Could not find rust_install_cli_tools.sh at ${RUST_TOOLS_INSTALL_PATH}"
      exit 1
  fi
  # Install all defined rust tools with shell config file as an argument
  Rust::Cli::install_all_tools "${SHELLRC_PATH}" || exit 1

  ### GO ###
  # Install Go
  source "${PROJECT_TOP_DIR}/src/golang/go_install.sh"
  Go::download "1.24.3"
  Go::install "1.24.3"
  Go::install_cli_tools
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
