#!/usr/bin/env bash
LOGGER_DIR_PATH="$( cd -- "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 || exit ; pwd -P )"
source "${LOGGER_DIR_PATH}/script_logger.sh"

Logger::test()
{
    LOG_FILE="${LOGGER_DIR_PATH}/logs/test_logger_$(date +%Y-%m-%d_%H-%M-%S).log"
    export LOG_FILE
    
    Logger::log_info "Starting logger test..."
    Logger::log_warning "This is a warning message."
    Logger::log_error "This is an error message."
    Logger::log_debug "This is a debug message."
    Logger::log_success "This is a success message."
    Logger::log_userAction "This is a user action required message."
    Logger::log "CUSTOM" "This is a custom log message."
    Utils::check_file_contains_string "${LOG_FILE}" "Starting logger test"
    Utils::check_file_contains_string "${LOG_FILE}" "this string is NOT in the log file"
    Env::check_bashrc_contains_string "#"
    Utils::check_file_exists "${LOG_FILE}"
    Utils::check_file_exists "/${HOME}/this/file/does/not/exist"
    Env::check_command_exists "ls"
    Env::check_command_exists "thiscommanddoesnotexist"

    cat << EOF > /tmp/testTraps.sh
#!/usr/bin/env bash
SCRIPT_LOGGER_PATH="${LOGGER_DIR_PATH}/script_logger.sh"
source "\${SCRIPT_LOGGER_PATH}"
Telemetry::setup_signal_handlers
sleep 3 # emulate child process (curl / make / etc)
EOF

chmod +x /tmp/testTraps.sh
/tmp/testTraps.sh &

PID=$!

sleep 1
kill "${PID}"
wait "${PID}"

rm /tmp/testTraps.sh
}
