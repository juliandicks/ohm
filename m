#!/bin/zsh
# shellcheck disable=SC2154,SC2086

: "${OHM_PATH:?OHM_PATH is not set. Source init.zsh first.}"; source "${OHM_PATH}/init_lib.zsh" || { print -u2 -- "Failed to source ${OHM_PATH}/init_lib.zsh"; exit 1; }

export MENU_FILE=$OHM_PATH/user/m.mnu

${0:A:h}/menu_zsh/m.sh
