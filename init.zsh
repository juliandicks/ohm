# shellcheck disable=SC2034,SC2086,SC1090,SC2120,SC2154

# Self-contained: sets OHM_PATH / USES_PATH / `uses` even without the ~/.zshenv hook.
# Safe to run more than once.
source ${0:A:h}/init_env.zsh

# source ${OHM_PATH}/version.zsh
uses ohm_lib.zsh

OhmLoadConfig

AddPath "$OHM_PATH/bin"

# Plugins dropped into user/plugins/ (others are registered with OhmPlugin in your init file).
OhmLoadPlugins

SourceIfExists ${OHM_USER_PATH}/init_${USER}
SourceIfExists ${OHM_USER_PATH}/init_${USER}_$(OhmHostId)

# Optional: open the menu from the prompt. Set OHM_MENU_KEY in user/init_<user>, for example:
#   export OHM_MENU_KEY='^G'
# The chosen command is placed on the command line for you to review and run.
if [[ -o interactive && -n ${OHM_MENU_KEY:-} ]]; then
  zle -N OhmMenuWidget 2>/dev/null && bindkey "$OHM_MENU_KEY" OhmMenuWidget
fi
