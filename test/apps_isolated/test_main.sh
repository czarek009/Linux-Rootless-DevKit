#!/usr/bin/env bash

set -Eu

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_TOP_DIR="${SCRIPT_DIR}/../.."

# source libraries
TEST_ISOLATED_APPS_CURL_PATH="${PROJECT_TOP_DIR}/test/apps_isolated/test_curl.sh"
if [[ -f "${TEST_ISOLATED_APPS_CURL_PATH}" ]]; then
    # shellcheck source=/dev/null
    source "${TEST_ISOLATED_APPS_CURL_PATH}"
else
    echo "Error: Could not find test_curl.sh at ${TEST_ISOLATED_APPS_CURL_PATH}"
    exit 1
fi

function Test::IsolatedApps::Testsuite::run()
{
    Test::IsolatedApps::Curl::Testsuite::run || return 1

    return 0
}

# If the script is run directly, execute the tests
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    Test::IsolatedApps::Testsuite::run || exit 1
fi
