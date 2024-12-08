#!/bin/bash
if [[ ! -d $XDG_DATA_HOME/q4base ]]; then mkdir $XDG_DATA_HOME/q4base; fi
if [[ ! -d $XDG_DATA_HOME/q4mp ]]; then mkdir $XDG_DATA_HOME/q4mp; fi
for q4path in q4base q4mp; do
    for basefile in /app/extra/quake4/$q4path/*; do
        filename=$(basename $basefile)
        if [[ ! -s $XDG_DATA_HOME/$q4path/$filename ]]; then
            echo "Missing $XDG_DATA_HOME/$q4path/$filename; linking from bundled data."
            ln -s $basefile $XDG_DATA_HOME/$q4path/$filename
        fi
    done
done

for gamedata_file in $XDG_DATA_HOME/q4base/pak{001..012}.pk4; do
    if [[ ! -f $gamedata_file ]]; then
    zenity --error --ok-label "Quit" --width=400 --text "
<b>Could not find Quake 4 game data file <tt>$(basename $gamedata_file)</tt></b>\n\n
Please ensure you have copied the necessary game data files
(at least <tt>pak001.pk4</tt> through <tt>pak012.pk4</tt> and
<tt>pak022.pk4</tt> through <tt>pak025.pk4</tt>)
to\n<tt><b>$XDG_DATA_HOME/base/</b></tt>."
        exit 1
    fi
done

if [[ ! -f $XDG_DATA_HOME/q4base/autoexec.cfg ]]; then
    echo 'seta sys_lang "english"' >> $XDG_DATA_HOME/q4base/autoexec.cfg
fi

if [[ ! -r $HOME/.quake4/q4base/quake4key ]]; then
    if [[ -r $XDG_DATA_HOME/q4base/quake4key ]]; then
        mkdir -p $HOME/.quake4/q4base
        ln -s $XDG_DATA_HOME/q4base/quake4key $HOME/.quake4/q4base/quake4key
    fi
fi

quake4smp.x86 +set fs_basepath $XDG_DATA_HOME $@
