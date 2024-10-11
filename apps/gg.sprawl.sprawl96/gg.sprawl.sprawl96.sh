#!/bin/bash
INSTALL_TEMP_DIR=$XDG_DATA_HOME/.install_tmp
LIBREQUAKE_RELEASE_URL=https://api.github.com/repos/lavenderdotpet/librequake/releases/latest
LIBREQUAKE_VERSION_FILE=$XDG_DATA_HOME/id1/.librequake_release
SPRAWL_MOD_URL=https://www.slipseer.com/index.php?resources/sprawl-96.398/history
SPRAWL96_VERSION_FILE=$XDG_DATA_HOME/sprawl/.sprawl96_release

download_file () {
    FILE_URL=$1
    TARGET_DIR=$2
    PACKAGE_NAME=$3
    echo "Downloading $FILE_URL to $TARGET_DIR..."
    if [[ -f $INSTALL_TEMP_DIR/downloaded_file.zip ]]; then rm $INSTALL_TEMP_DIR/downloaded_file.zip; fi
    wget $FILE_URL -O $INSTALL_TEMP_DIR/downloaded_file.zip 2>&1 \
        | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, ETA \3/' \
        | zenity --progress --auto-close --auto-kill --pulsate --width=400 \
            --title="Downloading $PACKAGE_NAME..." --text="Downloading..."
    echo "Installing $PACKAGE_NAME to $XDG_DATA_HOME/$TARGET_DIR..."
    mkdir -p $INSTALL_TEMP_DIR
    unzip -d $INSTALL_TEMP_DIR $INSTALL_TEMP_DIR/downloaded_file.zip
    if [[ $? == 0 ]]; then
        PACKAGE_DIR=$(dirname $(find $INSTALL_TEMP_DIR -iname "pak0.pak"))
        mv $PACKAGE_DIR/* $TARGET_DIR
    else
        zenity --error --title="Download failed" \
            --text="The downloaded file <tt>$FILE_URL</tt> failed to unzip. \
Please try again or manually download and extract its contents to $TARGET_DIR."
        rm -rf $INSTALL_TEMP_DIR $XDG_DATA_HOME/wget
        exit 1
    fi

    rm -rf $INSTALL_TEMP_DIR $XDG_DATA_HOME/wget
}

verify_quake_data () {
    if [[ ! $(find $XDG_DATA_HOME/id1/ -iname "pak0.pak") ]]; then
        zenity --warning --width=400 \
            --title="No Quake game data found" \
            --text="Please note that SPRAWL 96 requires base game data from Quake or LibreQuake to run.\n\n \
Please either copy the <tt><b>id1</b></tt> directory from a Quake installation or LibreQuake to \
<tt><b>$XDG_DATA_HOME</b></tt> or restart and download LibreQuake from here."
        exit 1
    fi
}

verify_sprawl_data () {
    if [[ ! $(find $XDG_DATA_HOME/sprawl/ -iname "pak0.pak") ]]; then
        zenity --warning --width=400 \
            --title="SPRAWL 96 data not found" \
            --text="SPRAWL 96 data has not been installed in <tt><b>$XDG_DATA_HOME/sprawl/</b></tt>.\n\n \
Please either manually download the mod and copy the contents of the <tt><b>sprawl</b></tt> directory \
to <tt><b>$XDG_DATA_HOME/sprawl/</b></tt> or restart and download the latest release from here."
        exit 1
    fi
}

update_librequake () {
    if [[ $(find $XDG_DATA_HOME/id1/ -iname "pak0.pak") && ! -f $LIBREQUAKE_VERSION_FILE ]]; then
        echo "$XDG_DATA_HOME/id1/pak0.pak exists but has no LibreQuake version file."
        echo "Assuming this is regular Quake data and skipping LibreQuake update check."
        return
    elif [[ -f $XDG_DATA_HOME/id1/.disable_update_check ]]; then
        echo "$XDG_DATA_HOME/id1/.disable_update_check exists; not checking for LibreQuake updates."
        return
    fi

    # get the latest LibreQuake version number
    LATEST_LIBREQUAKE_VERSION=$(curl -LsH 'Accept: application/json' \
                                $LIBREQUAKE_RELEASE_URL \
                                | grep -i "tag_name" \
                                | awk -F '"' '{print $4}')
    echo "Latest LibreQuake release is $LATEST_LIBREQUAKE_VERSION."

    # Compare to the local version number from the $LIBREQUAKE_VERSION_FILE
    LOCAL_LIBREQUAKE_VERSION=$(cat $LIBREQUAKE_VERSION_FILE)
    if [[ -z $LOCAL_LIBREQUAKE_VERSION || ! $(find $XDG_DATA_HOME/id1 -iname "pak0.pak") ]]; then
        LOCAL_LIBREQUAKE_VERSION="none"
    fi
    echo "Installed LibreQuake version is $LOCAL_LIBREQUAKE_VERSION."

    if [[ "$LOCAL_LIBREQUAKE_VERSION" != "$LATEST_LIBREQUAKE_VERSION" ]]; then
        selection=$(zenity --question --width=400 --title="LibreQuake update available" \
    --text "The latest release of LibreQuake is $LATEST_LIBREQUAKE_VERSION; you currently have \
$LOCAL_LIBREQUAKE_VERSION installed. Do you want to update?" \
    --extra-button="No, don't ask again" \
    --extra-button="No" \
    --extra-button="Update LibreQuake" --switch)
        case $selection in
            "Update LibreQuake")
                download_file \
                    "https://github.com/lavenderdotpet/LibreQuake/releases/download/$LATEST_LIBREQUAKE_VERSION/full.zip" \
                    $XDG_DATA_HOME/id1 \
                    "LibreQuake game data"
                rm $LIBREQUAKE_VERSION_FILE
                echo $LATEST_LIBREQUAKE_VERSION > $LIBREQUAKE_VERSION_FILE
                ;;
            "No, don't ask again")
                mkdir -p $XDG_DATA_HOME/id1
                touch $XDG_DATA_HOME/id1/.disable_update_check
                ;;
        esac
    fi
}

update_sprawl () {
    # if the .disable_update_check file exists in the sprawl folder, return
    if [[ -f $XDG_DATA_HOME/sprawl/.disable_update_check ]]; then
        echo "$XDG_DATA_HOME/sprawl/.disable_update_check exists; not checking for SPRAWL 96 updates."
        return
    fi

    # get the latest SPRAWL 96 version number
    LATEST_SPRAWL96_VERSION=$(curl -Ls $SPRAWL_MOD_URL \
                                | grep -Po "\/version\/(\d+)\/download" \
                                | awk -F '/' '{print $3}')
    echo "Latest SPRAWL 96 version is $LATEST_SPRAWL96_VERSION."

    # Compare to the local version number from the $SPRAWL96_VERSION_FILE
    LOCAL_SPRAWL96_VERSION=$(cat $SPRAWL96_VERSION_FILE)
    if [[ -z $LOCAL_SPRAWL96_VERSION  || ! $(find $XDG_DATA_HOME/sprawl -iname "pak0.pak") ]]; then
        LOCAL_SPRAWL96_VERSION="none"
    fi
    echo "Installed SPRAWL 96 version is $LOCAL_SPRAWL96_VERSION."

    if [[ "$LOCAL_SPRAWL96_VERSION" != "$LATEST_SPRAWL96_VERSION" ]]; then
        selection=$(zenity --question --width=400 --title="SPRAWL 96 update available" \
    --text "The latest release of SPRAWL 96 is v$LATEST_SPRAWL96_VERSION; you currently have \
$LOCAL_SPRAWL96_VERSION installed. Do you want to update?" \
    --extra-button="No, don't ask again" \
    --extra-button="No" \
    --extra-button="Update SPRAWL 96" --switch)
        case $selection in
            "Update SPRAWL 96")
                download_file \
                    "https://slipseer.com/index.php?resources/sprawl-96.398/version/$LATEST_SPRAWL96_VERSION/download" \
                    $XDG_DATA_HOME/sprawl \
                    "SPRAWL 96 game data"
                rm $SPRAWL96_VERSION_FILE
                echo $LATEST_SPRAWL96_VERSION > $SPRAWL96_VERSION_FILE
                ;;
            "No, don't ask again")
                mkdir -p $XDG_DATA_HOME/sprawl
                touch $XDG_DATA_HOME/sprawl/.disable_update_check
                ;;
        esac
    fi
}

update_librequake
verify_quake_data
update_sprawl
verify_sprawl_data

/app/bin/ironwail -basedir $XDG_DATA_HOME +game sprawl "$@"

if [[ "$?" != "0" ]]; then
    zenity --error --width=400 --title "SPRAWL 96 exited with an error" \
    --text "For a detailed error message, please run SPRAWL 96 from a terminal window using\n \
    <tt><b>flatpak run $FLATPAK_ID</b></tt>." --ok-label "Quit"
fi
