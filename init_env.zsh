export OHM_PATH=${0:A:h}

# Personal config directory (user/ by default). Set OHM_USER_PATH beforehand to relocate it.
export OHM_USER_PATH=${OHM_USER_PATH:-${OHM_PATH}/user}

# Colour themes defined as files in user/themes/ are visible to every ohm process.
export TURBO_THEME_PATH=${TURBO_THEME_PATH:-${OHM_USER_PATH}/themes}

source ${OHM_PATH}/turbo_zsh/init_env.zsh

AddSearchPathToUses "${OHM_PATH}"
