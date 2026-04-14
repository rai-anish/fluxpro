#!/bin/bash
# Installs fonts, dependencies, and sets up config.user

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Installing dependencies..."
sudo apt install -y conky-all

echo "Installing fonts..."
mkdir -p ~/.local/share/fonts
cp "$BASE_DIR/Flux/fonts/"* ~/.local/share/fonts/
fc-cache -fv

echo "Setting up config..."
if [[ ! -f "$BASE_DIR/Flux/config.user" ]]; then
    cp "$BASE_DIR/Flux/config.user.example" "$BASE_DIR/Flux/config.user"
    echo ""
    echo "Edit Flux/config.user with your settings, then run:"
    echo "  bash Flux/start_flux.sh"
else
    echo "config.user already exists, skipping."
fi

echo "Making scripts executable..."
chmod +x "$BASE_DIR/Flux/start_flux.sh"

echo ""
echo "Done! Edit Flux/config.user then run: bash Flux/start_flux.sh"