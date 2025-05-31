#!/usr/bin/env bash

set -Eu

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_TOP_DIR="${SCRIPT_DIR}/../.."

# source libraries
ISOLATED_APPS_CURL_PATH="${PROJECT_TOP_DIR}/apps_isolated/scripts/curl.sh"
if [[ -f "${ISOLATED_APPS_CURL_PATH}" ]]; then
    # shellcheck source=/dev/null
    source "${ISOLATED_APPS_CURL_PATH}"
else
    echo "Error: Could not find curl.sh at ${ISOLATED_APPS_CURL_PATH}"
    exit 1
fi

function Test::IsolatedApps::Curl::Testsuite::before::run()
{
    IsolatedApps::Curl::install || return 1
    if ! IsolatedApps::Curl::is_installed; then
        printf "ERROR: Curl is not installed correctly."
        return 1
    fi

    return 0
}

function Test::IsolatedApps::Curl::Testsuite::run()
{
    Test::IsolatedApps::Curl::Testsuite::before::run

    IsolatedApps::Curl::run --version || return 1

    return 0
}

# If the script is run directly, execute the tests
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    Test::IsolatedApps::Curl::Testsuite::run || exit 1
fi