#!/usr/bin/env bash
LOGGER_DIR_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
source $LOGGER_DIR_PATH/script_logger.sh


Logger::log_info "Starting scriptLogger test..."
Logger::log_warning "This is a warning message."
Logger::log_error "This is an error message."
Logger::log_debug "This is a debug message."
Logger::log "CUSTOM" "This is a custom log message."
Utils::check_file_contains_string "${LOG_FILE}" "Starting scriptLogger test"
Utils::check_file_contains_string "${LOG_FILE}" "this string is NOT in the log file"
Env::check_bashrc_contains_string "#"
Utils::check_file_exists "${LOG_FILE}"
Utils::check_file_exists "/${HOME}/this/file/does/not/exist"
Env::check_command_exists "ls"
Env::check_command_exists "thiscommanddoesnotexist"

SCRIPT_LOGGER_PATH="$(cd "$(dirname "$0")" && pwd)/script_logger.sh"
cat << EOF > /tmp/testTraps.sh
#!/usr/bin/env bash
source "${SCRIPT_LOGGER_PATH}"
Telemetry::setup_signal_handlers
sleep 3 # emulate child process (curl / make / etc)
EOF

chmod +x /tmp/testTraps.sh
setsid /tmp/testTraps.sh &
PID=$!

sleep 1
kill "${PID}"
wait "${PID}"

rm /tmp/testTraps.sh
