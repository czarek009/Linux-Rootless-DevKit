#!/usr/bin/env bash

EnvConfigurator::_write() {
    local file="$1"
    local content="$2"
    printf "%s\n" "$content" >> "$file"
}

EnvConfigurator::_write_if_not_present() {
    local file="$1"
    local content="$2"
    local exists
    exists=$(EnvConfigurator::_exists "$file" "$content")
    if [[ "$exists" -eq -1 ]]; then
        EnvConfigurator::_write "$file" "$content"
    else
        echo -1
    fi
}

EnvConfigurator::_insert() {
    local file="$1"
    local content="$2"
    local line_number="$3"

    if [[ -z "$line_number" ]]; then
        EnvConfigurator::_write "$file" "$content"
    else
        awk -v line="$line_number" -v content="$content" 'NR==line {print content} {print}' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
    fi
}

EnvConfigurator::_read() {
    local file="$1"
    local from="$2"
    local to="$3"
    awk -v f="$from" -v t="$to" 'NR>=f && NR<=t {print $0}' "$file"
}

EnvConfigurator::_replace() {
    local file="$1"
    local search="$2"
    local replace="$3"
    sed -i "s|$search|$replace|g" "$file"
}

EnvConfigurator::_remove() {
    local file="$1"
    local content="$2"

    awk -v pat="$content" '
    BEGIN { split(pat, lines, "\n"); n=length(lines); }
    {
        for(i=1;i<=n;i++) {
            if($0==lines[i]) nextline=1;
            else nextline=0;
        }
        if(!nextline) print $0;
    }' "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
}

EnvConfigurator::_exists() {
    local file="$1"
    local content="$2"
    local lineno
    lineno=$(grep -Fn -- "$content" "$file" | cut -d: -f1 | head -n1)
    if [[ -n "$lineno" ]]; then
        echo "$lineno"
    else
        echo "-1"
    fi
}

EnvConfigurator::_regex() {
    local file="$1"
    local pattern="$2"
    local replacement="$3"
    local esc_pattern esc_replacement
    esc_pattern=$(printf '%s' "$pattern" | sed 's/\//\\\//g')
    esc_replacement=$(printf '%s' "$replacement" | sed 's/\//\\\//g')
    sed -i -E "s/${esc_pattern}/${esc_replacement}/g" "$file"
}
