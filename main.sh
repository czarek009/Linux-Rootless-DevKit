#!/usr/bin/env bash
set -e

# GLOBAL PATHS FOR ENTIRE PROJECT
# Parameter for setting shell config file that will be used by a user (bashrc/zshrc)
# TODO: Needs to be modifiable by the initial script configuration.
SHELLRC_PATH="${HOME}/.bashrc.user"
BACKUP_PATH="${HOME}/.project-backup"
LOGGER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/src/logger" && pwd)/script_logger.sh"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_TOP_DIR="${SCRIPT_DIR}"

export SHELLRC_PATH
export BACKUP_PATH
export LOGGER_PATH
export SCRIPT_DIR
export PROJECT_TOP_DIR

# Run envConfigurator test sequence:
echo "ℹ️ Running envConfigurator test sequence..."
bash ./src/envConfigurator/test_envConfigurator.sh
wait

# Run logger test sequence:
echo "ℹ️ Running logger test sequence..."
TEST_LOG_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/src/logger/logs"
bash ./src/logger/test_logger.sh
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
logger_check_str "test_logger" "Starting logger test"
logger_check_str "test_logger" "This is a warning message"
logger_check_str "test_logger" "This is an error message"
logger_check_str "test_logger" "This is a debug message"
logger_check_str "test_logger" "This is a custom log message."
logger_check_str "test_logger" "this/file/does/not/exist' does not exist"
logger_check_str "test_logger" "Command 'ls' exists"
logger_check_str "test_logger" "Command 'thiscommanddoesnotexist' does not exist"
logger_check_str "testTraps" "Script interrupted by user"
rm -r "$TEST_LOG_DIR"


if [ ! -f "${SHELLRC_PATH}" ]
then
  touch "${SHELLRC_PATH}"
fi

source ./LinuxRootlessDevKit.sh

LinuxRootlessDevKit::install "${SELECTED_SHELL}"
LinuxRootlessDevKit::verify_installation "${SELECTED_SHELL}"
LinuxRootlessDevKit::uninstall "${SELECTED_SHELL}"
LinuxRootlessDevKit::verify_uninstallation "${SELECTED_SHELL}"
