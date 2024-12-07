#!/bin/bash
for basefile in /app/extra/prey/base/*; do
    filename=$(basename $basefile)
    if [[ ! -s $XDG_DATA_HOME/base/$filename ]]; then
        echo "Missing $XDG_DATA_HOME/base/$filename; linking from bundled data."
        ln -s $basefile $XDG_DATA_HOME/base/$filename
    fi
done
prey.x86 +set fs_basepath $XDG_DATA_HOME $@
