#!/usr/bin/env bash
ENVCONFIGURATOR_DIR_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit ; pwd -P )"
source "$ENVCONFIGURATOR_DIR_PATH/envConfigurator.sh"
LOGGER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../logger" && pwd)/script_logger.sh"
source "${LOGGER_PATH}"
ENV_PATHS_LIB="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/env_variables.sh"
source "${ENV_PATHS_LIB}"

# Test EnvConfigurator::_write
Logger::log_info "Checking if EnvConfigurator::_write adds a new line to the file"
EnvConfigurator::_write "test.txt" "This is the first new line"
if grep -q "This is the first new line" "test.txt"; then
    Logger::log_success "EnvConfigurator::_write works correctly"
else
    Logger::log_error "EnvConfigurator::_write failed to add the line"
    exit 1
fi


Logger::log_info "Checking if EnvConfigurator::_write doesn't overwrite the file"
EnvConfigurator::_write "test.txt" "This is the second new line"
EnvConfigurator::_write "test.txt" "This is the third new line"
EnvConfigurator::_write "test.txt" "This is the fourth new line"
first_line_num=$(grep -n "This is the first new line" test.txt | cut -d: -f1)
fourth_line_num=$(grep -n "This is the fourth new line" test.txt | cut -d: -f1)
if [[ -n "$first_line_num" && -n "$fourth_line_num" && "$first_line_num" -lt "$fourth_line_num" ]]; then
    Logger::log_success "EnvConfigurator::_write order works correctly"
else
    Logger::log_error "EnvConfigurator::_write order failed"
    exit 1
fi

# Test EnvConfigurator::_write_if_not_present
Logger::log_info "Checking if EnvConfigurator::_write_if_not_present adds a new line if it doesn't exist"
EnvConfigurator::_write_if_not_present "test.txt" "This is a write if not present test line"
if [[ $(grep -c "This is a write if not present test line" "test.txt") -eq 1 ]]; then
    Logger::log_success "EnvConfigurator::_write_if_not_present works correctly"
else
    Logger::log_error "EnvConfigurator::_write_if_not_present failed to add the line"
    exit 1
fi

# Test EnvConfigurator::_write_if_not_present with multiple lines
Logger::log_info "Checking if EnvConfigurator::_write_if_not_present adds multiple lines correctly"
# Write the multiline string if not present
EnvConfigurator::_write_if_not_present "test.txt" \
"This
text
only
once"
if [[ $(grep -Poz '(?s)(^|\n)This\ntext\nonly\nonce(?=\n|$)' test.txt | grep -c "^") -eq 5 ]]; then
    Logger::log_success "EnvConfigurator::_write_if_not_present added the multiline string correctly"
else
    Logger::log_error "EnvConfigurator::_write_if_not_present failed to add the multiline string"
    exit 1
fi

# Test EnvConfigurator::_write_if_not_present will not add multiple lines that already exist
Logger::log_info "Checking if EnvConfigurator::_write_if_not_present will NOT add multiple lines that already exist"
# Write the multiline string if not present
EnvConfigurator::_write_if_not_present "test.txt" \
"This
text
only
once"
if [[ $(grep -Poz '(?s)(^|\n)This\ntext\nonly\nonce(?=\n|$)' test.txt | grep -c "^") -eq 5 ]]; then
    Logger::log_success "EnvConfigurator::_write_if_not_present added the multiline string correctly"
else
    Logger::log_error "EnvConfigurator::_write_if_not_present ADDED multiple lines, that already exist!"
    exit 1
fi

Logger::log_info "Checking if EnvConfigurator::_write_if_not_present does not add a line that already exists"
EnvConfigurator::_write_if_not_present "test.txt" "This is the fifth new line"
if ! [[ $(grep -c "This is a write if not present test line" "test.txt") -eq 1 ]]; then
    Logger::log_error "EnvConfigurator::_write_if_not_present added a duplicate line"
    exit 1
else
    Logger::log_success "EnvConfigurator::_write_if_not_present did not add a duplicate line"
fi  

