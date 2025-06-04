#!/usr/bin/env bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_TOP_DIR="${SCRIPT_DIR}/.."

# @brief Function to run a docker test
#
# USAGE:
#   Test::Docker::run_test "Dockerfile path" "Docker tag" "Docker run command"
# OUTPUT:
#   Docker build output
#   Docker run output
#
# @param $1 - Dockerfile path
# @param $2 - Docker tag
#
# @return 0 on success, return 1 on failure
function Test::Docker::run_test()
{
    local dockerfile_path="${1}"
    local docker_tag="${2}"

    DOCKER_BUILDKIT=1 docker build --no-cache --file "${dockerfile_path}" --tag "${docker_tag}" "${PROJECT_TOP_DIR}" || return 1
    docker run --rm "${docker_tag}" || return 1
}

# @brief Function to run all docker tests in parallel
#
# USAGE:
#   Test::Docker::run_all_parallel
# OUTPUT:
#   Docker build output
#
# @return 0 on success, return 1 on failure
function Test::Docker::run_all_parallel()
{
    (
        ####################################### TEST UNIT #######################################
        # Test  redhat ubi8
        Test::Docker::run_test "${PROJECT_TOP_DIR}/test/docker/Dockerfile_redhat_ubi8" "docker_redhat_ubi8" &
        docker_pid_1=$!

        # Test ubuntu latest
        Test::Docker::run_test "${PROJECT_TOP_DIR}/test/docker/Dockerfile_ubuntu_latest" "docker_ubuntu_latest" &
        docker_pid_2=$!
	
	wait $docker_pid_1 $docker_pid_2
    )

    if ! some_command; then
        return 1
    fi
}


function Test::Docker::run_all()
{
    ####################################### TEST UNIT #######################################
    Test::Docker::run_test "${PROJECT_TOP_DIR}/test/docker/Dockerfile_redhat_ubi8" "docker_redhat_ubi8" || return 1
    Test::Docker::run_test "${PROJECT_TOP_DIR}/test/docker/Dockerfile_ubuntu_latest" "docker_ubuntu_latest" || return 1
}

# If user specifies the test to run in parallel by using -p flag then run the tests in parallel
if [[ "${1:-}" == "-p" ]]; then
    # Run the tests in parallel
    Test::Docker::run_all_parallel || exit 1
else
    # Run the tests sequentially
    Test::Docker::run_all || exit 1
fi
