#!/usr/bin/env bash

ENV_PATHS_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/env_variables.sh"
source "${ENV_PATHS_LIB}"
LOGGER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../logger" && pwd)/script_logger.sh"
source "$LOGGER_PATH"
ENV_CONFIGURATOR_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../envConfigurator" && pwd)/envConfigurator.sh"
source "${ENV_CONFIGURATOR_PATH}"

Omb::install()
{
  #TODO: customizable directory localization
  EnvConfigurator::create_dir_if_not_exists "${BACKUP_PATH}"

  bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"

  for file in "${HOME}"/.bashrc.omb-backup*; do
    if [[ -f "$file" ]]; then
        EnvConfigurator::move_file_if_exists "$file" "${BACKUP_PATH}/$(basename "$file")" "y"
    fi
  done
}

Omb::verify_installation()
{
  if [ ! -d "${HOME}/.oh-my-bash" ]; then
    Logger::log_error "Oh My Bash installation failed or .oh-my-bash directory not found at ${HOME}/.oh-my-bash"
  else
    Logger::log_info "✔ Oh My Bash installed successfully at ${HOME}/.oh-my-bash"
  fi

  BACKUP_FILE=$(find "${BACKUP_PATH}" -maxdepth 1 -type f -name ".bashrc.omb-backup-*" -printf "%T@ %p\n" 2>/dev/null | sort -nr | cut -d' ' -f2- | head -n 1)

  if [ ! -f "${BACKUP_FILE}" ]; then
    Logger::log_error ".bashrc backup not found at ${BACKUP_FILE}"
  else
    Logger::log_info "✔ .bashrc backup found at ${BACKUP_FILE}"
  fi

  # TODO: Check if current .bashrc contains OMB lines to be sure it was replaced
}