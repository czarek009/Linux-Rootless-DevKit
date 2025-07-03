#!/usr/bin/env bash

ENV_PATHS_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/env_variables.sh"
source "${ENV_PATHS_LIB}"
SHELLRC_PATH="$HOME/.bashrc"
LOGGER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../logger" && pwd)/script_logger.sh"
source "${LOGGER_PATH}"

Omb::uninstall()
{
  for file in "${HOME}"/.project-backup/.bashrc.omb-backup*; do
    if [[ -f "$file" ]]; then
      EnvConfigurator::copy_file_if_exists "$file" "${HOME}/$(basename "$file")" "y"
    fi
  done

  "${HOME}"/.oh-my-bash/tools/uninstall.sh <<< "Y"
}

Omb::verify_uninstallation()
{
  if [ -d "$HOME/.oh-my-bash" ]; then
    Logger::log_error "Oh My Bash directory still can be found at ${HOME}/.oh-my-bash"
  else
    Logger::log_info "✔ Oh My Bash removed successfully"
  fi

  BACKUP_FILE=$(find "${BACKUP_PATH}" -maxdepth 1 -type f -name ".bashrc.omb-backup-*" -printf "%T@ %p\n" 2>/dev/null | sort -nr | cut -d' ' -f2- | head -n 1)

  if ! cmp -s "${SHELLRC_PATH}" "${BACKUP_FILE}"
  then
    Logger::log_error ".bashrc not restored"
  else
    Logger::log_info "✔ .bashrc restored successfully"
  fi
}