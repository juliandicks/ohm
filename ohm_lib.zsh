# shellcheck disable=SC2034,SC2086,SC1090,SC2120,SC2154

uses system_lib.zsh

ohm_prefix() {
  printf "\e[91mΩ\e[0m %s" "${1}"
}

env_user_host() { echo ${OHM_USER_PATH}/env_${USER}_${HOST%%.*}; }
