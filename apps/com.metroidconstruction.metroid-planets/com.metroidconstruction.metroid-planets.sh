#!/bin/bash
MP_DEFAULT="${XDG_CONFIG_HOME}/mp_default"
HIDE_LAUNCHER="${XDG_CONFIG_HOME}/hide_launcher"

function write_version_config {
    if [[ -f ${MP_DEFAULT} ]]; then
      rm "${MP_DEFAULT}"
    fi
    echo "$1" > "${MP_DEFAULT}"
}

if [[ ! -f "${HIDE_LAUNCHER}" ]]; then

  CHOICE=$(zenity --list --radiolist --hide-header --modal --width=600 --height=400 \
    --column="" --column="" \
    TRUE "v1.33 (newer version with full Enigma support)" \
    FALSE "v1.27 (older version including Novum world)" \
    --title "Metroid Planets Launcher" \
    --text "Select which version of the game to launch" \
    --ok-label "Launch" \
    --cancel-label "Quit" \
    --window-icon "/app/share/icons/hicolor/256x256/apps/com.metroidconstruction.metroid-planets.png")

  case "$CHOICE" in
    "v1.33"*)
      write_version_config "133"
      ;;
    "v1.27"*)
      write_version_config "127"
      ;;
    *)
      exit 1
      ;;
  esac
  touch "${HIDE_LAUNCHER}"
fi

exitcode=$?
if [[ $exitcode -ne 0 ]]; then
  echo "Quitting..."
elif [[ $exitcode -eq 0 ]]; then
    if [[ -f "/app/bin/${FLATPAK_ID}.$1.sh" ]]; then
        GAME_VERSION="$1"
        GAME_ARGS="${@:2}"
    else
        GAME_VERSION=$(cat "${MP_DEFAULT}")
        GAME_ARGS="$@"
    fi
    echo "Launching Metroid Planets v${GAME_VERSION}..."
    ${FLATPAK_ID}.${GAME_VERSION}.sh
fi
