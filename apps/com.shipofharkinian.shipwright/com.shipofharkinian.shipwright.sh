#!/bin/bash
PORT_VER=$1
ASSETGEN_TEMPDIR="$XDG_DATA_HOME/.assetgen_temp"
if [[ ! -d "$XDG_DATA_HOME/mods" ]]; then mkdir -p "$XDG_DATA_HOME"/mods; fi
if [[ -d "$ASSETGEN_TEMPDIR" ]]; then rm -rf "$ASSETGEN_TEMPDIR"; fi

while [[ (! -e "$XDG_DATA_HOME"/oot.otr) || (! -e "$XDG_DATA_HOME"/oot-mq.otr) ]]; do
  for romfile in "$XDG_DATA_HOME"/*.?64; do
    mkdir -p "$ASSETGEN_TEMPDIR"
    ROMHASH=$(sha1sum -b "$romfile" | awk '{ print $1 }')

    OTRFILE="${XDG_DATA_HOME}/oot.otr"
    case "$ROMHASH" in
      a9059b56e761c9034fbe02fe4c24985aaa835dac|\
      24708102dc504d3f375a37f4ae4e149c167dc515)
        if [[ ! -e "$XDG_DATA_HOME"/oot.otr ]]; then
          ROM=GC_NMQ_D
        else
          continue
        fi
        ;;
      580dd0bd1b6d2c51cc20a764eece84dba558964c|\
      d6342c59007e57c1194661ec6880b2f078403f4e)
        if [[ ! -e "$XDG_DATA_HOME"/oot.otr ]]; then
          ROM=GC_NMQ_PAL_F
        else
          continue
        fi
        ;;
      d0bdc2eb320668b4ba6893b9aefe4040a73123ff|\
      4946ab250f6ac9b32d76b21f309ebb8ebc8103d2)
        if [[ ! -e "$XDG_DATA_HOME"/oot.otr ]]; then
          ROM=N64_PAL_10
        else
          continue
        fi
        ;;
      663c34f1b2c05a09e5beffe4d0dcd440f7d49dc7|\
      24c73d378b0620a380ce5ef9f2b186c6c157a68b)
        if [[ ! -e "$XDG_DATA_HOME"/oot.otr ]]; then
          ROM=N64_PAL_11
        else
          continue
        fi
        ;;
      8ebf2e29313f44f2d49e5b4191971d09919e8e48|\
      4264bf7b875737b8fae77d52322a5099d051fc11)
        if [[ ! -e "$XDG_DATA_HOME"/oot-mq.otr ]]; then
          ROM=GC_MQ_PAL_F
          OTRFILE="${XDG_DATA_HOME}/oot-mq.otr"
        else
          continue
        fi
        ;;
      973bc6fe56010a8d646166a1182a81b4f13b8cf9|\
      d327752c46edc70ff3668b9514083dbbee08927c|\
      ecdeb1747560834e079c22243febea7f6f26ba3b|\
      f19f8662ec7abee29484a272a6fda53e39efe0f1|\
      ab519ce04a33818ce2c39b3c514a751d807a494a|\
      c19a34f7646305e1755249fca2071e178bd7cd00|\
      25e8ae79ea0839ca5c984473f7460d8040c36f9c|\
      166c02770d67fcc3954c443eb400a6a3573d3fc0)
        if [[ ! -e "$XDG_DATA_HOME"/oot-mq.otr ]]; then
          ROM=GC_MQ_D
          OTRFILE="${XDG_DATA_HOME}/oot-mq.otr"
        else
          continue
        fi
        ;;
      *)
        echo "$romfile - unknown rom hash $ROMHASH"
        continue
        ;;
    esac

    if [[ ! -e "$XDG_DATA_HOME"/"$OTRNAME" ]]; then
      zenity --progress --title="Generating OTR for v$(cat /app/usr/assets/port_version)..." \
        --timeout=10 --percentage=0 --icon-name=com.shipofharkinian.shipwright \
        --window-icon=soh.png --height=80 --width=400 &
      zapd ed -eh -i "/app/usr/assets/extractor/xmls/${ROM}" \
        -b $romfile -fl /app/usr/assets/extractor/filelists -o placeholder \
        -osf placeholder -gsf 1 -rconf "/app/usr/assets/extractor/Config_${ROM}.xml" \
        -se OTR --otrfile "${OTRFILE}" --portVer "$(cat /app/usr/assets/port_version)"
        # mv "$ASSETGEN_TEMPDIR/$OTRNAME" "$XDG_DATA_HOME"
    elif [[ (! -e "$XDG_DATA_HOME"/oot.otr) && (! -e "$XDG_DATA_HOME"/oot-mq.otr) ]]; then
      zenity --error --timeout=5 --text="Place ROM in $XDG_DATA_HOME" \
        --title="Missing ROM file" --width=500 --width=200
      exit 1
    fi
  done
  if [[ (! -e "$XDG_DATA_HOME"/oot.otr) && (! -e "$XDG_DATA_HOME"/oot-mq.otr) ]]; then
    zenity --error --timeout=10 --width=500 --width=200 \
      --text="No valid ROMs were provided, No OTR was generated." \
      --title="Incorrect ROM file"
    rm -r "$ASSETGEN_TEMPDIR"
    exit 1
  else
    soh
  fi
  rm -r "$ASSETGEN_TEMPDIR"
done

soh
