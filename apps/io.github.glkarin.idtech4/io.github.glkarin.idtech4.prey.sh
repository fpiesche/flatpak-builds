#!/bin/bash

BASEDIR=$XDG_DATA_HOME/prey
GAMEDIR=$BASEDIR/base

for gamedata_file in $GAMEDIR/pak00{0..4}.pk4; do
    if [[ ! -f $gamedata_file ]]; then
        zenity --error --ok-label "Quit" --width=400 --text "
<b>Could not find Prey game data file <tt>$(basename $gamedata_file)</tt></b>\n\n
Please ensure you have copied the necessary game data files
(at least <tt>pak000.pk4</tt> through <tt>pak004.pk4</tt>)
from a Prey installation to\n<tt><b>$GAMEDIR/</b></tt>."
        if [[ ! -d $GAMEDIR ]]; then mkdir -p $GAMEDIR; fi
        xdg-open $GAMEDIR
        exit 1
    fi
done

Prey +set fs_basepath $BASEDIR $@
