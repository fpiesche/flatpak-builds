#!/bin/bash
function download_librequake {
selection=$(zenity --question --title="Download LibreQuake data?" \
    --text "No Quake game data was found. You can either exit and install Quake to your Steam \
library at <tt><b>$HOME/.local/share/Steam/</b></tt>, or copy the <tt>id1</tt> directory \
from a Quake installation to <tt><b>$XDG_DATA_HOME</b></tt>.\n \
Alternately, this launcher can download the LibreQuake data for you!" \
    --extra-button="Exit" --extra-button="Download LibreQuake" --switch)
case $selection in
    "Download LibreQuake")
        LIBREQUAKE_RELEASE=$(curl -L -s -H 'Accept: application/json' https://github.com/lavenderdotpet/LibreQuake/releases/latest)
        LIBREQUAKE_VERSION=$(echo $LIBREQUAKE_RELEASE | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')
        ARTIFACT_URL="https://github.com/lavenderdotpet/LibreQuake/releases/download/$LIBREQUAKE_VERSION/full.zip"
        wget $ARTIFACT_URL 2>&1 | sed -u 's/.*\ \([0-9]\+%\)\ \+\([0-9.]\+\ [KMB\/s]\+\)$/\1\n# Downloading \2/' | zenity --width=400 --progress --auto-close --pulsate --title="Downloading LibreQuake..." &
        #Start a loop testing if zenity is running, and if not kill wget
        RUNNING=0
        while [ $RUNNING -eq 0 ]; do
            if [ -z "$(pidof zenity)" ]; then
                pkill wget
                RUNNING=1
            else
                sleep 1
            fi
        done
        if [[ $? == 0 ]]; then
            unzip -d $XDG_DATA_HOME full.zip \
                && mv $XDG_DATA_HOME/full/id1 $XDG_DATA_HOME \
                && rm -rf $XDG_DATA_HOME/full full.zip
        else
            zenity --error --title "Downloading LibreQuake failed" \
                --text "Downloading LibreQuake failed. Please try again or download it manually and extract to <tt>$XDG_DATA_HOME</tt>"
            exit 1
        fi
        rm -rf $XDG_DATA_HOME/wget
        /app/bin/ironwail -basedir $XDG_DATA_HOME +game sprawl "$@"
        ;;
    *)
        exit 1
        ;;
    esac
}

# Check for game data
if [[ ! -d $HOME/.local/share/Steam/steamapps/common/Quake/id1/ ]]; then
    if [[ ! -f $XDG_DATA_HOME/id1/pak0.pak ]]; then
        download_librequake
    else
        # If game data is in XDG_DATA_HOME, just start the game
        /app/bin/ironwail -basedir $XDG_DATA_HOME +game sprawl "$@"
    fi
else
    # If Quake game data is in Steam directory, run without -basedir but catch potential errors on exit
    /app/bin/ironwail +game sprawl "$@"
fi

if [[ "$?" != "0" ]]; then
    zenity --error --title "SPRAWL 96 exited with an error" \
    --text "For a detailed error message, please run SPRAWL '96 from a terminal window using\n \
    <tt><b>flatpak run $FLATPAK_ID</b></tt>." --ok-label "Quit" --width=400
fi
