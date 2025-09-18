#!/bin/zsh
# shellcheck disable=SC2154,SC2086

[[ -z $OHM_PATH ]] && source ${0:A:h}/init.zsh

# SET MENU
export MENU_FILE=$OHM_PATH/user/m.mnu

${0:A:h}/menu_zsh/m.sh
