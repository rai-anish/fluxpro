#!/bin/bash

set -euo pipefail

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CONFIG_FILE="$BASE_DIR/config.user"
TEMPLATE_FILE="$BASE_DIR/Flux.conf.template"
CONF_FILE="$BASE_DIR/Flux.conf"
LOG="/tmp/fluxpro.log"

echo "[$(date)] ── Flux Pro Starting ──" >> "$LOG"

export DISPLAY="${DISPLAY:-:0}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-0}"
export XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR:-/mnt/wslg/runtime-dir}"

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "[$(date)] ERROR: config.user not found" >> "$LOG"
    echo "ERROR: config.user not found. Run: cp Flux/config.user.example Flux/config.user" >&2
    exit 1
fi

source "$CONFIG_FILE"

TIMEZONE="${TIMEZONE:-Asia/Kathmandu}"
ALIGNMENT="${ALIGNMENT:-top_right}"
GAP_X="${GAP_X:-50}"
GAP_Y="${GAP_Y:-70}"
WINDOW_TYPE="${WINDOW_TYPE:-override}"
STARTUP_MODE="${STARTUP_MODE:-auto}"

echo "[$(date)] Config loaded: TZ=$TIMEZONE ALIGN=$ALIGNMENT GAP=${GAP_X},${GAP_Y} WINDOW_TYPE=$WINDOW_TYPE STARTUP_MODE=$STARTUP_MODE" >> "$LOG"

if [[ ! -f "$TEMPLATE_FILE" ]]; then
    echo "[$(date)] ERROR: Flux.conf.template not found" >> "$LOG"
    exit 1
fi

generate_conf() {
    local mode="$1"
    sed \
        -e "s|__BASE_PATH__|$BASE_DIR|g" \
        -e "s|__TIMEZONE__|$TIMEZONE|g" \
        -e "s|__ALIGNMENT__|$ALIGNMENT|g" \
        -e "s|__GAP_X__|$GAP_X|g" \
        -e "s|__GAP_Y__|$GAP_Y|g" \
        -e "s|__WINDOW_TYPE__|$mode|g" \
        "$TEMPLATE_FILE" > "$CONF_FILE"
    echo "[$(date)] Flux.conf generated with WINDOW_TYPE=$mode at $CONF_FILE" >> "$LOG"
}

display_ready() {
    [[ -S "/tmp/.X11-unix/X0" ]] && return 0
    command -v xdpyinfo >/dev/null 2>&1 && xdpyinfo >/dev/null 2>&1 && return 0
    return 1
}

echo "[$(date)] Waiting for display..." >> "$LOG"
for i in $(seq 1 30); do
    if display_ready; then
        echo "[$(date)] Display ready at attempt $i (DISPLAY=$DISPLAY)" >> "$LOG"
        break
    fi
    sleep 2
done

if ! display_ready; then
    echo "[$(date)] ERROR: Display never became available" >> "$LOG"
    exit 1
fi

killall conky 2>/dev/null || true
sleep 1

if [[ "$STARTUP_MODE" == "auto" && "$WINDOW_TYPE" == "override" ]]; then
    echo "[$(date)] Safe startup sequence: normal -> override" >> "$LOG"

    generate_conf "normal"
    nohup conky -c "$CONF_FILE" >> "$LOG" 2>&1 &
    WARMUP_PID=$!
    sleep 4

    if kill -0 "$WARMUP_PID" 2>/dev/null; then
        echo "[$(date)] Warmup Conky started (PID $WARMUP_PID)" >> "$LOG"
    fi

    killall conky 2>/dev/null || true
    sleep 1

    generate_conf "override"
else
    generate_conf "$WINDOW_TYPE"
fi

nohup conky -c "$CONF_FILE" >> "$LOG" 2>&1 &
CONKY_PID=$!
sleep 2

if kill -0 "$CONKY_PID" 2>/dev/null; then
    echo "[$(date)] Flux Pro running (PID $CONKY_PID)" >> "$LOG"
    echo "Flux Pro started (PID $CONKY_PID)"
else
    echo "[$(date)] ERROR: Conky failed to start — check $LOG" >> "$LOG"
    echo "ERROR: Conky failed to start. Check /tmp/fluxpro.log" >&2
    exit 1
fi

