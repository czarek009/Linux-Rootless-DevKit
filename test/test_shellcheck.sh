#!/usr/bin/env bash
# To ignore warnings globally, go to the .shellcheckrc file.
# To run the script on all .sh files, choose the option: ./test_shellcheck.sh -p
# To run the script for selected files in SELECTED_TESTS, choose the option: ./test_shellcheck.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_TOP_DIR="${SCRIPT_DIR}/.."

# Source libraries
TEST_LIB_PATH="${PROJECT_TOP_DIR}/test/test_lib.sh"
if [[ -f "${TEST_LIB_PATH}" ]]; then
    # shellcheck source=/dev/null
    source "${TEST_LIB_PATH}"
else
    echo "Error: Could not find test_lib.sh at ${TEST_LIB_PATH}"
    exit 1
fi

# Lists of files to be checked
declare -a SELECTED_TESTS=(
    "${PROJECT_TOP_DIR}/test/test_dockerfile_main.sh"
    "${PROJECT_TOP_DIR}/test/test_lib.sh"
    "${PROJECT_TOP_DIR}/test/test_shellcheck.sh"
    "${PROJECT_TOP_DIR}/script.sh"
    "${PROJECT_TOP_DIR}/src/golang/go_install.sh"
    "${PROJECT_TOP_DIR}/src/golang/go_uninstall.sh"
    "${PROJECT_TOP_DIR}/src/rust/install_rust.sh"
    "${PROJECT_TOP_DIR}/src/rust/uninstall_rust.sh"
    "${PROJECT_TOP_DIR}/src/zsh/zsh_install.sh"
    "${PROJECT_TOP_DIR}/src/zsh/zsh_uninstall.sh"
    "${PROJECT_TOP_DIR}/src/scriptLogger/test_logger.sh"
    "${PROJECT_TOP_DIR}/src/scriptLogger/script_logger.sh"
)

# Choose option for running
if [[ "${1:-}" == "-p" ]]; then
    # Run shellcheck on all files in the project
    mapfile -t all_files < <(find "${PROJECT_TOP_DIR}" -type f -name "*.sh" || true)

    # Check if the array of files is empty
    if (( ${#all_files[@]} == 0 )); then
        echo "No .sh files found in the project."
        exit 1
    else
        # Run shellcheck on all found files
        run_shellcheck_all_files "${all_files[@]}"
    fi
else
    # Run shellcheck on the selected test files only
    run_shellcheck_all_files "${SELECTED_TESTS[@]}"
fi
