#!/usr/bin/env bash

ENV_PATHS_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/env_variables.sh"
source "${ENV_PATHS_LIB}"
ENV_CONFIGURATOR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../envConfigurator" && pwd)/envConfigurator.sh"
source "${ENV_CONFIGURATOR_PATH}"
LOGGER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../logger" && pwd)/script_logger.sh"
source "$LOGGER_PATH"

Go::remove_dirs() {
    Logger::log_info "Removing Go directories"
    EnvConfigurator::remove_dir_if_exists "${HOME}/.local/go" "y"
    EnvConfigurator::remove_dir_if_exists "${HOME}/go" "y"
}

# shellcheck disable=SC2016
Go::clean_bashrc() {
	local profile_file="${SHELLRC_PATH}"
	EnvConfigurator::_remove "${profile_file}" \
"
# Go environment setup
unset -f go 2> /dev/null
export GOROOT=\"${HOME}/.local/go\"
export GOPATH=\"${HOME}/go\"
export PATH=\"\$GOROOT/bin:\$GOPATH/bin:\$PATH\""
    Logger::log_info "Go environment lines removed from ${profile_file}"
}
