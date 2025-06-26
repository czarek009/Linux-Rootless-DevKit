#!/usr/bin/env bash

# Rust uninstallation function

Rust::uninstall() {
    local cargo_dir="${HOME}/.cargo"
    local rustup_dir="${HOME}/.rustup"
    local shellrc_path="$1"
    local cargo_path_line="export PATH=\"${HOME}/.cargo/bin:${PATH}\""
    local temp_log
    temp_log=$(mktemp)

    echo "[*] Removing Rust directories"
    rm -rf "${cargo_dir}" "${rustup_dir}"

    if [[ -w "${shellrc_path}" ]] && grep -Fxq "${cargo_path_line}" "${shellrc_path}" >"${temp_log}" 2>&1; then
        grep -Fxv "${cargo_path_line}" "${shellrc_path}" > "${shellrc_path}.tmp" && mv "${shellrc_path}.tmp" "${shellrc_path}" >"${temp_log}" 2>&1
        echo "[*] Removed Cargo PATH from ${shellrc_path}"
    fi

    if [[ ! -d "${cargo_dir}" ]] && [[ ! -d "${rustup_dir}" ]]; then
        echo "Rust successfully uninstalled"
        rm -f "${temp_log}"
        return 0
    else
        echo "Rust uninstallation failed. See log:"
        cat "${temp_log}" >&2
        rm -f "${temp_log}"
        return 1
    fi
}

