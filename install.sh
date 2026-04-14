#!/bin/bash
# Flux Pro installer — run once after cloning

set -euo pipefail

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
FLUX_DIR="$BASE_DIR/Flux"
FONT_SRC="$FLUX_DIR/fonts"
FONT_DEST="$HOME/.local/share/fonts"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Flux Pro — Installer"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "▶ Installing dependencies..."
sudo apt update
sudo apt install -y conky-all python3 curl x11-utils

echo ""
echo "▶ Installing fonts..."
mkdir -p "$FONT_DEST"

if [[ -d "$FONT_SRC" ]]; then
    find "$FONT_SRC" -type f \( -iname "*.ttf" -o -iname "*.otf" \) -exec cp -f {} "$FONT_DEST/" \;
    fc-cache -fv >/dev/null 2>&1 || true
    echo "   Fonts installed to $FONT_DEST"
else
    echo "   No fonts directory found at $FONT_SRC — skipping"
fi

echo ""
echo "▶ Setting up config..."
if [[ ! -f "$FLUX_DIR/config.user.example" ]]; then
    echo "ERROR: Missing template file: $FLUX_DIR/config.user.example" >&2
    exit 1
fi

if [[ ! -f "$FLUX_DIR/config.user" ]]; then
    cp "$FLUX_DIR/config.user.example" "$FLUX_DIR/config.user"
    echo "   Created Flux/config.user from example"
    echo ""
    echo "   Open Flux/config.user and set:"
    echo "   - TIMEZONE"
    echo "   - CITY_QUERY"
    echo "   - API_KEY  (free at https://openweathermap.org/api)"
else
    echo "   config.user already exists — skipping"
fi

echo ""
echo "▶ Setting permissions..."
chmod +x "$BASE_DIR/install.sh"

if [[ -f "$FLUX_DIR/start_flux.sh" ]]; then
    chmod +x "$FLUX_DIR/start_flux.sh"
else
    echo "ERROR: Missing launcher script: $FLUX_DIR/start_flux.sh" >&2
    exit 1
fi

if [[ -f "$FLUX_DIR/scripts/weather.sh" ]]; then
    chmod +x "$FLUX_DIR/scripts/weather.sh"
else
    echo "   weather.sh not found — skipping"
fi

echo ""
echo "▶ Checking optional Windows startup helper..."
if [[ -f "$BASE_DIR/StartFluxPro.vbs" ]]; then
    echo "   Found StartFluxPro.vbs in project root"
else
    echo "   StartFluxPro.vbs not found in project root — optional for Task Scheduler"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Done!"
echo ""
echo "  Next steps:"
echo "  1. Edit Flux/config.user with your settings"
echo "  2. Run: bash Flux/start_flux.sh"
echo "  3. Optional: add StartFluxPro.vbs to Windows Task Scheduler"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

