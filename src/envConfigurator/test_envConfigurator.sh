#!/usr/bin/env bash
ENVCONFIGURATOR_DIR_PATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 || exit ; pwd -P )"
source "$ENVCONFIGURATOR_DIR_PATH/envConfigurator.sh"

COLOR_RED="\033[1;31m"
COLOR_GREEN="\033[1;32m"
COLOR_BLUE="\033[1;34m"
COLOR_RESET="\033[0m"

# Clear test.txt at the start
true > test.txt

# Test EnvConfigurator::_write
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_write adds a new line to the file ${COLOR_RESET}"
EnvConfigurator::_write "test.txt" "This is the first new line"
if grep -q "This is the first new line" "test.txt"; then
  echo -e "${COLOR_GREEN}EnvConfigurator::_write works correctly${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::_write failed to add the line${COLOR_RESET}"
    exit 1
fi


echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_write doesn't overwrite the file ${COLOR_RESET}"
EnvConfigurator::_write "test.txt" "This is the second new line"
EnvConfigurator::_write "test.txt" "This is the third new line"
EnvConfigurator::_write "test.txt" "This is the fourth new line"
first_line_num=$(grep -n "This is the first new line" test.txt | cut -d: -f1)
fourth_line_num=$(grep -n "This is the fourth new line" test.txt | cut -d: -f1)
if [[ -n "$first_line_num" && -n "$fourth_line_num" && "$first_line_num" -lt "$fourth_line_num" ]]; then
    echo -e "${COLOR_GREEN}EnvConfigurator::_write order works correctly${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::_write order failed${COLOR_RESET}"
    exit 1
fi

# Test EnvConfigurator::_write_if_not_present
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_write_if_not_present adds a new line if it doesn't exist ${COLOR_RESET}"
EnvConfigurator::_write_if_not_present "test.txt" "This is a write if not present test line"
if [[ $(grep -c "This is a write if not present test line" "test.txt") -eq 1 ]]; then
    echo -e "${COLOR_GREEN}EnvConfigurator::_write_if_not_present works correctly${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::_write_if_not_present failed to add the line${COLOR_RESET}"
    exit 1
fi

# Test EnvConfigurator::_write_if_not_present with multiple lines
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_write_if_not_present adds multiple lines correctly ${COLOR_RESET}"
# Write the multiline string if not present
EnvConfigurator::_write_if_not_present "test.txt" \
"This
text
only
once"
if [[ $(grep -Poz '(?s)(^|\n)This\ntext\nonly\nonce(?=\n|$)' test.txt | grep -c "^") -eq 5 ]]; then
    echo -e "${COLOR_GREEN}EnvConfigurator::_write_if_not_present added the multiline string correctly${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::_write_if_not_present failed to add the multiline string${COLOR_RESET}"
    exit 1
fi

# Test EnvConfigurator::_write_if_not_present will not add multiple lines that already exist
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_write_if_not_present will NOT add multiple lines that already exist ${COLOR_RESET}"
# Write the multiline string if not present
EnvConfigurator::_write_if_not_present "test.txt" \
"This
text
only
once"
if [[ $(grep -Poz '(?s)(^|\n)This\ntext\nonly\nonce(?=\n|$)' test.txt | grep -c "^") -eq 5 ]]; then
    echo -e "${COLOR_GREEN}EnvConfigurator::_write_if_not_present added the multiline string correctly${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::_write_if_not_present ADDED multiple lines, that already exist!${COLOR_RESET}"
    exit 1
fi

echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_write_if_not_present does not add a line that already exists ${COLOR_RESET}"
EnvConfigurator::_write_if_not_present "test.txt" "This is the fifth new line"
if ! [[ $(grep -c "This is a write if not present test line" "test.txt") -eq 1 ]]; then
    echo -e "${COLOR_RED}EnvConfigurator::_write_if_not_present added a duplicate line${COLOR_RESET}"
    exit 1
else
    echo -e "${COLOR_GREEN}EnvConfigurator::_write_if_not_present did not add a duplicate line${COLOR_RESET}"
