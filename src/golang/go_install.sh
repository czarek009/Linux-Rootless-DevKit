#!/usr/bin/env bash

ENV_PATHS_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/env_variables.sh"
source "${ENV_PATHS_LIB}"
ENV_CONFIGURATOR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../envConfigurator" && pwd)/envConfigurator.sh"
source "${ENV_CONFIGURATOR_PATH}"

download() {
	local go_version="${1}"
	local go_tarball="go${go_version}.linux-amd64.tar.gz"

	echo "Downloading Go ${go_version}..."
	curl -LO "https://go.dev/dl/${go_tarball}" || { echo "Download failed"; exit 1;}
}

install() {
	local go_version="${1}"
	local go_tarball="go${go_version}.linux-amd64.tar.gz"
	local install_dir="${HOME}/.local"
	local goroot="${install_dir}/go"
	local gopath="${HOME}/go"
	local profile_file="${SHELLRC_PATH}"

	echo "Installing Go to ${goroot}..."
	EnvConfigurator::create_dir_if_not_exists "${install_dir}"
	tar -C "${install_dir}" -xzf "${go_tarball}" || { echo "Extraction failed"; exit 1;}
	rm "${go_tarball}"

	EnvConfigurator::_write_if_not_present "${profile_file}" \
"
# Go environment setup
unset -f go 2> /dev/null
export GOROOT=\"${goroot}\"
export GOPATH=\"${gopath}\"
export PATH=\"\$GOROOT/bin:\$GOPATH/bin:\$PATH\""

	EnvConfigurator::create_dir_if_not_exists "${gopath}/bin"
	# Source the profile file to update env vars
	echo "Sourcing ${profile_file}..."
	source "${profile_file}"

	# Check if Go is correctly installed
	if command -v go &>/dev/null; then
    		echo "Go installed successfully:"
    		go version
    		echo "You can now use Go. Run 'source ${profile_file}' or restart terminal if needed."
	else
    		echo "Go installation failed or PATH not updated. Please check ${profile_file} or restart your terminal."
    		exit 1
	fi
}

main() {
	local version="$1"
	download "${version}"
	install "${version}"
}

# Run main only if script is executed directly
# Usage : ./golang/go_install.sh <go_version> (default 1.24.3)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	if [[ $# -lt 1 ]]; then
		main "1.24.3"
		exit 0
	fi
	main "$@"
fi
