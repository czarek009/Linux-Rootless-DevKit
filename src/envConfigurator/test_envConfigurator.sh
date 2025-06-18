#!/usr/bin/env bash

source ./envConfigurator.sh

COLOR_BLUE="\033[1;34m"
COLOR_RESET="\033[0m"

# Clear test.txt at the start
true > test.txt

# Test EnvConfigurator::_write
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_write adds a new line to the file ${COLOR_RESET}"
EnvConfigurator::_write "test.txt" "This is the first new line"
cat "test.txt"

echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_write doesn't overwrite the file ${COLOR_RESET}"
EnvConfigurator::_write "test.txt" "This is the second new line"
EnvConfigurator::_write "test.txt" "This is the third new line"
EnvConfigurator::_write "test.txt" "This is the fourth new line"
cat "test.txt"

# Test EnvConfigurator::_exists
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_exists finds text in the file ${COLOR_RESET}"
line=$(EnvConfigurator::_exists "test.txt" "This is the second new line")
echo "Content found at line: $line"

echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_exists returns -1 when the content is not found ${COLOR_RESET}"
line=$(EnvConfigurator::_exists "test.txt" "It doesn't exist")
echo "Content was not found: $line"

# Test EnvConfigurator::_read
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_read reads lines between 1 and 3 ${COLOR_RESET}"
EnvConfigurator::_read "test.txt" "1" "3"

# Test EnvConfigurator::_replace
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_replace replaces 'line' with 'LINE'${COLOR_RESET}"
EnvConfigurator::_replace "test.txt" "line" "LINE"
cat "test.txt"

# Test EnvConfigurator::_remove
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_remove removes the line 'This is the third new LINE' in the file${COLOR_RESET}"
EnvConfigurator::_remove "test.txt" "This is the third new LINE"
cat "test.txt"

# Test EnvConfigurator::_regex
echo -e "\n${COLOR_BLUE}Checking if EnvConfigurator::_regex changes all occurrences of 'LINE' to 'word'${COLOR_RESET}"
EnvConfigurator::_regex "test.txt" "LINE" "word"
cat "test.txt"

# delete test.txt
rm -f test.txt
