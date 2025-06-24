#!/usr/bin/env bash
set -e

# Parameter for setting shell config file that will be used by a user (bashrc/zshrc)
# TODO: Needs to be modifiable by the initial script configuration.
SHELLRC_PATH="$HOME/.bashrc"

# Run envConfigurator test sequence:
echo "ℹ️ Running envConfigurator test sequence..."
bash ./src/envConfigurator/test_envConfigurator.sh
wait

# Run logger test sequence:
echo "ℹ️ Running logger test sequence..."
TEST_LOG_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/src/scriptLogger/logs"
bash ./src/scriptLogger/loggerTest.sh
wait

# Verify logger results:
logger_check_str()
{
  local file_prefix="$1"
  local search_str="$2"
  local log_file
  # take most recent log file:
  log_file=$(find "$TEST_LOG_DIR" -type f -name "${file_prefix}*" | sort | tail -n 1)

  if [ -n "$log_file" ] && [ -f "$log_file" ]; then
    if grep -Fq "$search_str" "$log_file" &> /dev/null; then
        echo "✅ File '$log_file' contains string '$search_str'."
    else
        echo "❌ File '$log_file' does not contain string '$search_str'."
        exit 1
    fi
  else
    echo "❌ No log file found with prefix '$file_prefix' in '$log_dir'."
    exit 1
  fi
}
logger_check_str "loggerTest" "Starting scriptLogger test"
logger_check_str "loggerTest" "This is a warning message"
logger_check_str "loggerTest" "This is an error message"
logger_check_str "loggerTest" "This is a debug message"
logger_check_str "loggerTest" "This is a custom log message."
logger_check_str "loggerTest" "this/file/does/not/exist' does not exist"
logger_check_str "loggerTest" "Command 'ls' exists"
logger_check_str "loggerTest" "Command 'thiscommanddoesnotexist' does not exist"
logger_check_str "testTraps" "Script interrupted by user"
rm -r "$TEST_LOG_DIR"

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_TOP_DIR="${SCRIPT_DIR}"

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

# Verify installation
source ${SHELLRC_PATH}
if command -v rustc >/dev/null 2>&1; then
  rustc --version
else
  echo "❌ rustc not found after install."
  exit 1
fi

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

# Verify installation of rust tools
source ${SHELLRC_PATH}
Rust::Cli::verify_installed || exit 1

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

# Verify uninstallation of rust tools
source ${SHELLRC_PATH}
Rust::Cli::verify_uninstalled || exit 1

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

# Verify Rust uninstallation
if [ ! -d "$HOME/.cargo" ] && [ ! -d "$HOME/.rustup" ]; then
  echo "✅ Rust successfully uninstalled."
else
  echo "❌ Rust files still exist after uninstall."
  exit 1
fi

# Intall zsh
bash ./src/zsh/zshInstall.sh
export PATH="$HOME/.local/bin:$PATH"
source $HOME/.bashrc

# Verify installation
if command -v zsh >/dev/null 2>&1; then
  zsh --version
  echo "✅ zsh successfully installed."
else
  echo "❌ zsh not found after install."
  exit 1
fi

# Uninstall zsh
bash ./src/zsh/zshUninstall.sh
source $HOME/.bashrc

# Verify uninstallation
if [ ! -d "$HOME/.oh-my-zsh" ] && [ ! -d "$HOME/.local/bin/zsh" ]; then
  echo "✅ zsh successfully uninstalled."
else
  echo "❌ zsh files still exist after uninstall."
  exit 1
fi

# Install Go
bash ./src/go_install.sh
source ~/.bashrc.user

# Verify Go installation
if command -v go >/dev/null 2>&1; then
  go version
else
  echo "❌ Go not found after install."
  exit 1
fi

# Uninstall Go
bash ./src/go_uninstall.sh

# Verify Go uninstallation
if [ ! -d "$HOME/go" ] && [ ! -d "$HOME/.local/go" ]; then
  echo "✅ Go successfully uninstalled."
else
  echo "❌ Go files still exist after uninstall."
  exit 1
fi