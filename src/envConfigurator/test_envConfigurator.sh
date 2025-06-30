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

# delete test.txt && test_dir
rm -f test.txt
rm -rf test_dir
