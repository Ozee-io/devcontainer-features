#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

check "See what is in app path" ls -la /opt/WebStorm

# Report result
reportResults