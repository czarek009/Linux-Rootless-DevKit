#!/usr/bin/env bash
# shellcheck disable=SC2312

# This script must install zsh + oh-my-zsh + fonts + power10k
# without sudo access

# Exit if non-zero status:
set -e
# Show executed commanmds:
#set -x

LOGGER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../logger" && pwd)/script_logger.sh"
ENV_CONFIGURATOR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../envConfigurator" && pwd)/envConfigurator.sh"
PRECONFIGURED_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/preconfigured" && pwd)"
source "${LOGGER_PATH}"
source "${ENV_CONFIGURATOR_PATH}"

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
    Logger::log_info "Compiling zsh - this may take a while"
    make > /dev/null 2>&1
    Logger::log_info "Installing zsh"
    make install > /dev/null 2>&1

    if [[ ! -f "${HOME}/.zshrc" ]]; then
        Logger::log_info "${HOME}/.zshrc does not exists - creating a new one"
        touch "${HOME}/.zshrc"
    else
        Logger::log_info "${HOME}/.zshrc already exists - backing it up as .zshrc.old"
        mv "${HOME}/.zshrc" "${HOME}/.zshrc.old"
    fi

    # Set $HOME/.local/bin in PATH:
    if ! echo "${PATH}" | grep -q "${HOME}/.local/bin"; then
        # shellcheck disable=SC2016
        EnvConfigurator::_write_if_not_present "${HOME}/.zshrc" 'export PATH="$HOME/.local/bin:$PATH"'
        export PATH="${HOME}/.local/bin:${PATH}"
        source "${HOME}"/.zshrc
    fi

    # Install oh-my-zsh
    export RUNZSH=no
    export ZSH="${HOME}/.oh-my-zsh"
    export CHSH=no
    export KEEP_ZSHRC=no
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

    EnvConfigurator::git_clone_if_not_exists https://github.com/zsh-users/zsh-syntax-highlighting.git "$HOME/.oh-my-zsh/custom/plugins"
    EnvConfigurator::git_clone_if_not_exists https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins"
    EnvConfigurator::git_clone_if_not_exists https://github.com/MichaelAquilina/zsh-you-should-use.git "$HOME/.oh-my-zsh/custom/plugins"
    EnvConfigurator::git_clone_if_not_exists https://github.com/zsh-users/zsh-history-substring-search "$HOME/.oh-my-zsh/custom/plugins"

    EnvConfigurator::_replace "${HOME}/.zshrc" '^plugins=(git)' 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-you-should-use zsh-history-substring-search)'
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

    EnvConfigurator::create_dir_if_not_exists "${FONT_DIR}"
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
    EnvConfigurator::git_clone_if_not_exists "https://github.com/powerline/fonts" "pl-fonts" > /dev/null 2>&1

    cd "pl-fonts/fonts" || exit
    ./install.sh > /dev/null 2>&1

    Logger::log_info "Finished installing fonts"
}

Zsh::install_theme()
{
    # Install powerlevel10k theme:
    Logger::log_info "Installing Powerlevel10k theme for oh-my-zsh"
    rm -f "${HOME}/.p10k.zsh"

    EnvConfigurator::git_clone_if_not_exists "https://github.com/romkatv/powerlevel10k.git" "${HOME}/.oh-my-zsh/custom/themes" > /dev/null 2>&1
    if EnvConfigurator::_exists "${HOME}/.zshrc" "ZSH_THEME" >/dev/null;then
        EnvConfigurator::_regex "${HOME}/.zshrc" '^ZSH_THEME=.*' 'ZSH_THEME="powerlevel10k/powerlevel10k"'
    else
        EnvConfigurator::_write "${HOME}/.zshrc" 'ZSH_THEME="powerlevel10k/powerlevel10k"'
    fi

    if ! EnvConfigurator::_exists "${HOME}/.zshrc" "source \$ZSH/oh-my-zsh.sh" >/dev/null; then
        EnvConfigurator::_write "${HOME}/.zshrc" "export ZSH=${HOME}/.oh-my-zsh"
        EnvConfigurator::_write "${HOME}/.zshrc" "source ${ZSH}/oh-my-zsh.sh"
    fi

    PRECONFIGURED_P10K="${PRECONFIGURED_DIR}/.p10k.zsh"
    if [[ -f "${PRECONFIGURED_P10K}" ]]; then
        Logger::log_info "Copying preconfigured .p10k.zsh to ${HOME}"
        cp "${PRECONFIGURED_P10K}" "${HOME}/.p10k.zsh"
    else
        Logger::log_warning "No preconfigured .p10k.zsh found in preconfigured directory"
    fi

    # shellcheck disable=SC2016
    EnvConfigurator::_insert "${HOME}/.zshrc" \
    '# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi' 1

    EnvConfigurator::_write_if_not_present "${HOME}/.zshrc" \
    "# To customize prompt, run p10k configure or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh"

    Logger::log_info "Finished installing theme for oh-my-zsh"
}

Zsh::set_aliases()
{
    Logger::log_info "Setting up aliases for zsh >> ${HOME}/.zshrc"
    # TODO: Add more aliases
    # 8: set aliases:
    EnvConfigurator::_write_if_not_present "${HOME}/.zshrc" "alias gs='git status'"
    if ! EnvConfigurator::_exists "${HOME}/.zshrc" "alias gs=" >/dev/null; then
        EnvConfigurator::_write "${HOME}/.zshrc" 'alias gs="git status"'
    fi

    Logger::log_info "Finished setting up aliases for zsh"
}

Zsh::verify_installation()
{
    # Check if zsh is installed
    if [[ -x "${INSTALL_DIR}/bin/zsh" ]]; then
        Logger::log_success "Zsh installed successfully at ${INSTALL_DIR}/bin/zsh"
        Logger::log_userAction "Font  '${FONT_NAME}' installed. Please set it in your terminal preferences"
        Logger::log_userAction "Run \"p10k configure\" to run prompt configurator"
        Logger::log_userAction "Please restart your terminal"
    else
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

Zsh::configure()
{
    Logger::log_info "Configuring zshrc"
    EnvConfigurator::_write_if_not_present "${HOME}/.zshrc" "export OSTYPE=linux"
}

Zsh::clean_up()
{
    Logger::log_info "Cleaning up temporary files"
    rm -rf "${SRC_DIR}/zsh-${ZSH_VERSION}" "${SRC_DIR}/zsh-${ZSH_VERSION}.tar.xz" "${SRC_DIR}/pl-fonts"
}

Logger::log_info "Starting Zsh installation script"
INSTALL_DIR="${HOME}/.local"
SRC_DIR="${HOME}/src"
ZSH_VERSION="$(Zsh::get_latest_available_zsh_version)"
Logger::log_info "Latest Zsh version: ${ZSH_VERSION}"

EnvConfigurator::create_dir_if_not_exists "${INSTALL_DIR}" > /dev/null
EnvConfigurator::create_dir_if_not_exists "${SRC_DIR}" > /dev/null

Zsh::install
Zsh::install_plugins
Zsh::install_fonts
Zsh::install_theme
Zsh::configure
Zsh::set_aliases
Zsh::verify_installation
