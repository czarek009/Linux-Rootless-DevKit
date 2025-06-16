#!/usr/bin/env bash

# Format: "tool_name:binary_name[:extra_flags][:shell_init]"
# Using format tool_name:binary_name::shell_init (not using flags but using shell_init) 
#   might cause a failure becasue of passing some part of shell_init into flags.
RUST_CLI_TOOLS=(
    "du-dust:dust:--locked"
    # "tealdeer:tldr:--locked"
    # "ripgrep:rg:--locked"
    # "gitui:gitui:--locked"
    # "git-delta:delta:--locked"
    # "atuin:atuin:--locked:eval \"\$(atuin init bash --disable-up-arrow)\""
    # "eza:eza:--locked"
    # "tokei:tokei:--locked"
    # "procs:procs:--locked"

    #"zoxide:zoxide:--locked:eval \"\$(zoxide init bash)\""
)

# Get tool name, binary, and optional flags
Rust::Cli::parse_tool_entry() {
    local entry="$1"
    IFS=":" read -r tool_name binary flags shell_init <<< "${entry}"
    echo "${tool_name}" "${binary}" "${flags}" "${shell_init}"
}

# Check if cargo is available
Rust::Cli::check_cargo_available() {
    if ! command -v cargo >/dev/null 2>&1; then
        echo "Error: 'cargo' is not available. Please install Rust first."
        exit 1
    fi
}
