#!/bin/bash
 
# Rust uninstall script for rustup-based installs
 
# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
 
# Paths to remove
CARGO_DIR="$HOME/.cargo"
RUSTUP_DIR="$HOME/.rustup"
BASHRC="$HOME/.bashrc"
CARGO_PATH_LINE='export PATH="$HOME/.cargo/bin:$PATH"'
 
echo "Starting Rust uninstallation..."
 
# Remove installed files
rm -rf "$CARGO_DIR" "$RUSTUP_DIR"
 
# Remove PATH export from .bashrc if present
if [ -w "$BASHRC" ]; then
    if grep -Fxq "$CARGO_PATH_LINE" "$BASHRC"; then
        grep -Fxv "$CARGO_PATH_LINE" "$BASHRC" > "$BASHRC.tmp" && mv "$BASHRC.tmp" "$BASHRC"
        echo "Removed Cargo PATH line from $BASHRC"
    fi
else
    echo -e "${YELLOW}⚠️  ${NC}Could not modify $BASHRC (no write permission)."
fi
 
# Confirm removal
if [ ! -d "$CARGO_DIR" ] && [ ! -d "$RUSTUP_DIR" ]; then
    echo -e "${GREEN}✔ ${NC}Rust and related directories have been successfully removed."
else
    echo -e "${RED}❌ ${NC}Some Rust directories could not be removed."
fi
 
