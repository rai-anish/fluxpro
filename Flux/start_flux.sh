#!/bin/bash

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_FILE="$BASE_DIR/config.user"
TEMPLATE_FILE="$BASE_DIR/Flux.conf.template"
CONF_FILE="$BASE_DIR/Flux.conf"

# Load user config
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: config.user not found. Copy config.user.example and edit it." >&2
    exit 1
fi
source "$CONFIG_FILE"

# Substitute all placeholders
sed \
    -e "s|__BASE_PATH__|$BASE_DIR|g" \
    -e "s|__TIMEZONE__|$TIMEZONE|g" \
    -e "s|__ALIGNMENT__|$ALIGNMENT|g" \
    -e "s|__GAP_X__|$GAP_X|g" \
    -e "s|__GAP_Y__|$GAP_Y|g" \
    "$TEMPLATE_FILE" > "$CONF_FILE"

echo -n "🚀 Initializing Flux Pro UI... Please wait"

# Wait for display
for i in $(seq 1 30); do
    if xdpyinfo &>/dev/null 2>&1; then
        echo -e "\n✅ Display found! Launching Conky..."
        break
    fi
    echo -n "."
    if [ $i -eq 30 ]; then
        echo -e "\n❌ ERROR: Timeout waiting for display (WSLg). Check if your WSLg is working." >&2
        exit 1
    fi
    sleep 2
done

killall conky 2>/dev/null
sleep 1

nohup conky -c "$CONF_FILE" > /tmp/fluxpro.log 2>&1 &
CONKY_PID=$!
sleep 2

if kill -0 "$CONKY_PID" 2>/dev/null; then
    echo "Flux Pro started (PID $CONKY_PID)"
else
    echo "ERROR: Check /tmp/fluxpro.log" >&2
    exit 1
fi