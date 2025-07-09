#!/usr/bin/env bash
# shellcheck disable=SC2312

# Uninstall a single Rust CLI tool if installed
Rust::Cli::uninstall_tool() {
    local shellrc_path="$1"
    local tool_name="$2"
    local command_name="$3"
    local shell_init="$4"
    local temp_log
    temp_log=$(mktemp)

    # Skip not present tools
    if ! cargo install --list | grep -q "^${tool_name} v"; then
        return 0
    fi

    echo "[*] Uninstalling ${tool_name}..."

    if cargo uninstall "${tool_name}" >"${temp_log}" 2>&1; then
        echo "${tool_name} uninstalled successfully"
        rm -f "${temp_log}"

	if [[ -n "${shell_init}" ]]; then
            echo "[*] Removing shell init for ${tool_name} from shellrc file"

	    # Escape special characters for use in sed
	    escaped_shell_init=$(printf '%s\n' "${shell_init}" | sed -e 's/[]\/$*.^[]/\\&/g')

	    # Remove the entire block if it contains the shell_init line
	    sed -i.bak -e "/if \[ -t 1 \] && \[\[ \$- == \*i\* \]\]; then/,/fi/ {
	    	/${escaped_shell_init}/!b
	    	d
    	    }" "${shellrc_path}"
        fi
    else
        echo "Failed to uninstall ${tool_name}. See log:"
        cat "${temp_log}" >&2
        rm -f "${temp_log}"
	return 1
    fi
}

# Uninstall all desired Rust CLI tools
Rust::Cli::uninstall_all_tools() {
    local shellrc_path="$1"

    # Get the directory of the current script
    local SCRIPT_CURR_DIR
    SCRIPT_CURR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local RUST_TOOLS_UTILS_PATH="${SCRIPT_CURR_DIR}/rust_tools_utils.sh"

    # source rust cli tools utils file
    if [[ -f "${RUST_TOOLS_UTILS_PATH}" ]]; then
        source "${RUST_TOOLS_UTILS_PATH}"
    else
        echo "Error: Could not find rust_tools_utils.sh at ${RUST_TOOLS_UTILS_PATH}"
        exit 1
    fi

    Rust::Cli::check_cargo_available || exit 1

    for entry in "${RUST_CLI_TOOLS[@]}"; do
        read -r tool_name binary _ shell_init <<< "$(Rust::Cli::parse_tool_entry "${entry}")"
        Rust::Cli::uninstall_tool "${shellrc_path}" "${tool_name}" "${binary}" "${shell_init}"
    done
}

# Verify all rust tools have been removed
Rust::Cli::verify_uninstalled() {
    # Get the directory of the current script
    local SCRIPT_CURR_DIR
    SCRIPT_CURR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local RUST_TOOLS_UTILS_PATH="${SCRIPT_CURR_DIR}/rust_tools_utils.sh"

    # source rust cli tools utils file
    if [[ -f "${RUST_TOOLS_UTILS_PATH}" ]]; then
        source "${RUST_TOOLS_UTILS_PATH}"
    else
        echo "Error: Could not find rust_tools_utils.sh at ${RUST_TOOLS_UTILS_PATH}"
        exit 1
    fi

    # Verify defined rust tools
    echo "Verifying uninstallation of Rust CLI tools:"
    for entry in "${RUST_CLI_TOOLS[@]}"; do
        read -r tool_name binary _ _ <<< "$(Rust::Cli::parse_tool_entry "${entry}")"
        if command -v "${binary}" >/dev/null 2>&1 | cargo install --list | grep -q "^${tool_name} v"; then
            echo "${tool_name} still exist after uninstall"
	    return 1
        else
            echo "${tool_name} successfully uninstalled"
        fi
    done
}
