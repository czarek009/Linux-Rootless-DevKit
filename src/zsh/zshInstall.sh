#!/bin/bash

# This script must install zsh + oh-my-zsh + fonts + power10k
# without sudo access

# Exit if non-zero status:
#set -e
# Show executed commanmds:
#set -x

# Variables:
ZSH_VERSION="5.9"
INSTALL_DIR="$HOME/.local"
SRC_DIR="$HOME/src"

create_dir_if_not_exists() {
    if [ ! -d "$1" ]; then
        echo "ℹ️ Creating directory: $1"
        mkdir -p "$1"
    else
        echo "⚠️ Directory already exists: $1"
    fi
}

# Prepare dirs:
create_dir_if_not_exists "$INSTALL_DIR"
create_dir_if_not_exists "$SRC_DIR"

##### INSTALL:
# Download and compile zsh source
cd "$SRC_DIR" || exit
if [ ! -f "zsh-$ZSH_VERSION.tar.xz" ]; then
    echo "ℹ️ Downloading zsh $ZSH_VERSION source..."
    curl -LO "https://sourceforge.net/projects/zsh/files/zsh/$ZSH_VERSION/zsh-$ZSH_VERSION.tar.xz"
else
    echo "⚠️ Zsh archive already downloaded."
fi

if [ ! -d "zsh-$ZSH_VERSION" ]; then
    echo "ℹ️ Extracting zsh..."
    tar -xf "zsh-$ZSH_VERSION.tar.xz"
fi

cd "zsh-$ZSH_VERSION" || exit
echo "ℹ️ Configuring zsh..."
./configure --prefix="$INSTALL_DIR" --with-tcsetpgrp > /dev/null 2>&1
echo "ℹ️ Compiling zsh..."
make > /dev/null 2>&1
echo "ℹ️ Installing zsh..."
make install > /dev/null 2>&1

# Set $HOME/.local/bin in PATH:
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
    export PATH="$HOME/.local/bin:$PATH"
fi

source $HOME/.bashrc

# Set zsh as default:
ZSH_BIN="$INSTALL_DIR/bin/zsh"
if ! grep -q "$ZSH_BIN" "$HOME/.bashrc"; then
    {
        echo "
# Start zsh if available
if [ -x \"$ZSH_BIN\" ] && [ \"\$SHELL\" != \"$ZSH_BIN\" ]; then
    #export SHELL=\"$HOME/.local/bin/zsh\"
    exec \"$ZSH_BIN\"
fi" >> "$HOME/.bashrc"
    } >> "$HOME/.bashrc"
fi

source $HOME/.bashrc

# Install oh-my-zsh
export RUNZSH=no
export ZSH="$HOME/.oh-my-zsh"
export CHSH=no
export KEEP_ZSHRC=yes
export PATH="$HOME/.local/bin:$PATH"

if [ ! -d "$ZSH" ]; then
    echo "ℹ️Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "⚠️Oh-my-zsh already installed."
fi


# Install fonts:
FONT_DIR="$HOME/.fonts"
FONT_NAME="UbuntuMono"
FONT_VERSION="3.4.0"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v$FONT_VERSION/$FONT_NAME.tar.xz"

create_dir_if_not_exists "$FONT_DIR"
cd "$SRC_DIR" || exit

if [ ! -f "${FONT_NAME}.tar.xz" ]; then
    echo "ℹ️ Downloading Nerd Font: $FONT_NAME (tar.xz)..."
    curl -fLo "${FONT_NAME}.tar.xz" "$FONT_URL"
else
    echo "⚠️Nerd Font archive already exists."
fi

echo "ℹ️ Extracting fonts to $FONT_DIR..."
tar -xf "${FONT_NAME}.tar.xz" -C "$FONT_DIR"

# Refresh fonts
if command -v fc-cache >/dev/null 2>&1; then
    echo "ℹ️ Updating font cache..."
    fc-cache -fv "$FONT_DIR"
else
    echo "⚠️ Font cache tool not found. Fonts installed, but you may need to reload fonts manually."
fi

echo "ℹ️ Installing PowerLine fonts..."
git clone --depth 1 "https://github.com/powerline/fonts" "pl-fonts"
cd "pl-fonts" || exit
/bin/bash ./install.sh

##### OPTIONSALS:

# Install powerlevel10k theme:
rm -f "$HOME/.p10k.zsh"
mkdir -p "$HOME/.oh-my-zsh/custom/themes/power"
git clone --depth=1 "https://github.com/romkatv/powerlevel10k.git" "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

if grep -q '^ZSH_THEME=' $HOME/.zshrc; then
    sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' $HOME/.zshrc
else
    echo 'ZSH_THEME="powerlevel10k/powerlevel10k"' >> $HOME/.zshrc
fi

if ! grep -q "source \$ZSH/oh-my-zsh.sh" $HOME/.zshrc; then
    echo "export ZSH="$HOME/.oh-my-zsh"" >> $HOME/.zshrc
    echo "plugins=()" >> $HOME/.zshrc
    echo "source $ZSH/oh-my-zsh.sh" >> $HOME/.zshrc
fi

# 8: set aliases:
if ! grep -q 'alias gs=' $HOME/.zshrc; then
  echo 'alias gs="git status"' >> $HOME/.zshrc
fi

# 9: resource .bashrc
source "$HOME/.bashrc"

# Check if zsh is installed
if [ -x "$INSTALL_DIR/bin/zsh" ]; then
    echo -e "\033[0;32m✔ Zsh installed successfully at $INSTALL_DIR/bin/zsh\033[0m"
    echo -e "\033[0;32m✔ Please restart your terminal\033[0m"
    echo -e "\033[0;32mℹ️ Font '$FONT_NAME' installed. Please set it in your terminal preferences.\033[0m"
else
    echo "❌ Zsh installation failed or zsh not found at $INSTALL_DIR/bin/zsh"
fi