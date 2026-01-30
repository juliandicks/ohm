# shellcheck disable=SC2034,SC2086,SC1090,SC2120,SC2154

export OHM_PATH=${0:A:h}

source ${OHM_PATH}/init_lib.zsh

add_path "$OHM_PATH"
export OHM_USER_PATH=${0:A:h}/user

source_if_exists ${OHM_USER_PATH}/init_${USER}
source_if_exists ${OHM_USER_PATH}/init_${USER}_${HOST%%.*}
