#!/usr/bin/env bash
set -e

START_TIME=$(date +"%Y-%m-%d %H:%M:%S")
# GLOBAL PATHS FOR ENTIRE PROJECT
# Parameter for setting shell config file that will be used by a user (bashrc/zshrc)
# TODO: Needs to be modifiable by the initial script configuration.

ENV_PATHS_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/src/env_variables.sh"
source "${ENV_PATHS_LIB}"
# ENVCONFIGURATOR_DIR_PATH="$( cd -- "$(dirname "${BASH_SOURCE[0]}")/src/envConfigurator" >/dev/null 2>&1 || exit ; pwd -P )"
# source "$ENVCONFIGURATOR_DIR_PATH/envConfigurator.sh"
ENV_CONFIGURATOR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/src/envConfigurator/envConfigurator.sh"
source "${ENV_CONFIGURATOR_PATH}"
LOGGER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/src/logger" && pwd)/script_logger.sh"
source "$LOGGER_PATH"

# Run envConfigurator test sequence:
Logger::log_info "ℹ️ Running envConfigurator test sequence..."
source "./src/envConfigurator/test_envConfigurator.sh"
EnvConfigurator::test

# Run logger test sequence:
Logger::log_info "ℹ️ Running logger test sequence..."
TEST_LOG_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/src/logger/logs"
source "./src/logger/test_logger.sh"
set +e
Logger::test
set -e

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
        Logger::log_success "✅ File '$log_file' contains string '$search_str'."
    else
        Logger::log_error "❌ File '$log_file' does not contain string '$search_str'."
        exit 1
    fi
  else
    Logger::log_error "❌ No log file found with prefix '$file_prefix' in '$TEST_LOG_DIR'."
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
EnvConfigurator::remove_dir_if_exists "$TEST_LOG_DIR" "y"

EnvConfigurator::create_file_if_not_exists "${SHELLRC_PATH}"

source ./LinuxRootlessDevKit.sh

LinuxRootlessDevKit::install "${SELECTED_SHELL}"
LinuxRootlessDevKit::verify_installation "${SELECTED_SHELL}"

Logger::log_info "ℹ️ Files created or modified in $HOME after install started:"
find "$HOME" -type d \( -path "$HOME/.cache" -o -path "$HOME/.var" \) -prune -o \
-type f \( -newermt "$START_TIME" -o -newerct "$START_TIME" \) -print 2>/dev/null \
> "new_modified_home_files_after_install_${SELECTED_SHELL}.txt"
wc -l < "new_modified_home_files_after_install_${SELECTED_SHELL}.txt"

LinuxRootlessDevKit::uninstall "${SELECTED_SHELL}"
LinuxRootlessDevKit::verify_uninstallation "${SELECTED_SHELL}"

Logger::log_info "ℹ️Files created or modified in $HOME after install and uninstall:"
find "$HOME" -type d \( -path "$HOME/.cache" -o -path "$HOME/.var" \) -prune -o \
-type f \( -newermt "$START_TIME" -o -newerct "$START_TIME" \) -print 2>/dev/null \
> "new_modified_home_files_after_install_unistall_${SELECTED_SHELL}.txt"
wc -l < "new_modified_home_files_after_install_unistall_${SELECTED_SHELL}.txt"