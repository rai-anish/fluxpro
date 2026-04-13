#!/bin/bash

# Resolve the actual location of the project dynamically
# This removes all hardcoded 'Botein' or 'BoteinTheme' references.
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TEMPLATE_FILE="$BASE_DIR/Flux.conf.template"
CONF_FILE="$BASE_DIR/Flux.conf"

# Generate actual config from template with the current folder path
sed "s|__BASE_PATH__|$BASE_DIR|g" "$TEMPLATE_FILE" > "$CONF_FILE"

# Start Conky
conky -c "$CONF_FILE" &
echo "Flux Pro started from $BASE_DIR"
