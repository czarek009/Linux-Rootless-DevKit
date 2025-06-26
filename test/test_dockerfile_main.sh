#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_TOP_DIR="${SCRIPT_DIR}/.."

function Test::Docker::run_test()
{
    local dockerfile_path="${1}"
    local docker_tag="${2}"

    shift 2
    local docker_arguments=("$@")

    DOCKER_BUILDKIT=1 docker build --no-cache --file "${dockerfile_path}" --tag "${docker_tag}" "${PROJECT_TOP_DIR}" || return 1
    docker run "${docker_arguments[@]}" --rm "${docker_tag}" || return 1
    docker image rm "${docker_tag}" || return 1

    return 0
}

function Test::Docker::run_all()
{
    Test::Docker::run_test "${PROJECT_TOP_DIR}/test/docker/Dockerfile_redhat_8" "tester:redhat-8" -e SELECTED_SHELL="bash" || return 1
    Test::Docker::run_test "${PROJECT_TOP_DIR}/test/docker/Dockerfile_redhat_8" "tester:redhat-8" -e SELECTED_SHELL="zsh" || return 1

    Test::Docker::run_test "${PROJECT_TOP_DIR}/test/docker/Dockerfile_ubuntu_2404" "tester:ubuntu-2404" -e SELECTED_SHELL="bash" || return 1
    Test::Docker::run_test "${PROJECT_TOP_DIR}/test/docker/Dockerfile_ubuntu_2404" "tester:ubuntu-2404" -e SELECTED_SHELL="zsh" || return 1

    Test::Docker::run_test "${PROJECT_TOP_DIR}/test/docker/Dockerfile_ubuntu_2504" "tester:ubuntu-2504" -e SELECTED_SHELL="bash" || return 1
    Test::Docker::run_test "${PROJECT_TOP_DIR}/test/docker/Dockerfile_ubuntu_2504" "tester:ubuntu-2504" -e SELECTED_SHELL="zsh" || return 1

    return 0
}

if (( $# == 0 )); then
    Test::Docker::run_all || exit 1
else
    if (( $# < 2 )); then
        printf "Usage: %s dockerfile_name dockerimage_tag [optional: dockerimage_arguments]\n" "$0"
        printf "Example: %s Dockerfile_ubuntu_2404 tester:ubuntu-2404 -e SELECTED_SHELL=\"bash\"\n" "$0"
        printf "If no arguments are provided, all tests will be run.\n"
        exit 1
    fi

    dockerfile_name="${1}"
    docker_tag="${2}"
    shift 2
    docker_arguments=("$@")

    if [[ ! -f "${PROJECT_TOP_DIR}/test/docker/${dockerfile_name}" ]]; then
        printf "Dockerfile %s does not exist in the test/docker directory." "${dockerfile_name}"
        exit 1
    fi

    Test::Docker::run_test "${PROJECT_TOP_DIR}/test/docker/${dockerfile_name}" "${docker_tag}" "${docker_arguments[@]}" || exit 1
fi

