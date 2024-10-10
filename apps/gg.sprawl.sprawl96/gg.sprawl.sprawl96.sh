#!/bin/bash
/app/bin/ironwail -basedir $XDG_DATA_HOME +game sprawl "$@"

if [[ "$?" != "0" ]]; then
    zenity --error --title "SPRAWL 96 exited with an error" \
    --text "For a detailed error message, please run SPRAWL '96 from a terminal window using\n \
    <tt><b>flatpak run $FLATPAK_ID</b></tt>." --ok-label "Quit" --width=400
fi
