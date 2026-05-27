#!/bin/bash
# reNut Linux Launcher
# Extracts game assets from a Banjo-Kazooie: Nuts & Bolts (US) ISO on first run,
# then launches the game.

set -eu
GAME_TITLE="Banjo-Kazooie: Nuts &amp; Bolts"
ISO_REQUIREMENT="the US version of $GAME_TITLE"
PORT_NAME="reNut"
EXECUTABLE="/app/bin/renut"
DATA_DIR="$XDG_DATA_HOME/$FLATPAK_ID"
ASSETS_DIR="$DATA_DIR/assets"

pick_iso_gui() {
    zenity --file-selection \
        --title="Select Banjo-Kazooie: Nuts & Bolts (US) ISO" \
        --file-filter="ISO files | *.iso *.ISO *.xiso *.XISO" 2>/dev/null || true
    return
}

setup_assets() {
    local iso_path="$1"

    cleanup() { rm -rf "$ASSETS_DIR"; }
    trap cleanup EXIT

    if [[ ! -d "$ASSETS_DIR" ]]; then mkdir -p "$ASSETS_DIR"; fi

    extract-xiso -x "$iso_path" -d "$ASSETS_DIR" | zenity --progress \
      --title "Extracting ISO" \
      --text "This may take a few minutes..." \
      --pulsate \
      --auto-close \
      --auto-kill

    if [ ! -f "$ASSETS_DIR/default.xex" ]; then
        zenity --error --title "default.xex not found after extraction" \
          --text "Please make sure to select an ISO of $ISO_REQUIREMENT."
        exit 1
    fi

    trap - EXIT
}

# ── First-run setup ───────────────────────────────────────────────────────────

if [ ! -f "$ASSETS_DIR/default.xex" ]; then
    zenity --info --title "Game assets not found" \
      --text "Please select an ISO image of $ISO_REQUIREMENT or place its contents into <tt>$ASSETS_DIR</tt>."

    ISO_PATH=""

    # 1. Command-line argument
    if [ -n "${1:-}" ]; then
        ISO_PATH="$1"
    fi

    # 2. GUI file picker
    if [ -z "$ISO_PATH" ]; then
        ISO_PATH=$(pick_iso_gui)
    fi

    if [ -z "$ISO_PATH" ] || [ ! -f "$ISO_PATH" ]; then
        zenity --error --title "File not found" --text \
          "${ISO_PATH:-<empty>} not found. Please select an ISO image of $ISO_REQUIREMENT."
        exit 1
    fi

    setup_assets "$ISO_PATH"
fi

# ── Launch ────────────────────────────────────────────────────────────────────

# SteamOS / Steam Deck: help SDL3 find the PipeWire audio server.
# If XDG_RUNTIME_DIR isn't set we derive the standard path from the UID.
if [ -z "${XDG_RUNTIME_DIR:-}" ]; then
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi
# Let SDL3 auto-detect the audio backend (it handles PipeWire/Pulse/ALSA
# fallback internally). Only force pulse if the user hasn't already set a
# driver AND the pipewire socket is absent, to avoid the SDL3 pipewire
# backend failing on older SteamOS images where pkgconfig says pipewire
# exists but the SDL3 dynamic loader can't open it.

echo "Starting $PORT_NAME..."
exec "$EXECUTABLE" \
  "$ASSETS_DIR" \
  --gpu_allow_invalid_fetch_constants=true \
  --cache_path "${XDG_CACHE_HOME}/${FLATPAK_ID}" \
  --log_file "${DATA_DIR}/${FLATPAK_ID}.log" \
  $@