# Test EnvConfigurator::_insert
Logger::log_info "Checking if EnvConfigurator::_insert adds a new line at the end of the file"
EnvConfigurator::_insert "test.txt" "This is the line inserted at the 2 position" 2
if [[ "$(sed -n '2p' test.txt)" == "This is the line inserted at the 2 position" ]]; then
    Logger::log_success "EnvConfigurator::_insert inserted the line at position 2 correctly"
else
    Logger::log_error "EnvConfigurator::_insert failed to insert the line at position 2"
    exit 1
fi

# Test EnvConfigurator::_exists
Logger::log_info "Checking if EnvConfigurator::_exists finds text in the file"
line=$(EnvConfigurator::_exists "test.txt" "This is the second new line")
if [[ $line != -1 ]]; then
    Logger::log_success "EnvConfigurator::_exists found the content at line $line"
else
    Logger::log_error "EnvConfigurator::_exists failed to find the content"
    exit 1
fi

Logger::log_info "Checking if EnvConfigurator::_exists returns -1 when the content is not found"
line=$(EnvConfigurator::_exists "test.txt" "It doesn't exist")
if [[ $line == -1 ]]; then
    Logger::log_success "EnvConfigurator::_exists did not found content"
else
    Logger::log_error "EnvConfigurator::_exists found content at line: $line"
    exit 1
fi

# Test EnvConfigurator::_read
Logger::log_info "Checking if EnvConfigurator::_read reads lines between 1 and 3"
result=$(EnvConfigurator::_read "test.txt" "1" "3")
if [[ $result == *"This is the first new line"* && $result == *"This is the line inserted at the 2 position"* && $result == *"This is the second new line"* ]]; then
    Logger::log_success "EnvConfigurator::_read works correctly"
else
    Logger::log_error "EnvConfigurator::_read failed to read the correct lines"
    exit 1
fi

# Test EnvConfigurator::_replace
Logger::log_info "Checking if EnvConfigurator::_replace replaces 'line' with 'LINE'"
EnvConfigurator::_replace "test.txt" "line" "LINE"
if grep -q "line" "test.txt"; then
    Logger::log_error "EnvConfigurator::_replace The string 'line' exists in test.txt"
    exit 1
else
    Logger::log_success "EnvConfigurator::_replace The string 'line' does not exist in test.txt"
fi

# Test EnvConfigurator::_remove
Logger::log_info "Checking if EnvConfigurator::_remove removes the line 'This is the third new LINE' in the file"
EnvConfigurator::_remove "test.txt" "This is the third new LINE"
if grep -q "This is the third new LINE" "test.txt"; then
    Logger::log_error "EnvConfigurator::_remove The string 'This is the third new LINE' exists in test.txt"
    exit 1
else
    Logger::log_success "EnvConfigurator::_remove The string 'This is the third new LINE' does not exist in test.txt"
fi

# Test EnvConfigurator::_regex
Logger::log_info "Checking if EnvConfigurator::_regex changes all occurrences of 'LINE' to 'word'"
EnvConfigurator::_regex "test.txt" "LINE" "word"
if grep -q "LINE" "test.txt"; then
    Logger::log_error "EnvConfigurator::_replace The string 'LINE' exists in test.txt"
    exit 1
else
    Logger::log_success "EnvConfigurator::_replace The string 'LINE' does not exist in test.txt"
fi

#Test EnvConfigurator::create_dir_if_not_exists
Logger::log_info "Checking if EnvConfigurator::create_dir_if_not_exists creates a directory if it does not exist"
EnvConfigurator::create_dir_if_not_exists "test_dir"
if [[ -d "test_dir" ]]; then
    Logger::log_success "EnvConfigurator::create_dir_if_not_exists created the directory 'test_dir' successfully"
else
    Logger::log_error "EnvConfigurator::create_dir_if_not_exists failed to create the directory 'test_dir'"
    exit 1
fi

#Test EnvConfigurator::remove_dir_if_exists
Logger::log_info "Checking if EnvConfigurator::remove_dir_if_exists removes a directory if it exists"
EnvConfigurator::remove_dir_if_exists "test_dir" "y"
if [[ ! -d "test_dir" ]]; then
    Logger::log_success "EnvConfigurator::remove_dir_if_exists removed the directory 'test_dir' successfully"
else
    Logger::log_error "EnvConfigurator::remove_dir_if_exists failed to remove the directory 'test_dir'"
    exit 1
