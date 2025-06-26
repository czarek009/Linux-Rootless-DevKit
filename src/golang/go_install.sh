#!/usr/bin/env bash

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
	local profile_file="${HOME}/.bashrc.user"

	echo "Installing Go to ${goroot}..."
	mkdir -p "${install_dir}"
	tar -C "${install_dir}" -xzf "${go_tarball}" || { echo "Extraction failed"; exit 1;}
	rm "${go_tarball}"

	echo "Updating ${profile_file}..."
	{
		echo ""
		echo "# Go environment setup"
		echo "unset -f go 2> /dev/null"
		echo "export GOROOT=\"${goroot}\""
		echo "export GOPATH=\"${gopath}\""
		echo "export PATH=\"\$GOROOT/bin:\$GOPATH/bin:\$PATH\""
	} >> "${profile_file}"

	mkdir -p "${gopath}/bin"
	echo "Go ${go_version} installed successfully."
	echo "Restart terminal or run: source ${profile_file}"
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
