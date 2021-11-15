#!/usr/bin/env bash

# Run checks of the platform
SHELL_FILES=()
while IFS='' read -r line; do SHELL_FILES+=("$line"); done < <(find . -type f -name "*.sh" -not -path "./ccc/client/node_modules/*")

shellcheck -e SC1091 -s bash "${SHELL_FILES[@]}"
