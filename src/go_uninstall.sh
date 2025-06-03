#!/bin/bash

remove_dirs() {
	echo "Removing Go directories"
	local goroot="$HOME/.local/go"
	local gopath="$HOME/go"
	rm -rf "$goroot" "$gopath"
}

clean_bashrc() {
	local profile_file="$HOME/.bashrc.user"
	sed -i '/^# Go environment setup$/d' "$profile_file"
	sed -i '/^unset -f go 2> \/dev\/null$/d ' "$profile_file"
  sed -i "/^export GOROOT=\"$(echo "$HOME" | sed 's_/_\\/_g')\/.local\/go\"$/d" "$profile_file"
  sed -i "/^export GOPATH=\"$(echo "$HOME" | sed 's_/_\\/_g')\/go\"$/d" "$profile_file"
	sed -i '/^export PATH="\$GOROOT\/bin:\$GOPATH\/bin:\$PATH"$/d' -i "$profile_file"

	echo "Go environment lines removed from $profile_file."
}

main() {
	remove_dirs
	clean_bashrc	
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	main
fi
