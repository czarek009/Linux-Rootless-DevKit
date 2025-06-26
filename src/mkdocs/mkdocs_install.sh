#!/bin/bash

# Script to install MkDocs and required plugins

set -e
if ! command -v python3 &>/dev/null; then
    echo "Python 3 is not installed. Please install Python 3 first."
    exit 1
fi
if ! command -v pip3 &>/dev/null; then
    echo "pip not found. Attempting to install pip..."
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3 --user
fi
pip3 install --user --upgrade pip

echo "Installing MkDocs and plugins to user environment..."

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
echo "MkDocs and plugins installed to your user environment (~/.local)."
echo "You can now run 'mkdocs serve' inside your project directory."
