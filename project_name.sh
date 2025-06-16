#!/usr/bin/env bash
set -e

ProjectName::install()
{
  ### RUST ###
  # Source rust install file
  RUST_INSTALL_PATH="${PROJECT_TOP_DIR}/src/rust/install_rust.sh"
  if [[ -f "${RUST_INSTALL_PATH}" ]]; then
      source "${RUST_INSTALL_PATH}"
  else
      echo "Error: Could not find install_rust.sh at ${RUST_INSTALL_PATH}"
      exit 1
  fi
  # Install rust with shell config file as an argument
  Rust::install ${SHELLRC_PATH} || exit 1
  source ${SHELLRC_PATH}

  ### RUST TOOLS ###
  # Source Rust Cli tools install file
  RUST_TOOLS_INSTALL_PATH="${PROJECT_TOP_DIR}/src/rust/install_rust_cli_tools.sh"
  if [[ -f "${RUST_TOOLS_INSTALL_PATH}" ]]; then
      source "${RUST_TOOLS_INSTALL_PATH}"
  else
      echo "Error: Could not find install_rust_cli_tools.sh at ${RUST_TOOLS_INSTALL_PATH}"
      exit 1
  fi
  # Install all defined rust tools with shell config file as an argument
  Rust::Cli::install_all_tools ${SHELLRC_PATH} || exit 1

  ### GO ###
  # Install Go
  bash ./src/golang/go_install.sh
  source ~/.bashrc.user
}

ProjectName::verify_installation()
{
  ### RUST ###
  # Verify installation
  source ${SHELLRC_PATH}
  if command -v rustc >/dev/null 2>&1; then
    rustc --version
  else
    echo "❌ rustc not found after install."
    exit 1
  fi

  ### RUST TOOLS ###
  # Verify installation of rust tools
  source ${SHELLRC_PATH}
  Rust::Cli::verify_installed || exit 1

  ### GO ###
  # Verify Go installation
  if command -v go >/dev/null 2>&1; then
    go version
  else
    echo "❌ Go not found after install."
    exit 1
  fi
}

ProjectName::uninstall()
{
  ### RUST TOOLS ###
  # Source Rust Cli tools uninstall file
  RUST_TOOLS_UNINSTALL_PATH="${PROJECT_TOP_DIR}/src/rust/uninstall_rust_cli_tools.sh"
  if [[ -f "${RUST_TOOLS_UNINSTALL_PATH}" ]]; then
      source "${RUST_TOOLS_UNINSTALL_PATH}"
  else
      echo "Error: Could not find uninstall_rust_cli_tools.sh at ${RUST_TOOLS_UNINSTALL_PATH}"
      exit 1
  fi
  # Uninstall all defined rust tools with shell config file as an argument
  Rust::Cli::uninstall_all_tools ${SHELLRC_PATH} || exit 1

  ### RUST ###
  # Source rust uninstall file
  RUST_UNINSTALL_PATH="${PROJECT_TOP_DIR}/src/rust/uninstall_rust.sh"
  if [[ -f "${RUST_UNINSTALL_PATH}" ]]; then
      source "${RUST_UNINSTALL_PATH}"
  else
      echo "Error: Could not find uninstall_rust.sh at ${RUST_UNINSTALL_PATH}"
      exit 1
  fi
  # Uninstall Rust with shell config file as an argument
  Rust::uninstall ${SHELLRC_PATH} || exit 1

  ### GO ###
  # Uninstall Go
  bash ./src/golang/go_uninstall.sh
}

ProjectName::verify_uninstallation()
{
  ### RUST TOOLS ###
  # Verify uninstallation of rust tools
  source ${SHELLRC_PATH}
  Rust::Cli::verify_uninstalled || exit 1

  ### RUST ###
  # Verify Rust uninstallation
  if [ ! -d "$HOME/.cargo" ] && [ ! -d "$HOME/.rustup" ]; then
    echo "✅ Rust successfully uninstalled."
  else
    echo "❌ Rust files still exist after uninstall."
    exit 1
  fi

  ### GO ###
  # Verify Go uninstallation
  if [ ! -d "$HOME/go" ] && [ ! -d "$HOME/.local/go" ]; then
    echo "✅ Go successfully uninstalled."
  else
    echo "❌ Go files still exist after uninstall."
    exit 1
  fi
}