#!/bin/zsh
# shellcheck disable=SC2154,SC2086

source $OHM_PATH/init_lib.zsh

export MENU_FILE=$OHM_PATH/user/m.mnu

${0:A:h}/menu_zsh/m.sh
