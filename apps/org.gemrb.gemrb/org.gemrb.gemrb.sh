#!/bin/bash
GEMRB_CONFIG_FILE=${XDG_CONFIG_HOME}/gemrb.cfg
if [[ ! -f ${GEMRB_CONFIG_FILE} ]]; then cp /app/etc/gemrb/GemRB.cfg ${GEMRB_CONFIG_FILE}; fi

gemrb -c ${GEMRB_CONFIG_FILE} $@
