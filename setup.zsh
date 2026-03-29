#!/bin/zsh
# shellcheck disable=SC2154,SC2086,SC2088

set -u

MY_PATH=${0:A:h}
DEPS=(menu_zsh turbo_zsh)
MODE="install"
ASSUME_YES=0
EDIT_SHELL=1
OFFLINE=0

info() {
  printf "\e[93;44;1m Ω \033[97;22m%s\033[K\033[0m\n" "$1"
}

warn() {
  printf "\e[30;103m ! \033[30;22m%s\033[K\033[0m\n" "$1"
}

fail() {
  printf "\e[97;41;1m ✗ \033[97;22m%s\033[K\033[0m\n" "$1" >&2
}

ask_yes_no() {
  local prompt=$1
  (( ASSUME_YES == 1 )) && return 0
  [[ ! -t 0 ]] && return 1
  printf "%s [y/N] " "$prompt"
  local ans
  read -r ans
  [[ "$ans" == "y" || "$ans" == "Y" ]]
}

show_help() {
  cat <<EOF
Usage: ./setup [OPTIONS]

Install and configure ohm.

Options:
  --fresh            Re-clone dependencies (existing dirs are backed up)
  --update           Pull latest changes for existing git dependencies
  --offline          Do not use network operations (clone/pull/fetch)
  --yes, -y          Non-interactive; accept recommended prompts
  --no-shell-edit    Do not modify ~/.zshrc
  -h, --help         Show this help

Examples:
  ./setup
  ./setup --update
  ./setup --fresh --yes
  ./setup --offline --no-shell-edit
EOF
}

parse_options() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --fresh)
        MODE="fresh"
        shift
        ;;
      --update)
        MODE="update"
        shift
        ;;
      --offline)
        OFFLINE=1
        shift
        ;;
      --yes|-y)
        ASSUME_YES=1
        shift
        ;;
      --no-shell-edit)
        EDIT_SHELL=0
        shift
        ;;
      -h|--help)
        show_help
        exit 0
        ;;
      *)
        fail "Unknown option: $1"
        show_help
        exit 1
        ;;
    esac
  done
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    fail "Missing required command: $1"
    return 1
  }
}

preflight() {
  info "Preflight checks"
  require_cmd zsh || exit 2
  require_cmd git || exit 2

  if [[ "${TERM:-}" == "dumb" ]]; then
    warn "TERM=dumb; UI output may not render correctly."
  fi
}

backup_if_exists() {
  local dir=$1
  [[ -e "$dir" ]] || return 0

  local stamp
  stamp=$(date +%Y%m%d%H%M%S)
  local backup="${dir}.bak.${stamp}"
  mv "$dir" "$backup"
  warn "Backed up $dir -> $backup"
}

clone_dep() {
  local dep=$1
  local target="${MY_PATH}/${dep}"
  local url="https://github.com/juliandicks/${dep}.git"

  if (( OFFLINE == 1 )); then
    warn "Offline mode: cannot clone missing dependency $dep"
    return 1
  fi

  info "Cloning $dep"
  git clone "$url" "$target" || return 1
}

pull_dep() {
  local dep=$1
  local target="${MY_PATH}/${dep}"
  [[ -d "$target/.git" ]] || return 1

  if (( OFFLINE == 1 )); then
    warn "Offline mode: skipping update for $dep"
    return 0
  fi

  info "Updating $dep"
  git -C "$target" pull --ff-only || return 1
}

pull_self_repo() {
  local target="${MY_PATH}"
  [[ -d "$target/.git" ]] || return 0

  if (( OFFLINE == 1 )); then
    warn "Offline mode: skipping update for ohm"
    return 0
  fi

  info "Updating ohm"
  git -C "$target" pull --ff-only || return 1
}

ensure_dependencies() {
  info "Ensuring dependencies (${MODE})"

  if [[ "$MODE" == "update" ]]; then
    pull_self_repo || return 1
  fi

  local dep target
  for dep in "${DEPS[@]}"; do
    target="${MY_PATH}/${dep}"
    case "$MODE" in
      fresh)
        [[ -e "$target" ]] && backup_if_exists "$target"
        [[ -d "$target/.git" ]] || clone_dep "$dep" || return 1
        ;;
      update)
        if [[ -d "$target/.git" ]]; then
          pull_dep "$dep" || return 1
        elif [[ -e "$target" ]]; then
          fail "$dep exists but is not a git checkout: $target"
          return 1
        else
          clone_dep "$dep" || return 1
        fi
        ;;
      install)
        if [[ -d "$target/.git" || -d "$target" ]]; then
          info "$dep present"
        else
          clone_dep "$dep" || return 1
        fi
        ;;
    esac
  done
}

append_shell_hook() {
  (( EDIT_SHELL == 1 )) || return 0

  local zshrc="${HOME}/.zshrc"
  local hook_turbo="source ${MY_PATH}/init.zsh"

  [[ -f "$zshrc" ]] || touch "$zshrc"
  grep -Fq "$hook_turbo" "$zshrc" && {
    info "~/.zshrc already includes ohm"
    return 0
  }

  source ${MY_PATH}/init.zsh

  if ask_yes_no "Append ohm startup line to ${zshrc}?"; then
    printf "\n# ohm\n%s\n" "$hook_turbo" >> "$zshrc"
    info "Added shell hook_turbo to ${zshrc}"
  else
    warn "Skipped shell hook_turbo update. Add this manually:"
    echo "  $hook_turbo"
  fi
}

configure_zshenv() {
  (( EDIT_SHELL == 1 )) || return 0

  local zshenv="${HOME}/.zshenv"
  local hook_ohm="source ${MY_PATH}/init_env.zsh"

  [[ -f "$zshenv" ]] || touch "$zshenv"


  grep -Fq "$hook_ohm" "$zshenv" && {
    info "~/.zshenv already includes ohm environment"
    return 0
  }

  source ${MY_PATH}/init_env.zsh

  if ask_yes_no "Append ohm startup line to ${zshenv}?"; then
    printf "\n# ohm environment\n%s\n" "$hook_ohm" >> "$zshenv"
    info "Added ohm hook to ${zshenv}"
  else
    warn "Skipped .zshenv update. Add this manually:"
    echo "  $hook_ohm"
  fi
}

run_doctor() {
  info "Running post-install checks"
  "${MY_PATH}/ohm" doctor || return 1
}

main() {
  parse_options "$@"
  source "${MY_PATH}/ohm_banner"
  info "SETUP"
  preflight
  ensure_dependencies
  configure_zshenv
  append_shell_hook
  run_doctor
  info "Done. Restart shell and run: m"
}

main "$@"
