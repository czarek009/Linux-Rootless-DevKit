#!/bin/bash
 
# Quiet custom install of Rust using rustup with specific options
 
 
# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
 
# Set environment variables to avoid path check warning
export RUSTUP_INIT_SKIP_PATH_CHECK=yes
 
# Download rustup-init
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup-init.sh
 
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ ${NC}Failed to download rustup-init."
    exit 1
fi
 
chmod +x rustup-init.sh
 
# Run rustup-init in quiet mode with custom options
./rustup-init.sh -y \
    --default-toolchain stable \
    --profile default \
    --no-modify-path > /dev/null 2>&1
 
INSTALL_STATUS=$?
 
# Clean up installer
rm -f rustup-init.sh
 
# Add cargo to PATH in .bashrc if not already present
BASHRC="$HOME/.bashrc"
CARGO_LINE='export PATH="$HOME/.cargo/bin:$PATH"'
 
if [ $INSTALL_STATUS -eq 0 ]; then
    if [ -w "$BASHRC" ]; then
        if ! grep -Fxq "$CARGO_LINE" "$BASHRC"; then
            echo "$CARGO_LINE" >> "$BASHRC"
        fi
        echo -e "${GREEN}✔ ${NC}Rust was successfully installed to \$HOME/.cargo/bin"
        echo -e "${BLUE}ℹ️  ${NC}Cargo path added to $BASHRC"
    else
        echo -e "${GREEN}✔ ${NC}Rust was successfully installed to \$HOME/.cargo/bin"
        echo -e "${YELLOW}⚠️  ${NC}Could not write to $BASHRC. Please add this line manually:"
        echo "$CARGO_LINE"
    fi
else
    echo -e "${RED}❌ ${NC}Rust installation failed."
    exit $INSTALL_STATUS
fi
