#!/bin/bash
set -e

# Run logger test sequence:
echo "ℹ️ Running logger test sequence..."
TEST_LOG_DIR="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )/src/scriptLogger/logs"
bash ./src/scriptLogger/loggerTest.sh
wait

# Verify logger results:
logger_check_str()
{
  local file_prefix="$1"
  local search_str="$2"
  local log_file
  # take most recent log file:
  log_file=$(find "$TEST_LOG_DIR" -type f -name "${file_prefix}*" | sort | tail -n 1)

  if [ -n "$log_file" ] && [ -f "$log_file" ]; then
    if grep -Fq "$search_str" "$log_file" &> /dev/null; then
        echo "✅ File '$log_file' contains string '$search_str'."
    else
        echo "❌ File '$log_file' does not contain string '$search_str'."
        exit 1
    fi
  else
    echo "❌ No log file found with prefix '$file_prefix' in '$log_dir'."
    exit 1
  fi
}
logger_check_str "loggerTest" "Starting scriptLogger test"
logger_check_str "loggerTest" "This is a warning message"
logger_check_str "loggerTest" "This is an error message"
logger_check_str "loggerTest" "This is a debug message"
logger_check_str "loggerTest" "This is a custom log message."
logger_check_str "loggerTest" "this/file/does/not/exist' does not exist"
logger_check_str "loggerTest" "Command 'ls' exists"
logger_check_str "loggerTest" "Command 'thiscommanddoesnotexist' does not exist"
logger_check_str "testTraps" "Script interrupted by user"
rm -r "$TEST_LOG_DIR"


# Install Rust
bash ./src/install_rust.sh

export PATH="$HOME/.cargo/bin:$PATH"

# Verify installation
source ~/.bashrc
if command -v rustc >/dev/null 2>&1; then
  rustc --version
else
  echo "❌ rustc not found after install."
  exit 1
fi

# Uninstall Rust
bash ./src/uninstall_rust.sh

# Verify uninstallation
if [ ! -d "$HOME/.cargo" ] && [ ! -d "$HOME/.rustup" ]; then
  echo "✅ Rust successfully uninstalled."
else
  echo "❌ Rust files still exist after uninstall."
  exit 1
fi

# Intall zsh
bash ./src/zsh/zshInstall.sh
export PATH="$HOME/.local/bin:$PATH"
source $HOME/.bashrc

# Verify installation
if command -v zsh >/dev/null 2>&1; then
  zsh --version
  echo "✅ zsh successfully installed."
else
  echo "❌ zsh not found after install."
  exit 1
fi

# Uninstall zsh
bash ./src/zsh/zshUninstall.sh
source $HOME/.bashrc

# Verify uninstallation
if [ ! -d "$HOME/.oh-my-zsh" ] && [ ! -d "$HOME/.local/bin/zsh" ]; then
  echo "✅ zsh successfully uninstalled."
else
  echo "❌ zsh files still exist after uninstall."
  exit 1
fi


