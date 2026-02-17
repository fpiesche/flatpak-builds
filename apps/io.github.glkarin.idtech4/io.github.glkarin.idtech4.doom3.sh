#!/bin/bash

for gamedata_file in $XDG_DATA_HOME/doom3/base/pak00{0..8}.pk4; do
    if [[ ! -f $gamedata_file ]]; then
        zenity --error --ok-label "Quit" --width=400 --text "
Could not find Doom 3 game data file <tt><b>$(basename $gamedata_file)</b></tt>\n\n
Please ensure you have copied the necessary game data files
(at least <tt><b>pak000.pk4</b></tt> through <tt><b>pak008.pk4</b></tt>)
from a Doom 3 installation to\n<tt><b>$XDG_DATA_HOME/doom3/base/</b></tt>."
        exit 1
    fi
done

Doom3 +set fs_basepath $XDG_DATA_HOME/doom3 $@
