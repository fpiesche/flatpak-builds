#!/bin/bash

DATADIR=${XDG_DATA_HOME}/nblood
declare -a GAME_PATHS=( \
  "$DATADIR" \
  "$HOME/.steam/steam/steamapps/common/Blood" \
  "$HOME/.steam/steam/steamapps/common/One Unit Whole Blood" \
  "$HOME/.var/app/com.valvesoftware.Steam/.steam/steam/steamapps/common/Blood" \
  "$HOME/.var/app/com.valvesoftware.Steam/.steam/steam/steamapps/common/One Unit Whole Blood" \
)

for DATA_DIR in "${GAME_PATHS[@]}"; do
  if [[ -f "$DATA_DIR/BLOOD.RFF" ]]; then
    FOUND_DATA=true
  fi
done

if [[ -z "${FOUND_DATA}" ]]; then
  zenity --error --ok-label "Quit" --width=400 \
    --title "Failed to find Blood game data" \
    --text "<b>Could not find Blood game data!</b>\n\n
Please ensure you have either installed Blood via Steam
or copy the Blood game data to <tt><b>${DATADIR}</b></tt>."
  if [[ ! -d $DATADIR ]]; then mkdir -p $DATADIR; fi
  xdg-open $DATADIR
  exit 1
fi


nblood $@
