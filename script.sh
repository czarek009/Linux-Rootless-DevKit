#!/usr/bin/env bash
set -e

# GLOBAL PATHS FOR ENTIRE PROJECT
# Parameter for setting shell config file that will be used by a user (bashrc/zshrc)
# TODO: Needs to be modifiable by the initial script configuration.
export SHELLRC_PATH="${HOME}/.bashrc"
export BACKUP_PATH="${HOME}/.project-backup"
export LOGGER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../scriptLogger" && pwd)/script_logger.sh"
export SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PROJECT_TOP_DIR="${SCRIPT_DIR}"

# Run logger test sequence:
echo "ℹ️ Running logger test sequence..."
TEST_LOG_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/src/scriptLogger/logs"
bash ./src/scriptLogger/test_logger.sh
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
logger_check_str "test_logger" "Starting scriptLogger test"
logger_check_str "test_logger" "This is a warning message"
logger_check_str "test_logger" "This is an error message"
logger_check_str "test_logger" "This is a debug message"
logger_check_str "test_logger" "This is a custom log message."
logger_check_str "test_logger" "this/file/does/not/exist' does not exist"
logger_check_str "test_logger" "Command 'ls' exists"
logger_check_str "test_logger" "Command 'thiscommanddoesnotexist' does not exist"
logger_check_str "testTraps" "Script interrupted by user"
rm -r "$TEST_LOG_DIR"


source ./project_name.sh

ProjectName::install

################### BASH ###################
# source ${PROJECT_TOP_DIR}/src/bash/omb_install.sh
# Omb::install || exit 1
# Omb::verify_installation || exit 1

# source ${PROJECT_TOP_DIR}/src/bash/omb_uninstall.sh
# Omb::uninstall || exit 1
# Omb::verify_uninstallation || exit 1


################### ZSH ###################
# Intall zsh
bash ./src/zsh/zsh_install.sh
export PATH="$HOME/.local/bin:$PATH"
source $HOME/.bashrc

ProjectName::verify_installation

# Verify installation
if command -v zsh >/dev/null 2>&1; then
  zsh --version
  echo "✅ zsh successfully installed."
else
  echo "❌ zsh not found after install."
  exit 1
fi

ProjectName::uninstall

# Uninstall zsh
bash ./src/zsh/zsh_uninstall.sh
source $HOME/.bashrc

ProjectName::verify_uninstallation

# Verify uninstallation
if [ ! -d "$HOME/.oh-my-zsh" ] && [ ! -d "$HOME/.local/bin/zsh" ]; then
  echo "✅ zsh successfully uninstalled."
else
  echo "❌ zsh files still exist after uninstall."
  exit 1
fi