fi

# Test EnvConfigurator::remove_dir_if_exists with a non-empty directory and remove_non_empty set to 'y'
EnvConfigurator::create_dir_if_not_exists "test_dir"
EnvConfigurator::create_file_if_not_exists "test_dir/test_file.txt"
Logger::log_info "Checking if EnvConfigurator::remove_dir_if_exists removes a non-empty directory if 'remove_non_empty' is set to 'y'"
EnvConfigurator::remove_dir_if_exists "test_dir" "y"
if [[ ! -d "test_dir" ]]; then
    Logger::log_success "EnvConfigurator::remove_dir_if_exists removed the non-empty directory 'test_dir' successfully"
else
    Logger::log_error "EnvConfigurator::remove_dir_if_exists failed to remove the non-empty directory 'test_dir'"
    exit 1
fi

# Test EnvConfigurator::remove_dir_if_exists with a non-empty directory and remove_non_empty set to 'n'
EnvConfigurator::create_dir_if_not_exists "test_dir"
EnvConfigurator::create_file_if_not_exists "test_dir/test_file.txt"
Logger::log_info "Checking if EnvConfigurator::remove_dir_if_exists does not remove a non-empty directory if 'remove_non_empty' is set to 'n'"
EnvConfigurator::remove_dir_if_exists "test_dir" "n"
if [[ -d "test_dir" ]]; then
    Logger::log_success "EnvConfigurator::remove_dir_if_exists did not remove the non-empty directory 'test_dir' as expected"
else
    Logger::log_error "EnvConfigurator::remove_dir_if_exists removed the non-empty directory 'test_dir' when it should not have"
    exit 1
fi

# Test EnvConfigurator::move_file_if_exists
EnvConfigurator::create_file_if_not_exists "test_mv.txt"
Logger::log_info "Checking if EnvConfigurator::move_file_if_exists moves test_mv.txt to test_dir/test_mv.txt if it exists"
EnvConfigurator::move_file_if_exists "test_mv.txt" "test_dir/test_mv.txt" "y"
if [[ -f "test_dir/test_mv.txt" && ! -f "test_mv.txt" ]]; then
    Logger::log_success "EnvConfigurator::move_file_if_exists moved the file 'test_mv.txt' to 'test_dir/test_mv.txt' successfully"
else
    Logger::log_error "EnvConfigurator::move_file_if_exists failed to move the file 'test_mv.txt' to 'test_dir/test_mv.txt'"
    exit 1
fi

# Test EnvConfigurator::move_file_if_exists with overwrite set to 'y'
EnvConfigurator::create_file_if_not_exists "test_mv.txt"
Logger::log_info "Checking if EnvConfigurator::move_file_if_exists moves test_mv.txt to test_dir/test_mv.txt if it exists and overwrite is set to 'y'"
EnvConfigurator::move_file_if_exists "test_mv.txt" "test_dir/test_mv.txt" "y"
if [[ -f "test_dir/test_mv.txt" && ! -f "test_mv.txt" ]]; then
    Logger::log_success "EnvConfigurator::move_file_if_exists moved the file 'test_mv.txt' to 'test_dir/test_mv.txt' successfully with overwrite set to 'y'"
else
    Logger::log_error "EnvConfigurator::move_file_if_exists failed to move the file 'test_mv.txt' to 'test_dir/test_mv.txt' with overwrite set to 'y'"
    exit 1
fi

# Test EnvConfigurator::move_file_if_exists with overwrite set to 'n'
EnvConfigurator::create_file_if_not_exists "test_mv.txt"
Logger::log_info "Checking if EnvConfigurator::move_file_if_exists does not move test_mv.txt to test_dir/test_mv.txt if it exists and overwrite is not set to 'y'"
EnvConfigurator::move_file_if_exists "test_mv.txt" "test_dir/test_mv.txt" "n"
if [[ -f "test_dir/test_mv.txt" && -f "test_mv.txt" ]]; then
    Logger::log_success "EnvConfigurator::move_file_if_exists did not move the file 'test_mv.txt' to 'test_dir/test_mv.txt' as expected"
