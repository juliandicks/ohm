# shellcheck disable=SC2034,SC2086,SC1090,SC2120,SC2154

# source ${OHM_PATH}/version.zsh
uses ohm_lib.zsh

AddPath "$OHM_PATH/bin"

export OHM_USER_PATH=${0:A:h}/user

SourceIfExists ${OHM_USER_PATH}/init_${USER}
SourceIfExists ${OHM_USER_PATH}/init_${USER}_${HOST%%.*}
