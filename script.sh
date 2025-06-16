#!/usr/bin/env bash
set -e

# GLOBAL PATHS FOR ENTIRE PROJECT
# Parameter for setting shell config file that will be used by a user (bashrc/zshrc)
# TODO: Needs to be modifiable by the initial script configuration.
export SHELLRC_PATH="${HOME}/.bashrc.user"
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


if [ ! -f ${SHELLRC_PATH} ]
then
  touch ${SHELLRC_PATH}
fi

source ./project_name.sh

ProjectName::install zsh
ProjectName::verify_installation zsh
ProjectName::uninstall zsh
ProjectName::verify_uninstallation zsh

ProjectName::install bash
ProjectName::verify_installation bash
ProjectName::uninstall bash
ProjectName::verify_uninstallation bash