fi  

# Test EnvConfigurator::_insert
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_insert adds a new line at the end of the file ${COLOR_RESET}"
EnvConfigurator::_insert "test.txt" "This is the line inserted at the 2 position" 2
if [[ "$(sed -n '2p' test.txt)" == "This is the line inserted at the 2 position" ]]; then
    echo -e "${COLOR_GREEN}EnvConfigurator::_insert inserted the line at position 2 correctly${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::_insert failed to insert the line at position 2${COLOR_RESET}"
    exit 1
fi

# Test EnvConfigurator::_exists
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_exists finds text in the file ${COLOR_RESET}"
line=$(EnvConfigurator::_exists "test.txt" "This is the second new line")
if [[ $line != -1 ]]; then
    echo -e "${COLOR_GREEN}EnvConfigurator::_exists found the content at line $line${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::_exists failed to find the content${COLOR_RESET}"
    exit 1
fi

echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_exists returns -1 when the content is not found ${COLOR_RESET}"
line=$(EnvConfigurator::_exists "test.txt" "It doesn't exist")
if [[ $line == -1 ]]; then
    echo -e "${COLOR_GREEN}EnvConfigurator::_exists did not found content${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::_exists found content at line: $line${COLOR_RESET}"
    exit 1
fi

# Test EnvConfigurator::_read
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_read reads lines between 1 and 3 ${COLOR_RESET}"
result=$(EnvConfigurator::_read "test.txt" "1" "3")
if [[ $result == *"This is the first new line"* && $result == *"This is the line inserted at the 2 position"* && $result == *"This is the second new line"* ]]; then
    echo -e "${COLOR_GREEN}EnvConfigurator::_read works correctly${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::_read failed to read the correct lines${COLOR_RESET}"
    exit 1
fi

# Test EnvConfigurator::_replace
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_replace replaces 'line' with 'LINE'${COLOR_RESET}"
EnvConfigurator::_replace "test.txt" "line" "LINE"
if grep -q "line" "test.txt"; then
    echo -e "${COLOR_RED}EnvConfigurator::_replace The string 'line' exists in test.txt${COLOR_RESET}"
    exit 1
else
    echo -e "${COLOR_GREEN}EnvConfigurator::_replace The string 'line' does not exist in test.txt${COLOR_RESET}"
fi

# Test EnvConfigurator::_remove
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_remove removes the line 'This is the third new LINE' in the file${COLOR_RESET}"
EnvConfigurator::_remove "test.txt" "This is the third new LINE"
if grep -q "This is the third new LINE" "test.txt"; then
    echo -e "${COLOR_RED}EnvConfigurator::_remove The string 'This is the third new LINE' exists in test.txt${COLOR_RESET}"
    exit 1
else
    echo -e "${COLOR_GREEN}EnvConfigurator::_remove The string 'This is the third new LINE' does not exist in test.txt${COLOR_RESET}"
fi

# Test EnvConfigurator::_regex
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_regex changes all occurrences of 'LINE' to 'word'${COLOR_RESET}"
EnvConfigurator::_regex "test.txt" "LINE" "word"
if grep -q "LINE" "test.txt"; then
    echo -e "${COLOR_RED}EnvConfigurator::_replace The string 'LINE' exists in test.txt${COLOR_RESET}"
    exit 1
else
    echo -e "${COLOR_GREEN}EnvConfigurator::_replace The string 'LINE' does not exist in test.txt${COLOR_RESET}"
fi

#Test EnvConfigurator::create_dir_if_not_exists
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::create_dir_if_not_exists creates a directory if it does not exist ${COLOR_RESET}"
EnvConfigurator::create_dir_if_not_exists "test_dir"
if [[ -d "test_dir" ]]; then
    echo -e "${COLOR_GREEN}EnvConfigurator::create_dir_if_not_exists created the directory 'test_dir' successfully${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::create_dir_if_not_exists failed to create the directory 'test_dir'${COLOR_RESET}"
    exit 1
fi

