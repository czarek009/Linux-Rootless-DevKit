#!/usr/bin/env bash
set -e

# Global variables defining important paths used throughout the entire project
SHELLRC_PATH="${HOME}/.bashrc.user"
BACKUP_PATH="${HOME}/.project-backup"
LOGGER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/logger" && pwd)/script_logger.sh"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_TOP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

export SHELLRC_PATH
export BACKUP_PATH
export LOGGER_PATH
export SCRIPT_DIR
export PROJECT_TOP_DIR
