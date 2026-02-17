#!/bin/bash

for gamedata_file in $XDG_DATA_HOME/prey/base/pak00{0..4}.pk4; do
    if [[ ! -f $gamedata_file ]]; then
        zenity --error --ok-label "Quit" --width=400 --text "
<b>Could not find Prey game data file <tt>$(basename $gamedata_file)</tt></b>\n\n
Please ensure you have copied the necessary game data files
(at least <tt>pak000.pk4</tt> through <tt>pak004.pk4</tt>)
from a Prey installation to\n<tt><b>$XDG_DATA_HOME/base/</b></tt>."
        exit 1
    fi
done

Prey +set fs_basepath $XDG_DATA_HOME/prey $@
