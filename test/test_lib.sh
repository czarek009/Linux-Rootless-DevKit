#!/usr/bin/env bash
# To ignore warnings globally, go to the main directory and add the appropriate comments to the .shellcheckrc file.

# Colors
COLOR_RED="\033[0;31m"
COLOR_GREEN="\033[0;32m"
COLOR_RESET='\033[0m'
COLOR_DARK_GRAY='\033[1;30m'

# Runs shellcheck on a list of files and prints results
function run_shellcheck_all_files() {
    local files=("$@")
    local pass=0
    local fail=0
    local pass_list=()
    local fail_list=()
    local idx=1

    for file in "${files[@]}"; do
	echo -e "\n${COLOR_DARK_GRAY}🧪 [$idx] Check: $file ${COLOR_RESET}"
        if shellcheck "$file"; then
            ((pass++))
            pass_list+=("$file")
            echo -e "${COLOR_GREEN}✔  Passed: $file"
        else
            ((fail++))
            fail_list+=("$file")
            echo -e "${COLOR_RED}✘ Failed: $file"
        fi
        ((idx++))
	echo -e "\033[1;34m$(printf '%*s' "$(tput cols)" '' | tr ' ' '─')\033[0m"
    done

    echo -e "\n${COLOR_GREEN}✅ Passed ${pass}:${COLOR_RESET}"
    for p in "${pass_list[@]}"; do
	echo -e "  ${COLOR_GREEN}- $p${COLOR_RESET}"
    done

    echo -e "\n${COLOR_RED}❌ Failed (${fail}):${COLOR_RESET}"
    for f in "${fail_list[@]}"; do
	echo -e "  ${COLOR_RED}- $f${COLOR_RESET}"
    done
}
