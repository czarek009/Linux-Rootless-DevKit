#!/usr/bin/env bash

# Rust installation function

Rust::install() {
    local rustup_url="https://sh.rustup.rs"
    local rustup_init="rustup-init.sh"
    local shellrc_path=$1
    local cargo_path_line="export PATH=\"${HOME}/.cargo/bin:${PATH}\""
    local temp_log
    temp_log=$(mktemp)

    echo "[*] Downloading rustup-init from ${rustup_url}"

    curl --proto '=https' --tlsv1.2 -sSf "${rustup_url}" -o "${rustup_init}" && chmod +x "${rustup_init}"

    echo "[*] Installing Rust"

    if RUSTUP_INIT_SKIP_PATH_CHECK=yes ./"${rustup_init}" -y \
        --default-toolchain stable \
        --profile default \
        --no-modify-path >"${temp_log}" 2>&1; then

        rm -f "${rustup_init}" "${temp_log}"

        if [[ -w "${shellrc_path}" ]] && ! grep -Fxq "${cargo_path_line}" "${shellrc_path}"; then
            echo "${cargo_path_line}" >> "${shellrc_path}"
        fi

        echo "Rust successfully installed."
        return 0
    else
        echo "Rust installation failed. See log:"
        cat "${temp_log}" >&2
        rm -f "${temp_log}" "${rustup_init}"
        return 1
    fi
}