#Test EnvConfigurator::remove_dir_if_exists
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::remove_dir_if_exists removes a directory if it exists ${COLOR_RESET}"
EnvConfigurator::remove_dir_if_exists "test_dir" "y"
if [[ ! -d "test_dir" ]]; then
    echo -e "${COLOR_GREEN}EnvConfigurator::remove_dir_if_exists removed the directory 'test_dir' successfully${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::remove_dir_if_exists failed to remove the directory 'test_dir'${COLOR_RESET}"
    exit 1
fi

# Test EnvConfigurator::remove_dir_if_exists with a non-empty directory and remove_non_empty set to 'y'
mkdir "test_dir"
touch "test_dir/test_file.txt"
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::remove_dir_if_exists removes a non-empty directory if 'remove_non_empty' is set to 'y' ${COLOR_RESET}"
EnvConfigurator::remove_dir_if_exists "test_dir" "y"
if [[ ! -d "test_dir" ]]; then
    echo -e "${COLOR_GREEN}EnvConfigurator::remove_dir_if_exists removed the non-empty directory 'test_dir' successfully${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::remove_dir_if_exists failed to remove the non-empty directory 'test_dir'${COLOR_RESET}"
    exit 1
fi

# Test EnvConfigurator::remove_dir_if_exists with a non-empty directory and remove_non_empty set to 'n'
mkdir "test_dir"
touch "test_dir/test_file.txt"
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::remove_dir_if_exists does not remove a non-empty directory if 'remove_non_empty' is set to 'n' ${COLOR_RESET}"
EnvConfigurator::remove_dir_if_exists "test_dir" "n"
if [[ -d "test_dir" ]]; then
    echo -e "${COLOR_GREEN}EnvConfigurator::remove_dir_if_exists did not remove the non-empty directory 'test_dir' as expected${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::remove_dir_if_exists removed the non-empty directory 'test_dir' when it should not have${COLOR_RESET}"
    exit 1
fi

# Test EnvConfigurator::move_file_if_exists
touch "test_mv.txt"
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::move_file_if_exists moves test_mv.txt to test_dir/test_mv.txt if it exists ${COLOR_RESET}"
EnvConfigurator::move_file_if_exists "test_mv.txt" "test_dir/test_mv.txt" "y"
if [[ -f "test_dir/test_mv.txt" && ! -f "test_mv.txt" ]]; then
    echo -e "${COLOR_GREEN}EnvConfigurator::move_file_if_exists moved the file 'test_mv.txt' to 'test_dir/test_mv.txt' successfully${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::move_file_if_exists failed to move the file 'test_mv.txt' to 'test_dir/test_mv.txt'${COLOR_RESET}"
    exit 1
fi

# Test EnvConfigurator::move_file_if_exists with overwrite set to 'y'
touch "test_mv.txt"
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::move_file_if_exists moves test_mv.txt to test_dir/test_mv.txt if it exists and overwrite is set to 'y' ${COLOR_RESET}"
EnvConfigurator::move_file_if_exists "test_mv.txt" "test_dir/test_mv.txt" "y"
if [[ -f "test_dir/test_mv.txt" && ! -f "test_mv.txt" ]]; then
    echo -e "${COLOR_GREEN}EnvConfigurator::move_file_if_exists moved the file 'test_mv.txt' to 'test_dir/test_mv.txt' successfully with overwrite set to 'y'${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::move_file_if_exists failed to move the file 'test_mv.txt' to 'test_dir/test_mv.txt' with overwrite set to 'y'${COLOR_RESET}"
    exit 1
fi

# Test EnvConfigurator::move_file_if_exists with overwrite set to 'n'
touch "test_mv.txt"
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::move_file_if_exists does not move test_mv.txt to test_dir/test_mv.txt if it exists and overwrite is not set to 'y' ${COLOR_RESET}"
EnvConfigurator::move_file_if_exists "test_mv.txt" "test_dir/test_mv.txt" "n"
if [[ -f "test_dir/test_mv.txt" && -f "test_mv.txt" ]]; then
    echo -e "${COLOR_GREEN}EnvConfigurator::move_file_if_exists did not move the file 'test_mv.txt' to 'test_dir/test_mv.txt' as expected${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::move_file_if_exists moved the file 'test_mv.txt' to 'test_dir/test_mv.txt' when it should not have${COLOR_RESET}"
    exit 1
