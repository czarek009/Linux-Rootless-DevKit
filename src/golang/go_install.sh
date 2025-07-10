#!/usr/bin/env bash

ENV_PATHS_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/env_variables.sh"
source "${ENV_PATHS_LIB}"
ENV_CONFIGURATOR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../envConfigurator" && pwd)/envConfigurator.sh"
source "${ENV_CONFIGURATOR_PATH}"
LOGGER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../logger" && pwd)/script_logger.sh"
source "$LOGGER_PATH"

Go::download() {
	local go_version="${1}"
	local go_tarball="go${go_version}.linux-amd64.tar.gz"

	Logger::log_info "Downloading Go ${go_version}..."
	curl -LO "https://go.dev/dl/${go_tarball}" || { echo "Download failed"; exit 1;}
}

Go::install() {
    local go_version="${1}"
    local go_tarball="go${go_version}.linux-amd64.tar.gz"
    local install_dir="${HOME}/.local"
    local goroot="${install_dir}/go"
    local gopath="${HOME}/go"
    local profile_file="${SHELLRC_PATH}"

    Logger::log_info "Installing Go to ${goroot}..."
    EnvConfigurator::create_dir_if_not_exists "${install_dir}"
    tar -C "${install_dir}" -xzf "${go_tarball}" || { echo "Extraction failed"; exit 1;}
    EnvConfigurator::remove_file_if_exists "${go_tarball}"
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
        Logger::log_success "Go installed successfully:"
        go version
        Logger::log_info "You can now use Go. Run 'source ${profile_file}' or restart terminal if needed."
    else
        Logger::log_error "Go installation failed or PATH not updated. Please check ${profile_file} or restart your terminal."
        exit 1
    fi
}

