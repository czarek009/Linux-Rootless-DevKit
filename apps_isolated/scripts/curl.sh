#!/usr/bin/env bash

set -Eu

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_TOP_DIR="${SCRIPT_DIR}/../.."

function IsolatedApps::Curl::install()
{
    DOCKER_BUILDKIT=1 \
    BUILDX_GIT_INFO=false \
    docker build \
            --build-arg "USER_UID=$(id -u)" \
            --build-arg "USER_GID=$(id -g)" \
            --no-cache \
            --file "${PROJECT_TOP_DIR}/apps_isolated/docker/Dockerfile_isolated_curl" \
            --tag app-isolated:curl . || return 1

    return 0
}

function IsolatedApps::Curl::uninstall()
{
    docker rmi app-isolated:curl >/dev/null 2>&1 || return 1

    return 0
}

function IsolatedApps::Curl::is_installed()
{
    if docker image inspect app-isolated:curl >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi

    return 0
}

function IsolatedApps::Curl::update()
{
    IsolatedApps::Curl::uninstall || return 1
    IsolatedApps::Curl::install || return 1

    return 0
}

function IsolatedApps::Curl::run()
{
    local curl_options_with_files=(
        "--abstract-unix-socket"
        "--alt-svc"
        "-b"
        "--cacert"
        "--capath"
        "-c"
        "--cert"
        "--cookie"
        "--cookie-jar"
        "--crlfile"
        "-D"
        "--dump-header"
        "-E"
        "--egd-file"
        "--etag-compare"
        "--etag-save"
        "--hsts"
        "--key"
        "--K"
        "--libcurl"
        "--netrc-file"
        "--output"
        "--output-dir"
        "-o"
        "--pinnedpubkey"
        "--proxy-cacert"
        "--proxy-capath"
        "--proxy-cert"
        "--proxy-crlfile"
        "--proxy-header"
        "--proxy-key"
        "--random-file"
        "--remote-name"
        "--stderr"
        "-T"
        "--trace"
        "--trace-ascii"
        "--unix-socket"
    )

    local curl_arguments=()

    local -A volumes=(
        ["/etc/group"]="/etc/group:ro"
        ["${HOME}"]="${HOME}:ro"
        ["/etc/ssl/certs"]="/etc/ssl/certs:ro"
    )

    while (( $# > 0 )); do
        local arg="$1"
        curl_arguments+=("${arg}")
        shift

        for opt in "${curl_options_with_files[@]}"; do
            if [[ "${arg}" == "${opt}" ]]; then
                if [[ $# -eq 0 ]]; then
                    echo "Error: missing argument for ${opt}" >&2
                    return 1
                fi

                local val="$1";
                curl_arguments+=("${val}")
                shift

                local dir="$(dirname "${val}")"
                local path="$(realpath -m "${dir}")"
                if [[ -d "${path}" ]]; then
                    volumes["${path}"]="${path}"
                fi

                continue 2
            fi
        done

    #TODO: It should support file:// URLs not full path like /...
        if [[ "arg" == /* ]]; then
            local dir="$(dirname "${arg}")"
            local path="$(realpath -m "${dir}")"
            if [[ -d "${path}" ]]; then
                volumes["${path}"]="${path}"
            fi
        fi
    done

    local mounts=()
    for src in "${!volumes[@]}"; do
        mounts+=("-v" "${src}:${volumes[${src}]}")
    done

    local proxy_docker_args=()
    local proxy_env=(
        HTTP_PROXY
        http_proxy
        HTTPS_PROXY
        https_proxy
        ALL_PROXY
        all_proxy
        NO_PROXY
        no_proxy
    )

    for v in "${proxy_env[@]}"; do
        val="${!v:-}"
        if [[ -n "$val" ]]; then
            proxy_docker_args+=( "--env" "$v=$val" )
        fi
    done

    docker run \
            --rm \
            -i \
            -t \
            --user $(id -u):$(id -g) \
            "${proxy_docker_args[@]}" \
            --env HOME="${HOME}" \
            -w "${PWD}" \
            -v "${PWD}:${PWD}" \
            "${mounts[@]}" \
            app-isolated:curl "${curl_arguments[@]}"

    return $?
}

# If the script is run directly, execute run
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    IsolatedApps::Curl::run "$@" || exit 1
fi