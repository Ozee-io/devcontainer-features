#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

check "If App Path exists" jetbrains-ide-path

# Report result
reportResults