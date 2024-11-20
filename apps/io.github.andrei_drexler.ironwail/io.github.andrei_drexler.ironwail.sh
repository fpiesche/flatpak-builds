#!/bin/bash
IW_EXIT_CODE=0

function check_game_data () {
  if [[ "$1" == "" ]]; then
    zenity --error --ok-label "Quit" --width=400 --text \
    "<b>Could not find Quake game data</b>\n\n Please either install Quake via Steam or copy the game data (at least <tt>pak0.pak</tt>) to <tt><b>$XDG_DATA_HOME/id1/</b></tt>."
    exit 1
  fi
}

function check_exit_code () {
  if [[ "$1" != "0" ]]; then
    zenity --error --ok-label "Quit" --width=400 --text \
      "<b>Ironwail exited with an error</b>\n\n For a detailed error message, please run Ironwail from a terminal window using\n <tt><b>flatpak run $FLATPAK_ID</b></tt>."
    exit 1
  fi
}

echo "Checking ${XDG_DATA_HOME} for Quake game data..."
if [[ -f "$XDG_DATA_HOME/id1/pak0.pak" ]]; then
  QUAKEDIR=$XDG_DATA_HOME
  echo "Found Quake data in $XDG_DATA_HOME!"
  /app/bin/ironwail -basedir $XDG_DATA_HOME "$@"
  check_exit_code $?

# Otherwise, check the Steam libraries
else
  echo "Checking Steam libraries for Quake game data..."
  LIBRARYFOLDERS_VDF_PATH=$(find ~ -ipath "*/config/libraryfolders.vdf")
  LIBRARY_PATHS=$(sed -nE "s:^\s+\"path\"\s+\"(.*)\"$:\1:p" $LIBRARYFOLDERS_VDF_PATH)
  for library in ${LIBRARY_PATHS[@]}; do
    echo "Checking in $library..."
    QUAKEDIR=$(find "$library" -ipath "*/steamapps/common/Quake/id1/pak0.pak" | sed s:/id1/pak0.pak::I)
    if [[ -d "$library" && "${QUAKEDIR}" != "" ]]; then
      echo "Found ${QUAKEDIR}!"
      QUAKEDIR="steam"
      /app/bin/ironwail "$@"
      check_exit_code $?
    fi
  done
fi

check_game_data $QUAKEDIR