else
    Logger::log_error "EnvConfigurator::move_file_if_exists moved the file 'test_mv.txt' to 'test_dir/test_mv.txt' when it should not have"
    exit 1
fi

# Test EnvConfigurator::copy_file_if_exists
EnvConfigurator::create_file_if_not_exists "test_cp.txt"
Logger::log_info "Checking if EnvConfigurator::copy_file_if_exists copies test_cp.txt to test_dir/test_cp.txt if it exists"
EnvConfigurator::copy_file_if_exists "test_cp.txt" "test_dir/test_cp.txt" "y"
if [[ -f "test_dir/test_cp.txt" && -f "test_cp.txt" ]]; then
    Logger::log_success "EnvConfigurator::copy_file_if_exists copied the file 'test_cp.txt' to 'test_dir/test_cp.txt' successfully"
else
    Logger::log_error "EnvConfigurator::copy_file_if_exists failed to copy the file 'test_cp.txt' to 'test_dir/test_cp.txt'"
    exit 1
fi

# Test EnvConfigurator::copy_file_if_exists with overwrite set to 'y'
EnvConfigurator::create_file_if_not_exists "test_cp.txt"
EnvConfigurator::_write "test_cp.txt" "OVERWRITE"
Logger::log_info "Checking if EnvConfigurator::copy_file_if_exists copies test_cp.txt to test_dir/test_cp.txt if it exists and overwrite is set to 'y'"
EnvConfigurator::copy_file_if_exists "test_cp.txt" "test_dir/test_cp.txt" "y"
if [[ -f "test_dir/test_cp.txt" && -f "test_cp.txt" ]] && grep -q "OVERWRITE" "test_dir/test_cp.txt"; then
    Logger::log_success "EnvConfigurator::copy_file_if_exists copied the file 'test_cp.txt' to 'test_dir/test_cp.txt' successfully with overwrite set to 'y'"
else
    Logger::log_error "EnvConfigurator::copy_file_if_exists failed to copy the file 'test_cp.txt' to 'test_dir/test_cp.txt' with overwrite set to 'y'"
    exit 1
fi

# Test EnvConfigurator::backup_file_if_exists
EnvConfigurator::create_dir_if_not_exists "test_backup_dir"
BACKUP_PATH_BACKUP=$BACKUP_PATH
BACKUP_PATH="test_backup_dir"
EnvConfigurator::create_file_if_not_exists "test_backup.txt"
Logger::log_info "Checking if EnvConfigurator::backup_file_if_exists backss up test_backup.txt to $BACKUP_PATH if it exists"
EnvConfigurator::backup_file_if_exists "test_backup.txt" "$BACKUP_PATH"
if [[ "$(ls -1 "$BACKUP_PATH" | wc -l)" == 1 ]]; then
    Logger::log_success "EnvConfigurator::backup_file_if_exists backed up the file 'test_backup.txt' to '$BACKUP_PATH' successfully"
else
    Logger::log_error "EnvConfigurator::backup_file_if_exists failed to back up the file 'test_backup.txt' to '$BACKUP_PATH'"
    exit 1
fi
BACKUP_PATH=$BACKUP_PATH_BACKUP

# Test EnvConfigurator::remove_file_if_exists
EnvConfigurator::create_file_if_not_exists "test_rm.txt"
Logger::log_info "Checking if EnvConfigurator::remove_file_if_exists removes test_rm.txt if it exists"
EnvConfigurator::remove_file_if_exists "test_rm.txt"
if [[ ! -f "test_rm.txt" ]]; then
    Logger::log_success "EnvConfigurator::remove_file_if_exists removed the file 'test_rm.txt' successfully"
else
    Logger::log_error "EnvConfigurator::remove_file_if_exists failed to remove the file 'test_rm.txt'"
    exit 1
fi

# delete leftover files and directories
EnvConfigurator::remove_file_if_exists "test.txt"
EnvConfigurator::remove_file_if_exists "test_mv.txt"
EnvConfigurator::remove_file_if_exists "test_cp.txt"
EnvConfigurator::remove_file_if_exists "test_backup.txt"
EnvConfigurator::remove_dir_if_exists "test_dir" "y"
EnvConfigurator::remove_dir_if_exists "test_backup_dir" "y"
