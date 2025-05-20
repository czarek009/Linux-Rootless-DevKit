#!/usr/bin/env bash

# Rust uninstallation function

uninstall_rust() {
    local cargo_dir="$HOME/.cargo"
    local rustup_dir="$HOME/.rustup"
    local bashrc="$HOME/.bashrc"
    local cargo_path_line='export PATH="$HOME/.cargo/bin:$PATH"'
    local temp_log
    temp_log=$(mktemp)

    {
        echo "[*] Removing Rust directories"
        rm -rf "$cargo_dir" "$rustup_dir"

        if [ -w "$bashrc" ] && grep -Fxq "$cargo_path_line" "$bashrc"; then
            grep -Fxv "$cargo_path_line" "$bashrc" > "${bashrc}.tmp" && mv "${bashrc}.tmp" "$bashrc"
            echo "[*] Removed Cargo PATH from $bashrc"
        fi
    } >"$temp_log" 2>&1

    if [ ! -d "$cargo_dir" ] && [ ! -d "$rustup_dir" ]; then
        echo "Rust successfully uninstalled"
        rm -f "$temp_log"
        return 0
    else
        echo "Rust uninstallation failed. See log:"
        cat "$temp_log" >&2
        rm -f "$temp_log"
        return 1
    fi
}

