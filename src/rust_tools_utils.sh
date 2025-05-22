#!/usr/bin/env bash

# Define Rust CLI tools: "tool_name:binary_name[:extra_flags]"
RUST_CLI_TOOLS=(
    "du-dust:dust"
    "tealdeer:tldr"
    "ripgrep:rg"
    "gitui:gitui:--locked"
    "git-delta:delta"
    "atuin:atuin"
    "eza:eza"
    "tokei:tokei"
    "procs:procs"
)

# Get tool name, binary, and optional flags
RustCli::parse_tool_entry() {
    local entry="$1"
    IFS=":" read -r tool_name binary flags <<< "$entry"
    echo "$tool_name" "$binary" "$flags"
}

# Check if cargo is available
RustCli::check_cargo_available() {
    if ! command -v cargo >/dev/null 2>&1; then
        echo "Error: 'cargo' is not available. Please install Rust first."
        exit 1
    fi
}
