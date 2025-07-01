#!/usr/bin/env bash
# To ignore warnings globally, go to the .shellcheckrc file.

LOGGER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../src/logger" && pwd)/script_logger.sh"
source "${LOGGER_PATH}"

# Colors
COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[0;32m"
COLOR_RESET='\033[0m'
COLOR_BLUE="\033[1;34m"

# Runs shellcheck on a list of files and prints results
function run_shellcheck_all_files() {
    local files=("$@")
    local pass=0
    local fail=0
    local pass_list=()
    local fail_list=()
    local idx=1

    for file in "${files[@]}"; do
        Logger::log_info "${COLOR_BLUE}[$idx] Checking: $file ${COLOR_RESET}"
        if shellcheck "$file"; then
            ((pass++))
            pass_list+=("$file")
            Logger::log_success "${COLOR_GREEN}[PASS] $file${COLOR_RESET}"
        else
            ((fail++))
            fail_list+=("$file")
            Logger::log_error "${COLOR_RED}[FAIL] $file${COLOR_RESET}"
        fi
        ((idx++))
        cols=$(tput cols 2>/dev/null || echo 80)
        echo -e "${COLOR_BLUE}$(printf '%*s' "$cols" '' | tr ' ' '-')${COLOR_RESET}"
    done

    Logger::log_info "${COLOR_GREEN}[PASS] Passed ${pass}:${COLOR_RESET}"
    for p in "${pass_list[@]}"; do
        Logger::log_success "  ${COLOR_GREEN}- $p${COLOR_RESET}"
    done

    echo -e "${COLOR_BLUE}$(printf '%*s' "$cols" '' | tr ' ' '-')${COLOR_RESET}"
    Logger::log_info "${COLOR_RED}[FAIL] Failed (${fail}):${COLOR_RESET}"
    for f in "${fail_list[@]}"; do
        Logger::log_error "  ${COLOR_RED}- $f${COLOR_RESET}"
    done

    # Return 1 if any files failed ShellCheck
    if [ ${#fail_list[@]} -gt 0 ]; then
        return 1
    else
        return 0
    fi
}
