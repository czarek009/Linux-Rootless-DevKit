#!/usr/bin/env bash

set -Eu

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_TOP_DIR="${SCRIPT_DIR}/../.."

function Test::IsolatedApps::Docker::CentOS::run()
{
    DOCKER_BUILDKIT=1 docker build \
                            --no-cache \
                            --file "${PROJECT_TOP_DIR}/test/apps_isolated/docker/Dockerfile_isolated_test_centos" \
                            --tag tests-centos:apps-isolated . || return 1

    docker run \
            --rm \
            -t \
            -v /etc/group:/etc/group:ro \
            -v /var/run/docker.sock:/var/run/docker.sock \
            --group-add $(stat -c '%g' /var/run/docker.sock) \
            tests-centos:apps-isolated || return 1

    return 0
}

function Test::IsolatedApps::Docker::Debian::run()
{
    DOCKER_BUILDKIT=1 docker build \
                            --no-cache \
                            --file "${PROJECT_TOP_DIR}/test/apps_isolated/docker/Dockerfile_isolated_test_debian" \
                            --tag tests-debian:apps-isolated . || return 1

    docker run \
            --rm \
            -t \
            -v /etc/group:/etc/group:ro \
            -v /var/run/docker.sock:/var/run/docker.sock \
            --group-add $(stat -c '%g' /var/run/docker.sock) \
            tests-debian:apps-isolated || return 1

    return 0
}

function Test::IsolatedApps::Docker::Opensuse::run()
{
    DOCKER_BUILDKIT=1 docker build \
                            --no-cache \
                            --file "${PROJECT_TOP_DIR}/test/apps_isolated/docker/Dockerfile_isolated_test_opensuse" \
                            --tag tests-opensuse:apps-isolated . || return 1

    docker run \
            --rm \
            -t \
            -v /etc/group:/etc/group:ro \
            -v /var/run/docker.sock:/var/run/docker.sock \
            --group-add $(stat -c '%g' /var/run/docker.sock) \
            tests-opensuse:apps-isolated || return 1

    return 0
}

function Test::IsolatedApps::Docker::Redhat::run()
{
    DOCKER_BUILDKIT=1 docker build \
                            --no-cache \
                            --file "${PROJECT_TOP_DIR}/test/apps_isolated/docker/Dockerfile_isolated_test_redhat" \
                            --tag tests-redhat:apps-isolated . || return 1

    docker run \
            --rm \
            -t \
            -v /etc/group:/etc/group:ro \
            -v /var/run/docker.sock:/var/run/docker.sock \
            --group-add $(stat -c '%g' /var/run/docker.sock) \
            tests-redhat:apps-isolated || return 1

    return 0
}

function Test::IsolatedApps::Docker::Rockylinux::run()
{
    DOCKER_BUILDKIT=1 docker build \
                            --no-cache \
                            --file "${PROJECT_TOP_DIR}/test/apps_isolated/docker/Dockerfile_isolated_test_rocky" \
                            --tag tests-rocky:apps-isolated . || return 1

    docker run \
            --rm \
            -t \
            -v /etc/group:/etc/group:ro \
            -v /var/run/docker.sock:/var/run/docker.sock \
            --group-add $(stat -c '%g' /var/run/docker.sock) \
            tests-rocky:apps-isolated || return 1

    return 0
}

function Test::IsolatedApps::Docker::Suse::run()
{
    DOCKER_BUILDKIT=1 docker build \
                            --no-cache \
                            --file "${PROJECT_TOP_DIR}/test/apps_isolated/docker/Dockerfile_isolated_test_suse" \
                            --tag tests-suse:apps-isolated . || return 1

    docker run \
            --rm \
            -t \
            -v /etc/group:/etc/group:ro \
            -v /var/run/docker.sock:/var/run/docker.sock \
            --group-add $(stat -c '%g' /var/run/docker.sock) \
            tests-suse:apps-isolated || return 1

    return 0
}

function Test::IsolatedApps::Docker::Ubuntu::run()
{
    DOCKER_BUILDKIT=1 docker build \
                            --no-cache \
                            --file "${PROJECT_TOP_DIR}/test/apps_isolated/docker/Dockerfile_isolated_test_ubuntu" \
                            --tag tests-ubuntu:apps-isolated . || return 1

    docker run \
            --rm \
            -t \
            -v /etc/group:/etc/group:ro \
            -v /var/run/docker.sock:/var/run/docker.sock \
            --group-add $(stat -c '%g' /var/run/docker.sock) \
            tests-ubuntu:apps-isolated || return 1

    return 0
}

function Test::IsolatedApps::Docker::run()
{
    Test::IsolatedApps::Docker::CentOS::run || return 1
    Test::IsolatedApps::Docker::Debian::run || return 1
    Test::IsolatedApps::Docker::Opensuse::run || return 1
    Test::IsolatedApps::Docker::Redhat::run || return 1
    Test::IsolatedApps::Docker::Rockylinux::run || return 1
    Test::IsolatedApps::Docker::Suse::run || return 1
    Test::IsolatedApps::Docker::Ubuntu::run || return 1

    return 0
}

# if the script is run directly, execute the tests
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    Test::IsolatedApps::Docker::run || exit 1
fi