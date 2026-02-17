#!/bin/bash
for gamedata_file in $XDG_DATA_HOME/quake4/q4base/pak{001..012}.pk4; do
    if [[ ! -f $gamedata_file ]]; then
    zenity --error --ok-label "Quit" --width=400 --text "
Could not find Quake 4 game data file <tt><b>$(basename $gamedata_file)</b></tt>\n\n
Please ensure you have copied the necessary game data files
(at least <tt><b>pak001.pk4</b></tt> through <tt><b>pak012.pk4</b></tt> and
<tt><b>pak022.pk4</b></tt> through <tt><b>pak025.pk4</b></tt>)
to\n<tt><b>$XDG_DATA_HOME/q4base/</b></tt>."
        exit 1
    fi
done

if [[ ! -f $XDG_DATA_HOME/q4base/autoexec.cfg ]]; then
    echo 'seta sys_lang "english"' >> $XDG_DATA_HOME/quake4/q4base/autoexec.cfg
fi

Quake4 +set fs_basepath $XDG_DATA_HOME/quake4 $@
