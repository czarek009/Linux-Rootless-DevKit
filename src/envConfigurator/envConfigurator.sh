#!/usr/bin/env bash
LOGGER_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")/../logger" && pwd)/script_logger.sh"
source "${LOGGER_PATH}"

EnvConfigurator::_write() {
    local file="$1"
    local content="$2"

    Logger::log_debug "Writing content to file: $file"
    Logger::log_debug "Content: $content"
    printf "%s\n" "$content" >> "$file"
}

EnvConfigurator::_write_if_not_present() {
    local file="$1"
    local content="$2"
    local exists

    Logger::log_debug "Checking if content exists in file: $file"
    exists=$(EnvConfigurator::_exists "$file" "$content")
    if [[ "$exists" -eq -1 ]]; then
        Logger::log_debug "Content not found -> writing to file: $file"
        EnvConfigurator::_write "$file" "$content"
    else
        Logger::log_debug "Content already exists in file: $file at line $exists"
    fi
}

EnvConfigurator::_insert() {
    local file="$1"
    local content="$2"
    local line_number="$3"

    if [[ -z "$line_number" ]]; then
        Logger::log_error "Line number is not specified for insertion - appending to the end of the file"
        EnvConfigurator::_write "$file" "$content"
    else
        Logger::log_debug "Inserting content at line $line_number in file: $file"
        Logger::log_debug "Content: $content"
        awk -v line="$line_number" -v content="$content" 'NR==line {print content} {print}' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
    fi
}

EnvConfigurator::_read() {
    local file="$1"
    local from="$2"
    local to="$3"
    Logger::log_debug "Reading lines from $from to $to in file: $file"
    awk -v f="$from" -v t="$to" 'NR>=f && NR<=t {print $0}' "$file"
}

EnvConfigurator::_replace() {
    local file="$1"
    local search="$2"
    local replace="$3"

    Logger::log_debug "Replacing content in file: $file"
    Logger::log_debug "Sed command: sed -i \"s|$search|$replace|g\" \"$file\""

    sed -i "s|$search|$replace|g" "$file"
}

EnvConfigurator::_remove() {
    local file="$1"
    local content="$2"

    Logger::log_debug "Removing content from file: $file"
    Logger::log_debug "Content to remove: $content"

    awk -v pat="$content" '
    BEGIN { split(pat, lines, "\n"); n=length(lines); }
    {
        skip=0
        if ($0 ~ /^[[:space:]]*$/) skip=1
        for(i=1;i<=n;i++) {
            if($0==lines[i]) skip=1
        }
        if(!skip) print $0;
    }' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
}

EnvConfigurator::_exists() {
    local file="$1"
    local content="$2"
    local lineno

    Logger::log_debug "Checking if content exists in file: $file"
    Logger::log_debug "Content to find: $content"

    if [[ "$content" == *$'\n'* ]]; then
        lineno=$(grep -F -x -m 1 -n -f <(printf '%s\n' "$content") "$file" | cut -d: -f1 | head -n1)
    else
        # Single line
        lineno=$(grep -F -x -m 1 -n -- "$content" "$file" | cut -d: -f1 | head -n1)
    fi

    if [[ -n "$lineno" ]]; then
        Logger::log_debug "Content was found at line: $lineno"
        echo "$lineno"
    else
        Logger::log_debug "Content not found in file: $file"
        echo "-1"
    fi
}

EnvConfigurator::_regex() {
    local file="$1"
    local pattern="$2"
    local replacement="$3"
    local esc_pattern esc_replacement

    Logger::log_debug "Applying regex replacement in file: $file"
    esc_pattern=$(printf '%s' "$pattern" | sed 's/\//\\\//g')
    esc_replacement=$(printf '%s' "$replacement" | sed 's/\//\\\//g')
    Logger::log_debug "Sed command: sed -i -E 's/${esc_pattern}/${esc_replacement}/g' $file"
    sed -i -E "s/${esc_pattern}/${esc_replacement}/g" "$file"
}

EnvConfigurator::git_clone_if_not_exists() 
{
    local repo_url="$1"
    local target_dir="$2"
    local repo_dir_name

    Logger::log_debug "Cloning git repository if it does not exist: $repo_url"
    repo_dir_name=$(basename "$repo_url" .git)
    if [[ ! -d "$target_dir/$repo_dir_name" ]]; then
        Logger::log_debug "Directory does not exist -> cloning into: $target_dir/$repo_dir_name"
        git clone "$repo_url" "$target_dir/$repo_dir_name" > /dev/null 2>&1
    else
        Logger::log_debug "Directory already exists: $target_dir/$repo_dir_name - skipping clone"
    fi
}

EnvConfigurator::create_dir_if_not_exists() 
{
    local dir_name="$1"
    Logger::log_debug "Creating directory if it does not exist: $1"
    if [[ ! -d "$dir_name" ]]; then
        Logger::log_debug "Directory does not exist -> creating: $dir_name"
        mkdir -p "$dir_name"
    else
        Logger::log_debug "Directory already exists: $dir_name - skipping creation"
    fi
}
