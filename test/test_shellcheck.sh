#!/usr/bin/env bash
# To ignore warnings globally, go to the .shellcheckrc file.
# To run the script on all .sh files, choose the option: ./test_shellcheck.sh -p
# To run the script for selected files in SELECTED_TESTS, choose the option: ./test_shellcheck.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_TOP_DIR="${SCRIPT_DIR}/.."
LOGGER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../src/logger" && pwd)/script_logger.sh"
source "${LOGGER_PATH}"
TEST_LIB_PATH="${PROJECT_TOP_DIR}/test/test_lib.sh"
source "${TEST_LIB_PATH}"

# Checking if shellcheck is installed
if ! command -v shellcheck &>/dev/null; then
    Logger::log_error "Error: shellcheck is not installed."
    exit 1
fi

# Lists of files to be checked
declare -a SELECTED_TESTS=(
    "${PROJECT_TOP_DIR}/src/bash/omb_install.sh"
    "${PROJECT_TOP_DIR}/src/bash/omb_uninstall.sh"
    "${PROJECT_TOP_DIR}/LinuxRootlessDevKit.sh"
    "${PROJECT_TOP_DIR}/test/test_dockerfile_main.sh"
    "${PROJECT_TOP_DIR}/test/test_lib.sh"
    "${PROJECT_TOP_DIR}/test/test_shellcheck.sh"
    "${PROJECT_TOP_DIR}/main.sh"
    "${PROJECT_TOP_DIR}/src/golang/go_install.sh"
    "${PROJECT_TOP_DIR}/src/golang/go_uninstall.sh"
    "${PROJECT_TOP_DIR}/src/rust/rust_install.sh"
    "${PROJECT_TOP_DIR}/src/rust/rust_uninstall.sh"
    "${PROJECT_TOP_DIR}/src/zsh/zsh_install.sh"
    "${PROJECT_TOP_DIR}/src/zsh/zsh_uninstall.sh"
    "${PROJECT_TOP_DIR}/src/logger/test_logger.sh"
    "${PROJECT_TOP_DIR}/src/logger/script_logger.sh"
)

# Choose option for running
if [[ "${1:-}" == "-p" ]]; then
    # Run shellcheck on all files in the project
    mapfile -t all_files < <(find "${PROJECT_TOP_DIR}" -type f -name "*.sh" || true)

    # Check if the array of files is empty
    if (( ${#all_files[@]} == 0 )); then
        Logger::log_warning "No .sh files found in the project."
        exit 1
    else
        # Run shellcheck on all found files
        run_shellcheck_all_files "${all_files[@]}"
    fi
else
    # Run shellcheck on the selected test files only
    run_shellcheck_all_files "${SELECTED_TESTS[@]}"
fi
