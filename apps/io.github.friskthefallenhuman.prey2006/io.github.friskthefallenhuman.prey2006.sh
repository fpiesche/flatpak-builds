#!/bin/bash
PREY_BASEDIR=$XDG_DATA_HOME/prey06/base
for basefile in /app/extra/prey/base/*; do
    filename=$(basename $basefile)
    if [[ ! -d $PREY_BASEDIR ]]; then
        mkdir -p $PREY_BASEDIR
    fi
    if [[ ! -s $PREY_BASEDIR/$filename ]]; then
        echo "Missing $PREY_BASEDIR/$filename; linking from bundled data."
        ln -s $basefile $PREY_BASEDIR/$filename
    fi
done

if [[ ! -s $PREY_BASEDIR/game.so ]]; then
    echo "Linking game.so."
    ln -s /app/lib/prey06/game.so $PREY_BASEDIR/game.so
fi

for gamedata_file in $PREY_BASEDIR/pak00{0,1,2,3,4}.pk4; do
    if [[ ! -f $gamedata_file ]]; then
        zenity --error --ok-label "Quit" --width=400 --text "
<b>Could not find Prey game data file <tt>$(basename $gamedata_file)</tt></b>\n\n
Please ensure you have copied the necessary game data files
(at least <tt>pak000.pk4</tt> through <tt>pak004.pk4</tt>)
from a Prey installation to\n<tt><b>$PREY_BASEDIR</b></tt>."
        exit 1
    fi
done

PREY06 +set fs_basepath $PREY_BASEDIR $@
