#!/bin/bash
cd /app/bin
sprawl96 +game sprawl "$@"

if [[ "$?" != "0" ]]; then
    zenity --error --width=400 --title "SPRAWL 96 exited with an error" \
    --text "For a detailed error message, please run SPRAWL 96 from a terminal window using\n \
    <tt><b>flatpak run $FLATPAK_ID</b></tt>." --ok-label "Quit"
fi
