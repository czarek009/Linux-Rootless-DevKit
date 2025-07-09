#!/usr/bin/env bash

# Format: "tool_name:binary_name[:shell_init]"
RUST_CLI_TOOLS=(
    "du-dust:dust"
    "tealdeer:tldr"
    "ripgrep:rg"
    "gitui:gitui"
    "git-delta:delta"
    "atuin:atuin:eval \"\$(atuin init bash --disable-up-arrow)\""
    "eza:eza"
    "tokei:tokei"
    "procs:procs"
    "zoxide:zoxide:eval \"\$(zoxide init bash)\""
) 

# Get tool name, binary, and optional flags
Rust::Cli::parse_tool_entry() {
    local entry="$1"
    IFS=":" read -r tool_name binary shell_init <<< "${entry}"
    echo "${tool_name}" "${binary}" "${shell_init}"
}

# Check if cargo is available
Rust::Cli::check_cargo_available() {
    if ! command -v cargo >/dev/null 2>&1; then
        echo "Error: 'cargo' is not available. Please install Rust first."
        exit 1
    fi
}

# Updates RUST_CLI_TOOLS with a current version of tools from .settings
Rust::Cli::update_tools_versions_from_settings() {
    local updated_tools=()

    if [[ ! -f "$MASTER_CONFIG_FILE" ]]; then
        echo "Settings file '$MASTER_CONFIG_FILE' not found."
        return 1
    fi

    for entry in "${RUST_CLI_TOOLS[@]}"; do
        # Extract parts (support entries with or without shell_init)
        IFS=":" read -r tool_name binary version shell_init <<< "$entry"

        # Convert tool name to uppercase and dash to underscore to match .settings keys
        local upper_key
        upper_key=$(echo "$tool_name" | tr '[:lower:]-' '[:upper:]_')

        # Extract version from .settings file using grep + sed (safer than eval)
        local config_version
        config_version=$(grep -E "^ROOTLESS_CONFIG_MASTER_RUST_TOOLS_${upper_key}_VERSION=" "$MASTER_CONFIG_FILE" | sed -E 's/.*="([^"]+)"/\1/')

        # If version is found, use it; otherwise fallback to original version
        local new_version="${config_version:-$version}"

        # Reconstruct entry with new version
        if [[ -n "$shell_init" ]]; then
            updated_tools+=("${tool_name}:${binary}:${new_version}:${shell_init}")
        else
            updated_tools+=("${tool_name}:${binary}:${new_version}")
        fi
        echo "$new_version"
    done

    # Replace the original RUST_CLI_TOOLS with the updated one
    RUST_CLI_TOOLS=("${updated_tools[@]}")

    echo "[*] RUST_CLI_TOOLS updated with versions from .settings"
}

Rust::Cli::persist_tool_versions_to_file() {
    local utils_file="${PROJECT_TOP_DIR}/rust_tools_utils.sh"

    if [[ ! -f "$MASTER_CONFIG_FILE" ]]; then
        Logger::log_error "Settings file '$MASTER_CONFIG_FILE' not found."
        return 1
    fi

    if [[ ! -f "$utils_file" ]]; then
        Logger::log_error "Rust tools utils file '$utils_file' not found."
        return 1
    fi

    for entry in "${RUST_CLI_TOOLS[@]}"; do
        IFS=":" read -r tool_name binary current_version shell_init <<< "$entry"
        upper_key=$(echo "$tool_name" | tr '[:lower:]-' '[:upper:]_')
        config_version=$(grep -E "^ROOTLESS_CONFIG_MASTER_RUST_TOOLS_${upper_key}_VERSION=" "$MASTER_CONFIG_FILE" | sed -E 's/.*="([^"]+)"/\1/')

        # Only proceed if there's a version override
        if [[ -n "$config_version" && "$config_version" != "$current_version" ]]; then
            # Match and replace exact version for this tool inside a quoted string
            local pattern="\"${tool_name}:${binary}:${current_version}"
            local replacement="\"${tool_name}:${binary}:${config_version}"
            EnvConfigurator::_replace "$utils_file" "$pattern" "$replacement"
            Logger::log_info "Updated $tool_name to version $config_version"
        fi
    done
}