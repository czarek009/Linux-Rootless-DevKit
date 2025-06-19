#!/usr/bin/env bash
# shellcheck disable=SC2312

# This script must install zsh + oh-my-zsh + fonts + power10k
# without sudo access

# Exit if non-zero status:
#set -e
# Show executed commanmds:
#set -x

LOGGER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../scriptLogger" && pwd)/script_logger.sh"
source "${LOGGER_PATH}"
PRECONFIGURED_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/preconfigured" && pwd)"

Zsh::get_latest_available_zsh_version() 
{
    curl -s "https://sourceforge.net/projects/zsh/rss?path=/zsh" \
    | grep -oP 'zsh-\K[0-9]+\.[0-9]+(\.[0-9]+)?(?=\.tar\.xz)' \
    | sort -V \
    | tail -1
}

Zsh::install()
{
    PRECONFIGURED_ARCHIVE="$(ls "${PRECONFIGURED_DIR}"/zsh-*.tar.xz 2>/dev/null | head -n1)"

    cd "${SRC_DIR}" || exit

    if [[ -n "${PRECONFIGURED_ARCHIVE}" ]]; then
        PRECONF_VERSION="$(basename "${PRECONFIGURED_ARCHIVE}" | grep -oP '[0-9]+\.[0-9]+(\.[0-9]+)?')"
    else
        PRECONF_VERSION=""
    fi

    if [[ "${PRECONF_VERSION}" = "${ZSH_VERSION}" ]]; then
        Logger::log_info "Using preconfigured Zsh archive: ${PRECONFIGURED_ARCHIVE}"
        cp "${PRECONFIGURED_ARCHIVE}" .
    elif [[ -n "${PRECONF_VERSION}" ]]; then
        Logger::log_warn "Preconfigured Zsh version (${PRECONF_VERSION}) is not the latest (${ZSH_VERSION}) - downloading latest"
        curl -LO "https://sourceforge.net/projects/zsh/files/zsh/${ZSH_VERSION}/zsh-${ZSH_VERSION}.tar.xz"
    else
        Logger::log_warn "No preconfigured Zsh archive found - downloading latest"
        curl -LO "https://sourceforge.net/projects/zsh/files/zsh/${ZSH_VERSION}/zsh-${ZSH_VERSION}.tar.xz"
    fi

    if [[ ! -d "zsh-${ZSH_VERSION}" ]]; then
        Logger::log_info "Extracting zsh ${ZSH_VERSION}"
        tar -xf "zsh-${ZSH_VERSION}.tar.xz"
    fi

    cd "zsh-${ZSH_VERSION}" || exit
    Logger::log_info "Configuring zsh"
    ./configure --prefix="${INSTALL_DIR}" --with-tcsetpgrp > /dev/null 2>&1
    Logger::log_info "Compiling zsh"
    make > /dev/null 2>&1
    Logger::log_info "Installing zsh"
    make install > /dev/null 2>&1

    # Set $HOME/.local/bin in PATH:
    if ! echo "${PATH}" | grep -q "${HOME}/.local/bin"; then
        # shellcheck disable=SC2016
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "${HOME}/.bashrc"
        export PATH="${HOME}/.local/bin:${PATH}"
        source "${HOME}"/.bashrc
    fi

    # Install oh-my-zsh
    export RUNZSH=no
    export ZSH="${HOME}/.oh-my-zsh"
    export CHSH=no
    export KEEP_ZSHRC=yes
    export PATH="${HOME}/.local/bin:${PATH}"

    if [[ ! -d "${ZSH}" ]]; then
        Logger::log_info "Installing oh-my-zsh"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        Logger::log_warning "Oh-my-zsh already exists at ${ZSH}"
    fi

    Logger::log_info "Finished installing zsh and oh-my-zsh"
}

Zsh::install_plugins()
{
    Logger::log_info "Installing oh-my-zsh plugins"

    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-syntax-highlighting > /dev/null 2>&1
    git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-autosuggestions > /dev/null 2>&1
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/you-should-use > /dev/null 2>&1
    git clone https://github.com/zsh-users/zsh-history-substring-search "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}"/plugins/zsh-history-substring-search > /dev/null 2>&1

    if grep -q '^plugins=(git)' "${HOME}"/.zshrc; then
        sed -i 's/^plugins=(git).*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting you-should-use zsh-history-substring-search)/g' "${HOME}"/.zshrc
    fi

    Logger::log_info "Finished installing oh-my-zsh plugins"
}

Zsh::install_fonts()
{
    # Install fonts:
    Logger::log_info "Installing Nerd Fonts and PowerLine fonts"
    FONT_DIR="${HOME}/.fonts"
    FONT_NAME="UbuntuMono"
    FONT_VERSION="3.4.0"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v${FONT_VERSION}/${FONT_NAME}.tar.xz"

    Utils::create_dir_if_not_exists "${FONT_DIR}"
    cd "${SRC_DIR}" || exit

    if [[ ! -f "${FONT_NAME}.tar.xz" ]]; then
        Logger::log_info "Downloading Nerd Font: ${FONT_NAME} (tar.xz)"
        curl -fLo "${FONT_NAME}.tar.xz" "${FONT_URL}"
    else
        Logger::log_warning "Nerd Font archive already exists"
    fi

    Logger::log_info "Extracting fonts to ${FONT_DIR}"
    tar -xf "${FONT_NAME}.tar.xz" -C "${FONT_DIR}"

    # Refresh fonts
    if command -v fc-cache >/dev/null 2>&1; then
        Logger::log_info "Updating font cache"
        fc-cache -fv "${FONT_DIR}" > /dev/null 2>&1
    else
        Logger::log_warning "Font cache tool not found. Fonts installed, but you may need to reload fonts manually"
    fi

    Logger::log_info "Installing PowerLine fonts"
    git clone --depth 1 "https://github.com/powerline/fonts" "pl-fonts" > /dev/null 2>&1
    cd "pl-fonts" || exit
    /bin/bash ./install.sh > /dev/null 2>&1

    Logger::log_info "Finished installing fonts"
}

