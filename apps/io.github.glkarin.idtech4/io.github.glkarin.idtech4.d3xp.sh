#!/bin/bash

BASEDIR=$XDG_DATA_HOME/doom3
GAMEDIR=$BASEDIR/d3xp
gamedata_file="$GAMEDIR/pak000.pk4"

if [[ ! -f $gamedata_file ]]; then
    zenity --error --ok-label "Quit" --width=400 --text "
Could not find Doom 3 RoE game data file <tt><b>$(basename $gamedata_file)</tt></b>\n\n
Please ensure you have copied at least <tt><b>$(basename $gamedata_file)</b></tt>
from a Doom 3 RoE installation to\n<tt><b>$GAMEDIR/</b></tt>."
    if [[ ! -d $GAMEDIR ]]; then mkdir -p $GAMEDIR; fi
    xdg-open $GAMEDIR
    exit 1
fi

io.github.glkarin.idtech4.doom3.sh +set fs_game d3xp
