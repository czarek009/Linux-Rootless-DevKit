#!/usr/bin/env bash

# Install a single Rust CLI tool if not already installed
Rust::Cli::install_tool() {
    local shellrc_path="$1"
    local tool_name="$2"
    local command_name="$3"
    local install_flags="$4"
    local shell_init="$5"
    local temp_log
    temp_log=$(mktemp)

    # Check if the tool already exists
    if command -v "${command_name}" >/dev/null 2>&1; then
        echo "${tool_name} is already installed — skipping."
        return 0
    fi

    echo "[*] Installing ${tool_name}..."

    if cargo install "${install_flags}" "${tool_name}" >"${temp_log}" 2>&1; then
        echo "${tool_name} installed successfully"
        rm -f "${temp_log}"

	# Inject shell init into shellrc file if defined for tool and not already present
        if [[ -n "${shell_init}" ]]; then
            # Safely append to shellrc file with interactive shell check
            shell_safe="if [ -t 1 ] && [[ \$- == *i* ]]; then ${shell_init}; fi"

	    if ! grep -Fq "${shell_safe}" "${shellrc_path}"; then
                echo "[*] Adding shell init for ${tool_name} to ${shellrc_path}"
                    echo "${shell_safe}" >> "${shellrc_path}"
	    else
                echo "[*] Shell init for ${tool_name} already present"
            fi
        fi
    else
        echo "Failed to install ${tool_name}. See log:"
        cat "${temp_log}" >&2
        rm -f "${temp_log}"
	return 1
    fi
}

# Install all desired Rust CLI tools
Rust::Cli::install_all_tools() {
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
        read -r tool_name binary flags shell_init <<< "$(Rust::Cli::parse_tool_entry "${entry}")"
        Rust::Cli::install_tool "${shellrc_path}" "${tool_name}" "${binary}" "${flags}" "${shell_init}" || exit 1
    done
}

# Verify installation of all defined Rust tools
Rust::Cli::verify_installed() {
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

    echo "Verifying installed Rust CLI tools:"
    for entry in "${RUST_CLI_TOOLS[@]}"; do
        read -r tool_name binary _ _ <<< "$(Rust::Cli::parse_tool_entry "${entry}")"

        if command -v "${binary}" &>/dev/null; then
            echo "${tool_name} is successfully installed"
        else
            echo "${tool_name} is not installed"
	    return 1
        fi
    done
}