fi

# Test EnvConfigurator::copy_file_if_exists
touch "test_cp.txt"
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::copy_file_if_exists copies test_cp.txt to test_dir/test_cp.txt if it exists ${COLOR_RESET}"
EnvConfigurator::copy_file_if_exists "test_cp.txt" "test_dir/test_cp.txt" "y"
if [[ -f "test_dir/test_cp.txt" && -f "test_cp.txt" ]]; then
    echo -e "${COLOR_GREEN}EnvConfigurator::copy_file_if_exists copied the file 'test_cp.txt' to 'test_dir/test_cp.txt' successfully${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::copy_file_if_exists failed to copy the file 'test_cp.txt' to 'test_dir/test_cp.txt'${COLOR_RESET}"
    exit 1
fi

# Test EnvConfigurator::copy_file_if_exists with overwrite set to 'y'
touch "test_cp.txt"
EnvConfigurator::_write "test_cp.txt" "OVERWRITE"
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::copy_file_if_exists copies test_cp.txt to test_dir/test_cp.txt if it exists and overwrite is set to 'y' ${COLOR_RESET}"
EnvConfigurator::copy_file_if_exists "test_cp.txt" "test_dir/test_cp.txt" "y"
if [[ -f "test_dir/test_cp.txt" && -f "test_cp.txt" ]] && grep -q "OVERWRITE" "test_dir/test_cp.txt"; then
    echo -e "${COLOR_GREEN}EnvConfigurator::copy_file_if_exists copied the file 'test_cp.txt' to 'test_dir/test_cp.txt' successfully with overwrite set to 'y'${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::copy_file_if_exists failed to copy the file 'test_cp.txt' to 'test_dir/test_cp.txt' with overwrite set to 'y'${COLOR_RESET}"
    exit 1
fi

# Test EnvConfigurator::backup_file_if_exists
mkdir "test_backup_dir"
BACKUP_PATH_BACKUP=$BACKUP_PATH
BACKUP_PATH="test_backup_dir"
touch "test_backup.txt"
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::backup_file_if_exists backss up test_backup.txt to $BACKUP_PATH if it exists ${COLOR_RESET}"
EnvConfigurator::backup_file_if_exists "test_backup.txt" "$BACKUP_PATH"
if [[ "$(ls -1 "$BACKUP_PATH" | wc -l)" == 1 ]]; then
    echo -e "${COLOR_GREEN}EnvConfigurator::backup_file_if_exists backed up the file 'test_backup.txt' to '$BACKUP_PATH' successfully${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::backup_file_if_exists failed to back up the file 'test_backup.txt' to '$BACKUP_PATH'${COLOR_RESET}"
    exit 1
fi

# Test EnvConfigurator::backup_file_if_exists with already backuped 
sleep 1s
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::backup_file_if_exists back up test_backup.txt again and adds a timestamp $BACKUP_PATH ${COLOR_RESET}"
EnvConfigurator::backup_file_if_exists "test_backup.txt" "$BACKUP_PATH"
if [[ "$(ls -1 "$BACKUP_PATH" | wc -l)" == 2 ]]; then
    echo -e "${COLOR_GREEN}EnvConfigurator::backup_file_if_exists backed up the file 'test_backup.txt' again to '$BACKUP_PATH' successfully${COLOR_RESET}"
else
    echo -e "${COLOR_RED}EnvConfigurator::backup_file_if_exists failed to back up the file 'test_backup.txt' again to '$BACKUP_PATH'${COLOR_RESET}"
    exit 1
fi


BACKUP_PATH=$BACKUP_PATH_BACKUP
# delete leftover files and directories
rm -f test_mv.txt
rm -f test_cp.txt
rm -f test_backup.txt
rm -f test.txt
rm -rf test_dir
rm -rf test_backup_dir
