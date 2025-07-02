#!/bin/bash

# Script to install MkDocs and required plugins
LOGGER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../logger" && pwd)/script_logger.sh"
source "$LOGGER_PATH"

set -euo pipefail

echo "Starting MkDocs installation..."

# Check for Python 3
if ! command -v python3 &>/dev/null; then
    Logger::log_info "Python 3 is not installed. Please install Python 3 first."
    exit 1
fi

if ! command -v pip3 &>/dev/null; then
    Logger::log_info "pip not found. Attempting to install pip..."
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3
fi

# Check for pipx
if ! command -v pipx &>/dev/null; then
    Logger::log_info "pipx not found. Installing pipx..."
    python3 -m pip install --user pipx
    python3 -m pipx ensurepath
    export PATH="$HOME/.local/bin:$PATH"
fi
Logger::log_info "Installing MkDocs and plugins to user environment..."

# Upgrade pipx
pipx upgrade pipx

# Install MkDocs and plugins in an isolated pipx environment
pipx install mkdocs
pipx inject mkdocs mkdocs-material
pipx inject mkdocs mkdocs-git-revision-date-localized-plugin
pipx inject mkdocs mkdocs-git-authors-plugin
pipx inject mkdocs mkdocs-literate-nav
pipx inject mkdocs mkdocs-d2-plugin
pipx inject mkdocs pymdown-extensions

# Install d2 binary (if not already installed)
if ! command -v d2 &>/dev/null; then
    echo "Installing d2 CLI tool..."
    curl -fsSL https://d2lang.com/install.sh | sh
else
    echo "d2 is already installed."
fi

Logger::log_info "MkDocs and plugins installed to your user environment (~/.local)."
Logger::log_info "You can now run 'mkdocs serve' inside your project directory."
