#!/usr/bin/env bash

ENV_PATHS_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/env_variables.sh"
source "${ENV_PATHS_LIB}"
ENV_CONFIGURATOR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../envConfigurator" && pwd)/envConfigurator.sh"
source "${ENV_CONFIGURATOR_PATH}"

GO::remove_dirs() {
	echo "Removing Go directories"
	local goroot="${HOME}/.local/go"
	local gopath="${HOME}/go"
	rm -rf "${goroot}" "${gopath}"
}

# shellcheck disable=SC2016
GO::clean_bashrc() {
	local profile_file="${SHELLRC_PATH}"
	EnvConfigurator::_remove "${profile_file}" \
"
# Go environment setup
unset -f go 2> /dev/null
export GOROOT=\"${HOME}/.local/go\"
export GOPATH=\"${HOME}/go\"
export PATH=\"\$GOROOT/bin:\$GOPATH/bin:\$PATH\""
    echo "Go environment lines removed from ${profile_file}"
}

GO::uninstall::main() {
	GO::remove_dirs
	GO::clean_bashrc	
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	GO::uninstall::main
fi
