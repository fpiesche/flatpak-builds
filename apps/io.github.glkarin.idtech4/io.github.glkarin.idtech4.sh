#!/bin/bash

if [[ ! -z "$@" ]]; then
    $@
    exit 0
fi

CHOICE=$(zenity --list --radiolist --hide-header --modal --width=600 --height=400 \
    --column="" --column="" \
    TRUE "Doom 3" \
    FALSE "Prey" \
    FALSE "Quake 4" \
    --title "idtech4 Launcher" \
    --text "Select which game to launch" \
    --extra-button "Open data directory" \
    --ok-label "Launch" \
    --cancel-label "Quit" \
    --window-icon "/app/share/icons/hicolor/scalable/apps/io.github.glkarin.idtech4.svg")

  case "$CHOICE" in
    "Open data directory")
      xdg-open $XDG_DATA_HOME
      exit 2
      ;;
    "Doom 3"*)
      io.github.glkarin.idtech4.doom3.sh
      ;;
    "Prey"*)
      io.github.glkarin.idtech4.prey.sh
      ;;
    "Quake 4"*)
      io.github.glkarin.idtech4.quake4.sh
      ;;
    *)
      exit 1
      ;;
  esac
fi
