#!/usr/bin/env bash


# Install a single Rust CLI tool if not already installed
RustCli::install_tool() {
    local tool_name="$1"
    local command_name="$2"
    local install_flags="$3"
    local temp_log
    temp_log=$(mktemp)

    # Check if the tool already exists
    if command -v "$command_name" >/dev/null 2>&1; then
        echo "$tool_name is already installed — skipping."
        return 0
    fi

    echo "[*] Installing $tool_name..."

    if cargo install $install_flags "$tool_name" >"$temp_log" 2>&1; then
        echo "$tool_name installed successfully"
        rm -f "$temp_log"
    else
        echo "Failed to install $tool_name. See log:"
        cat "$temp_log" >&2
        rm -f "$temp_log"
	return 1
    fi
}

# Install all desired Rust CLI tools
RustCli::install_all_tools() {
    # Get the directory of the current script
    local SCRIPT_CURR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local RUST_TOOLS_UTILS_PATH="${SCRIPT_CURR_DIR}/rust_tools_utils.sh"

    # source rust cli tools utils file
    if [[ -f "${RUST_TOOLS_UTILS_PATH}" ]]; then
        source "${RUST_TOOLS_UTILS_PATH}"
    else
        echo "Error: Could not find rust_tools_utils.sh at ${RUST_TOOLS_UTILS_PATH}"
        exit 1
    fi

    RustCli::check_cargo_available || exit 1

    for entry in "${RUST_CLI_TOOLS[@]}"; do
        read -r tool_name binary flags <<< "$(RustCli::parse_tool_entry "$entry")"
        RustCli::install_tool "$tool_name" "$binary" "$flags" || exit 1
    done
}

# Verify installation of all defined Rust tools
RustCli::verify_installed() {
    # Get the directory of the current script
    local SCRIPT_CURR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
        read -r tool_name binary _ <<< "$(RustCli::parse_tool_entry "$entry")"

        if command -v "$binary" &>/dev/null; then
            echo "$tool_name is successfully installed"
        else
            echo "$tool_name is not installed"
	    return 1
        fi
    done
}
