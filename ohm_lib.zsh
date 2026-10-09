# shellcheck disable=SC2034,SC2086,SC1090,SC2120,SC2154

uses system_lib.zsh
uses config_lib.zsh

OhmPrefix() {
  printf "\e[91mΩ\e[0m %s" "${1}"
}

# --- persisted settings ($OHM_USER_PATH/config, KEY=value) -------------------------

# OhmConfigGet key [default]
OhmConfigGet() { ConfigGet "${OHM_USER_PATH}/config" "$@"; }

# OhmConfigSet key value
OhmConfigSet() { ConfigSet "${OHM_USER_PATH}/config" "$@"; }

# Apply persisted settings to the environment so every child command inherits them.
# A variable that is already set wins over the config file.
OhmLoadConfig() {
  local spinner theme
  if [[ -z ${TURBO_SPINNER:-} ]]; then
    spinner=$(OhmConfigGet spinner) && [[ -n $spinner ]] && export TURBO_SPINNER=$spinner
  fi
  if [[ -z ${TURBO_THEME:-} ]]; then
    theme=$(OhmConfigGet theme) && [[ -n $theme ]] && export TURBO_THEME=$theme
  fi
  return 0
}

# --- host identity ------------------------------------------------------------------

# The name that host-specific files in user/ are keyed on (init_<user>_<host>, env_<user>_<host>).
# Order: $OHM_HOST, the 'host' config key, then the short hostname. macOS can rename a machine
# when the network changes, so `ohm config init` pins the current name into the config.
OhmHostId() {
  local id=${OHM_HOST:-}
  [[ -n $id ]] || id=$(OhmConfigGet host)
  # The id becomes part of a file name: refuse anything that is not a plain token.
  [[ $id =~ '^[A-Za-z0-9._-]+$' ]] || id=${HOST%%.*}
  [[ -n $id ]] || id=$(hostname -s 2>/dev/null)
  print -rn -- "$id"
}

EnvUserHost() { print -r -- "${OHM_USER_PATH}/env_${USER}_$(OhmHostId)"; }

# --- prompt integration -------------------------------------------------------------------

# OhmMenuWidget: the zle widget behind OHM_MENU_KEY. Opens the menu in --print mode and puts the
# chosen command line on the prompt, where it can be edited and ends up in your history.
OhmMenuWidget() {
  local cmd
  cmd=$(ohm menu --print </dev/tty)
  zle reset-prompt
  [[ -n $cmd ]] && LBUFFER+=$cmd
  return 0
}

# --- plugins ---------------------------------------------------------------------------------
# A plugin is a directory with any of these (all optional):
#   plugin.zsh            shell initialisation, sourced when the plugin is registered
#   menu.zsh              sourced by `ohm menu` to add items (MenuAddItem, MenuGroup, MenuNotice)
#   libexec/ohm-<name>    extra `ohm <name>` commands (core commands always win a name clash)
# Plugins come from $OHM_PLUGIN_PATH (colon separated, exported so `ohm` commands see it) and
# from every directory or symlink in $OHM_USER_PATH/plugins/. Plugin code runs with your
# privileges, like your .zshrc: only register plugins you trust.

# OhmPluginDirs: one plugin directory per line, in order, without duplicates.
OhmPluginDirs() {
  local d
  local -a seen=()
  local -a candidates=("${(@s/:/)${OHM_PLUGIN_PATH:-}}" "${OHM_USER_PATH}"/plugins/*(-/N))
  for d in "${candidates[@]}"; do
    [[ -n $d && -d $d ]] || continue
    (( ${seen[(Ie)${d:A}]} )) && continue
    seen+=("${d:A}")
    print -r -- "$d"
  done
}

# OhmPlugin <dir>: register a plugin and run its plugin.zsh. Safe to call more than once.
# While plugin.zsh runs, OHM_PLUGIN_DIR and OHM_PLUGIN_NAME describe the plugin. Use plain
# assignments (or `typeset -g`) there: a bare `typeset` would be local to this function.
OhmPlugin() {
  local dir=${1:a}
  if [[ -z ${1:-} || ! -d $dir ]]; then
    print -u2 "ohm: plugin directory not found: ${1:-<none>}"
    return 1
  fi
  case ":${OHM_PLUGIN_PATH:-}:" in
    *":${dir}:"*) ;;
    *) export OHM_PLUGIN_PATH="${OHM_PLUGIN_PATH:+${OHM_PLUGIN_PATH}:}${dir}" ;;
  esac
  local OHM_PLUGIN_DIR=$dir OHM_PLUGIN_NAME=${dir:t}
  [[ -f $dir/plugin.zsh ]] && source "$dir/plugin.zsh"
  return 0
}

# OhmLoadPlugins: register everything dropped into $OHM_USER_PATH/plugins (called by init.zsh).
OhmLoadPlugins() {
  local d
  for d in "${OHM_USER_PATH}"/plugins/*(-/N); do
    OhmPlugin "$d"
  done
  return 0
}
