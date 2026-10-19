#!/bin/bash
GAME_TITLE="Kameo: Elements of Power"
ISO_REQUIREMENT="the EU Rev1 version of $GAME_TITLE"
PORT_NAME="Kameo RePowered"
EXECUTABLE="/app/bin/kameorepowered"
DATA_DIR="$XDG_DATA_HOME/$FLATPAK_ID"
ASSETS_DIR="$DATA_DIR/assets"
XEX_SHASUM="124d812f75f465d393134a84792412bf01a135ea1d6ea4eafef82aa4a5f739c4"

pick_iso_gui() {
    zenity --file-selection \
        --title="Select ISO for $ISO_REQUIREMENT" \
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

    if [ $? -ne 0 ]; then
        zenity --error --title "Extraction failed" \
          --text "Failed to extract <tt>$iso_path</tt>. Please try another
disk image or manually extract it to <tt>$ASSETS_DIR</tt> using <tt>extract-xiso</tt>."
        exit 1
    fi

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

    ISO_PATH=$(pick_iso_gui)

    if [ -z "$ISO_PATH" ] || [ ! -f "$ISO_PATH" ]; then
        zenity --error --title "File not found" --text \
          "${ISO_PATH:-<empty>} not found. Please select an ISO image of $ISO_REQUIREMENT."
        exit 1
    fi

    setup_assets "$ISO_PATH"
fi

# ── Verify default.xex ────────────────────────────────────────────────────────

CHECKED_SHASUM=$(sha256sum $ASSETS_DIR/default.xex | cut -d " " -f 1)
if [ ! -z "$XEX_SHASUM" ] && [ "$CHECKED_SHASUM" != "$XEX_SHASUM" ]; then
    response=$(zenity --warning --title "default.xex sha256 mismatched" \
      --extra-button "Open asset directory" \
      --text "The sha256 checksum for <tt>default.xex</tt> does not match the expected file. \
The game may not work properly.\n
If you encounter problems, please delete the asset directory and restart $PORT_NAME to try \
another dump of the game.\n
Expected: <tt>$XEX_SHASUM</tt>
Got: <tt>$CHECKED_SHASUM</tt>")
    if [ "$response" == "Open asset directory" ]; then
      xdg-open "$ASSETS_DIR"
      exit 1
    fi
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
  --game_data_root "$ASSETS_DIR" \
  --cache_path "${XDG_CACHE_HOME}/${FLATPAK_ID}" \
  --log_file "${DATA_DIR}/${FLATPAK_ID}.log" \
  --log_level "warn" \
  $@
