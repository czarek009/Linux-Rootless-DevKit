#!/bin/bash

# Script to install MkDocs and required plugins
LOGGER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../logger" && pwd)/script_logger.sh"
source "$LOGGER_PATH"

set -e
if ! command -v python3 &>/dev/null; then
    Logger::log_info "Python 3 is not installed. Please install Python 3 first."
    exit 1
fi
if ! command -v pip3 &>/dev/null; then
    Logger::log_info "pip not found. Attempting to install pip..."
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3
fi
pip3 install --user --upgrade pip

Logger::log_info "Installing MkDocs and plugins to user environment..."

pip install --user --upgrade pip

pip install --user \
    mkdocs \
    mkdocs-material \
    mkdocs-git-revision-date-localized-plugin \
    mkdocs-git-authors-plugin \
    mkdocs-literate-nav \
    mkdocs-d2-plugin \
    pymdown-extensions
# Install d2
curl -fsSL https://d2lang.com/install.sh | sh


echo
Logger::log_info "MkDocs and plugins installed to your user environment (~/.local)."
Logger::log_info "You can now run 'mkdocs serve' inside your project directory."