Zsh::install_theme()
{
    # Install powerlevel10k theme:
    Logger::log_info "Installing Powerlevel10k theme for oh-my-zsh"
    rm -f "${HOME}/.p10k.zsh"
    mkdir -p "${HOME}/.oh-my-zsh/custom/themes/power"
    git clone --depth=1 "https://github.com/romkatv/powerlevel10k.git" "${HOME}/.oh-my-zsh/custom/themes/powerlevel10k" > /dev/null 2>&1

    if grep -q '^ZSH_THEME=' "${HOME}"/.zshrc; then
        sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' "${HOME}"/.zshrc
    else
        echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> "${HOME}"/.zshrc
    fi

    if ! grep -q "source \$ZSH/oh-my-zsh.sh" "${HOME}"/.zshrc; then
        # shellcheck disable=SC2129
        # shellcheck disable=SC2140
        echo "export ZSH=""${HOME}"/.oh-my-zsh"" >> "${HOME}"/.zshrc
        echo "plugins=()" >> "${HOME}"/.zshrc
        echo "source ${ZSH}/oh-my-zsh.sh" >> "${HOME}"/.zshrc
    fi

    PRECONFIGURED_P10K="${PRECONFIGURED_DIR}/.p10k.zsh"
    if [[ -f "${PRECONFIGURED_P10K}" ]]; then
        Logger::log_info "Copying preconfigured .p10k.zsh to ${HOME}"
        cp "${PRECONFIGURED_P10K}" "${HOME}/.p10k.zsh"
    else
        Logger::log_warning "No preconfigured .p10k.zsh found in preconfigured directory"
    fi

    # shellcheck disable=SC2016
    echo '# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi' | cat - "${HOME}/.zshrc"> temp && mv temp "${HOME}/.zshrc"

echo "# To customize prompt, run p10k configure or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh" >> "${HOME}/.zshrc"

    Logger::log_info "Finished installing theme for oh-my-zsh"
}

Zsh::set_aliases()
{
    Logger::log_info "Setting up aliases for zsh >> ${HOME}/.zshrc"
    # TODO: Add more aliases
    # 8: set aliases:
    if ! grep -q 'alias gs=' "${HOME}"/.zshrc; then
        echo 'alias gs="git status"' >> "${HOME}"/.zshrc
    fi
    source "${HOME}/.bashrc"

    Logger::log_info "Finished setting up aliases for zsh"
}

Zsh::verify_installation()
{
    # Check if zsh is installed
    if [[ -x "${INSTALL_DIR}/bin/zsh" ]]; then
        Logger::log_info "✔ Zsh installed successfully at ${INSTALL_DIR}/bin/zsh"
        echo -e "\033[0;32mℹ️ Font  '${FONT_NAME}' installed. Please set it in your terminal preferences.\033[0m"
        echo -e "\033[0;32mℹ️ Run \"p10k configure\" to run prompt configurator \033[0m"
        echo -e "\033[0;32m✔ Please restart your terminal\033[0m"
    else
        echo "❌ Zsh installation failed or zsh not found at ${INSTALL_DIR}/bin/zsh"
        Logger::log_error "Zsh installation failed or zsh not found at ${INSTALL_DIR}/bin/zsh"
    fi
}

Zsh::set_as_default_shell()
{
    # Set zsh as default:

    # TODO: Implement a way to set ZSH as default shell
    # if ! grep -q "$ZSH_BIN" "$HOME/.bashrc"; then
    #     {
    #         echo "
    # # Start zsh if available
    # if [ -x \"$ZSH_BIN\" ] && [ \"\$SHELL\" != \"$ZSH_BIN\" ]; then
    #     #export SHELL=\"$HOME/.local/bin/zsh\"
    #     exec \"$ZSH_BIN\"
    # fi" >> "$HOME/.bashrc"
    #     } >> "$HOME/.bashrc"
    # fi
    Logger::log_warning "Setting zsh as default shell - no implementation yet"
}

Zsh::clean_up()
{
    Logger::log_info "Cleaning up temporary files"
    rm -rf "${SRC_DIR}/zsh-${ZSH_VERSION}" "${SRC_DIR}/zsh-${ZSH_VERSION}.tar.xz" "${SRC_DIR}/pl-fonts"
}

Utils::create_dir_if_not_exists() 
{
    if [[ ! -d "$1" ]]; then
        Logger::log_info "Creating directory: $1"
        mkdir -p "$1"
    else
        Logger::log_warning "Directory already exists: $1"
    fi
}

Logger::log_info "Starting Zsh installation script"
INSTALL_DIR="${HOME}/.local"
SRC_DIR="${HOME}/src"
ZSH_VERSION="$(Zsh::get_latest_available_zsh_version)"
Logger::log_info "Latest Zsh version: ${ZSH_VERSION}"

Utils::create_dir_if_not_exists "${INSTALL_DIR}"
Utils::create_dir_if_not_exists "${SRC_DIR}"

Zsh::install
Zsh::install_plugins
Zsh::install_fonts
Zsh::install_theme
Zsh::set_aliases
Zsh::verify_installation
