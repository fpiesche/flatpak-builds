#!/bin/bash

DATADIR=$XDG_DATA_HOME/doomrpg
gamedata_file="$DATADIR/DoomRPG.zip"

mkdir -p "$DATADIR" "$DATADIR/saves"
if [[ ! -f $gamedata_file ]]; then
    zenity --error --ok-label "Quit" --width=400 \
        --title "Failed to find Doom RPG game data" --text "
Could not find Doom RPG game data file <tt><b>$(basename $gamedata_file)</b></tt>\n\n
Please ensure you have copied this file to\n<tt><b>$DATADIR/</b></tt>."
    xdg-open $DATADIR
    exit 1
fi

cd $DATADIR
DoomRPG
