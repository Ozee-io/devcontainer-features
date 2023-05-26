#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

Check "See what is in app path" ls -la jetbrains-ide-path

# Report result
reportResults