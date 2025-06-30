#!/usr/bin/env bash
# TODO: Consider moving logs into some persistent directory when the release comes in:
LOG_DIR="$( cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit 1; pwd -P )/logs"

# Utils functions:
Utils::check_file_contains_string() 
{
    local file="$1"
    local string="$2"
    Logger::_log "STRF" "Checking if file '${file}' contains string '${string}'..."

    if [[ -f "${file}" ]]; then
        if grep -q "${string}" "${file}" &> /dev/null; then
            Logger::_log "STRF" "File '${file}' contains string '${string}'."
            return 0
        else
            Logger::_log "STRF" "File '${file}' does not contain string '${string}'."
            return 1
        fi
    else
        Logger::_log "STRF" "File '${file}' does not exist."
        return 1
    fi
}

Utils::check_file_exists()
{
    local file="$1"
    Logger::_log "FILE" "Checking if file '${file}' exists..."

    if [[ -f "${file}" ]]; then
        Logger::_log "FILE" "File '${file}' exists."
        return 0
    else
        Logger::_log "FILE" "File '${file}' does not exist."
        return 1
    fi
}

# Environment functions (.<confgig>rc / commands):
Env::check_bashrc_contains_string() 
{
    local file="${HOME}/.bashrc"
    local string="$2"
    Logger::_log "STRF" "Checking if file '${file}' contains string '${string}'..."

    if [[ -f "${file}" ]]; then
        if grep -q "${string}" "${file}" &> /dev/null; then
            Logger::_log "STRF" "File '${file}' contains string '${string}'."
            return 0
        else
            Logger::_log "STRF" "File '${file}' does not contain string '${string}'."
            return 1
        fi
    else
        Logger::_log "STRF" "File '${file}' does not exist."
        return 1
    fi
}

Env::check_command_exists()
{
    local command="$1"
    Logger::_log "CMD" "Checking if command '${command}' exists..."

    if command -v "${command}" &> /dev/null; then
        Logger::_log "CMD" "Command '${command}' exists."
        return 0
    else
        Logger::_log "CMD" "Command '${command}' does not exist."
        return 1
    fi
}

# Logger functions:
# Added a separte log() for caller function to work properly for 1 index
Logger::_log()
{
    local log_level="$1"
    local log_message="$2"
    local timestamp
    timestamp=$(date +"%H:%M:%S")
    local caller
    caller=$(caller 1)
    local file_name=${caller##*/}
    local line_number=${caller%% *}

    if [[ ! -f "${LOG_FILE}" ]]; then
        mkdir -p "$(dirname "${LOG_FILE}")"
        touch "${LOG_FILE}"
    fi

    echo "[${timestamp}] [${log_level}] [${file_name}:${line_number}]: ${log_message}" >> "${LOG_FILE}"

    if [[ "${log_level}" == "ERROR" ||
          "${log_level}" == "WARN" ||
          "${log_level}" == "INFO" ||
          "${log_level}" == "SUCCESS" ||
          "${log_level}" == "USER ACTION" ||
          ("${log_level}" == "DEBUG" && "$LOGGER_DEBUG_PRINT" -eq "1") ]]; then
        local color_reset="\033[0m"
        local color
        case "${log_level}" in
            "ERROR") color="\033[31m" ;; # Red
            "WARN")  color="\033[33m" ;; # Yellow
            "INFO")  color="\033[34m" ;; # Blue
            "DEBUG") color="\033[36m" ;; # Cyan
            "SUCCESS") color="\033[32m" ;; # Green
            "USER ACTION") color="\033[35m" ;; # Magenta
            *)       color="" ;;
        esac
        echo -e "[${timestamp}] [${color}${log_level}${color_reset}] [${file_name}:${line_number}]: ${log_message}" > "/dev/stderr"
    fi
}

Logger::log()
{
    Logger::_log "$1" "$2"
}

Logger::log_info()
{
    Logger::_log "INFO" "$1"
}

Logger::log_warning()
{
    Logger::_log "WARN" "$1"
}

Logger::log_error()
{
    Logger::_log "ERROR" "$1"
}

Logger::log_debug()
{
    Logger::_log "DEBUG" "$1"
}

Logger::log_success()
{
    Logger::_log "SUCCESS" "$1"
}

Logger::log_userAction()
{
    Logger::_log "USER ACTION" "$1"
}

# Telemetry functions and signal handlers:
Telemetry::prepare_report()
{
    Logger::log_info "NOT IMPLEMENTED"
    # TODO: Gather some additional system info / env variables / etc.
    # Add whole dir with log to archive, name archive
}

Telemetry::send_report()
{
    Logger::log_info "NOT IMPLEMENTED"
    # TODO: Send report somewhere
}

# Capture exit signals, call wait to ensure all child processes are finished
Trapper::handle_sigint()
{
    Logger::_log "USER" "Script interrupted by user."
    wait
    exit 0

}

Trapper::handle_sigterm()
{
    Logger::_log "USER" "Script interrupted by user."
    wait
    exit 0
}

Trapper::handle_exit()
{
    Logger::_log "USER" "Script interrupted by user."
    wait
    exit 0
}

Telemetry::setup_signal_handlers()
{
    trap 'Trapper::handle_sigint' SIGINT
    trap 'Trapper::handle_sigterm' SIGTERM
    trap 'Trapper::handle_exit' EXIT
}

# Helper functions:
get_log_filename() 
{
    if [[ -z "${LOGGER_MAIN_SCRIPT}" ]]; then
        LOGGER_MAIN_SCRIPT="$(basename "$0" .sh)"
        export LOGGER_MAIN_SCRIPT
    fi
    if [[ -z "${LOGGER_RUN_TIMESTAMP}" ]]; then
        LOGGER_RUN_TIMESTAMP="$(date +%Y-%m-%d_%H:%M:%S)"
    fi

    echo "${LOG_DIR}/${LOGGER_MAIN_SCRIPT}_${LOGGER_RUN_TIMESTAMP}.log"
}
LOG_FILE="$(get_log_filename)"
export LOG_FILE
