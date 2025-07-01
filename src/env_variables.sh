#!/usr/bin/env bash
set -e

# GLOBAL PATHS FOR ENTIRE PROJECT
# Parameter for setting shell config file that will be used by a user (bashrc/zshrc)
# TODO: Needs to be modifiable by the initial script configuration.
SHELLRC_PATH="${HOME}/.bashrc.user"
BACKUP_PATH="${HOME}/.project-backup"
LOGGER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/logger" && pwd)/script_logger.sh"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_TOP_DIR="${SCRIPT_DIR}"

export SHELLRC_PATH
export BACKUP_PATH
export LOGGER_PATH
export SCRIPT_DIR
export PROJECT_TOP_DIR
