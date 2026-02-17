#!/bin/bash

BASEDIR=$XDG_DATA_HOME/quake4
GAMEDIR=$BASEDIR/q4base

for gamedata_file in $GAMEDIR/pak{001..012}.pk4; do
    if [[ ! -f $gamedata_file ]]; then
        zenity --error --ok-label "Quit" --width=400 --text "
Could not find Quake 4 game data file <tt><b>$(basename $gamedata_file)</b></tt>\n\n
Please ensure you have copied the necessary game data files
(at least <tt><b>pak001.pk4</b></tt> through <tt><b>pak012.pk4</b></tt> and
<tt><b>pak022.pk4</b></tt> through <tt><b>pak025.pk4</b></tt>)
to\n<tt><b>$GAMEDIR/</b></tt>."
        if [[ ! -d $GAMEDIR ]]; then mkdir -p $GAMEDIR; fi
        xdg-open $GAMEDIR
        exit 1
    fi
done

if [[ ! -f $GAMEDIR/autoexec.cfg ]]; then
    echo 'seta sys_lang "english"' >> $GAMEDIR/autoexec.cfg
fi

Quake4 +set fs_basepath $BASEDIR $@
