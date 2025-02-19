#!/bin/bash

# This test file will be executed against an auto-generated devcontainer.json that
# includes the 'go-mod-cache' Feature with no options.
#
# For more information, see: https://github.com/devcontainers/cli/blob/main/docs/features/test.md
#
# These scripts are run as 'root' by default. Although that can be changed
# with the '--remote-user' flag.
# 
# This test can be run with the following command:
#
#    devcontainer features test \ 
#                   --features go-mod-cache   \
#                   --remote-user root \
#                   --skip-scenarios   \
#                   --base-image mcr.microsoft.com/devcontainers/base:ubuntu \
#                   /path/to/this/repo

set -e

# Optional: Import test library bundled with the devcontainer CLI
# See https://github.com/devcontainers/cli/blob/HEAD/docs/features/test.md#dev-container-features-test-lib
# Provides the 'check' and 'reportResults' commands.
source dev-container-features-test-lib

# Feature-specific tests
# The 'check' command comes from the dev-container-features-test-lib. Syntax is...
# check <LABEL> <cmd> [args...]
# check that `/go/pkg` and `/mnt/go-cache` exist`
check "/go/pkg exists" bash -c "ls -la /go | grep 'pkg'"
check "/mnt/go-cache exists" bash -c "ls -la /mnt | grep 'go-cache'"
# check that `/go/pkg` is a symlink
# https://unix.stackexchange.com/a/96910
check "/go/pkg is a symlink" bash -c "test -L /go/pkg && test -d /go/pkg"

# Report results
# If any of the checks above exited with a non-zero exit code, the test will fail.
reportResults