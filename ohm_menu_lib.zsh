# shellcheck disable=SC2034,SC2154,SC2296,SC2206

# Menu providers for `ohm menu`. Each provider fills turbo_zsh's menu_lib with MenuAddItem,
# MenuGroup and MenuNotice; menu_lib stores everything sanitized and runs commands as argv.

uses menu_lib.zsh
uses string_lib.zsh

# --- mise tasks -------------------------------------------------------------------------------
# `mise tasks ls --json` already knows the tasks for the current directory (it merges parent
# configs), their descriptions, dependencies and the commands they run. A task named
# "db:migrate" becomes the item "migrate" in the group "db".

# _OhmMenuMiseExplain: `mise tasks ls` failed; say why without ever trusting anything ourselves.
_OhmMenuMiseExplain() {
  local msg
  local -a lines
  msg=$(mise tasks ls --json 2>&1 >/dev/null)
  lines=("${(@f)msg}")
  if [[ ${(L)msg} == *trust* ]]; then
    MenuNotice "mise: this directory's config is not trusted. Read it, then run: mise trust"
  else
    MenuNotice "mise: could not list tasks (${lines[1]:-no message})"
  fi
}

# OhmMenuMise [--all]
OhmMenuMise() {
  local all=${1:-}
  command -v mise >/dev/null 2>&1 || return 0
  if ! command -v jq >/dev/null 2>&1; then
    MenuNotice "mise tasks need jq (brew install jq)"
    return 0
  fi

  local json
  json=$(mise tasks ls --json ${all:+--all} 2>/dev/null) || { _OhmMenuMiseExplain; return 0; }
  [[ -n $json ]] || return 0

  # @tsv escapes tabs, newlines and backslashes inside values, so one task is exactly one line.
  local prog='.[]
    | select((.hide // false) | not)
    | [ .name,
        (.description // ""),
        (.source // ""),
        (.dir // ""),
        ((.depends // []) | map(tostring) | join(", ")),
        ((.run // []) | map(if type == "string" then . else tojson end) | join(" ⏎ ")),
        (if ((.usage // "") | length) > 0 then "1" else "0" end)
      ] | @tsv'
  local rows
  rows=$(jq -r "$prog" <<<"$json" 2>/dev/null) || { MenuNotice "mise: unreadable task list"; return 0; }

  local line name desc src dir deps runs usage label ipath seg
  local -a f segs opts
  local -i skipped=0
  for line in "${(@o)${(f)rows}}"; do
    [[ -n $line ]] || continue
    f=("${(@ps:\t:)line}")
    name=${f[1]-} desc=${f[2]-} src=${f[3]-} dir=${f[4]-} deps=${f[5]-} runs=${f[6]-} usage=${f[7]-}

    # A name that starts with "-" would be read by mise as an option, and one containing
    # control characters or escapes cannot be shown or run reliably. Skip both.
    _StripControl "$name"
    if [[ -z $name || $name == -* || $name == *\\* || $REPLY != "$name" ]]; then
      (( skipped++ ))
      continue
    fi

    # "a:b:c" -> group a/b, label c ("/" inside a segment is made harmless)
    segs=("${(@s.:.)name}")
    segs=("${(@)segs:#}")
    (( ${#segs} )) || { (( skipped++ )); continue; }
    segs=("${(@)segs//\//∕}")
    label=${segs[-1]}
    ipath=${(j:/:)segs[1,-2]}

    # undo @tsv's escaping, then show newlines as spaces
    desc=${desc//\\n/ }; desc=${desc//\\t/ }; desc=${desc//\\r/ }; desc=${desc//\\\\/\\}
    runs=${runs//\\n/ }; runs=${runs//\\t/ }; runs=${runs//\\r/ }; runs=${runs//\\\\/\\}

    opts=(-p "$ipath" -l "$label" -c "$PWD" -s "${${src/#$PWD\//}/#$HOME/\~}")
    [[ -n $desc ]] && opts+=(-d "$desc")
    [[ -n $deps ]] && opts+=(-m "Depends: $deps")
    [[ -n $runs ]] && opts+=(-m "Runs: $runs")
    [[ -n $dir && $dir != "$PWD" ]] && opts+=(-m "Directory: ${${dir/#$PWD\//}/#$HOME/\~}")
    [[ $usage == 1 ]] && opts+=(-a)

    MenuAddItem "${opts[@]}" -- mise run "$name"
  done

  (( skipped )) && MenuNotice "mise: skipped ${skipped} task(s) with unusable names"
  return 0
}

# --- personal menu: user/m.mnu ---------------------------------------------------------------
# The file uses the format from the README: items are associative arrays
#   typeset -A mi_x=([l]="[S]ys Info" [k]=s [c]="_popup ohm sysinfo")
# [l] label ([X] marks the hotkey), [k] hotkey, [c] command, [d]=1 always ask before running. Top-level entries named mnu_* open a
# sub-menu through a loader function that fills `menu` and `menuTitle`.
# Commands become argv. A command that uses shell operators (; | && > ...) runs through eval,
# but only because the file is yours: it is sourced like your .zshrc.

# _OhmMenuLegacyParse name -> sets label, key, danger, words (caller's variables); returns 1 if unusable
_OhmMenuLegacyParse() {
  local name=$1 raw k cmd w
  [[ $name =~ '^[A-Za-z_][A-Za-z0-9_]*$' ]] || return 1
  typeset -p "$name" >/dev/null 2>&1 || return 1
  [[ ${(Pt)name} == association* ]] || return 1
  local -A it=("${(@kvP)name}")

  raw=${it[l]-}
  k=${it[k]-}
  label=$raw
  if [[ $raw =~ '\[(.)\]' ]]; then
    [[ -n $k ]] || k=$match[1]
    label="${raw[1,MBEGIN-1]}${match[1]}${raw[MEND+1,-1]}"
  fi
  key=$k
  danger=0
  [[ ${(L)it[d]-} == (1|y|yes|true) ]] && danger=1

  cmd=${it[c]-}
  [[ -n $cmd ]] || return 1
  local -a toks=(${(z)cmd})
  case ${(Q)toks[1]} in _popup|_cmd) toks=("${(@)toks[2,-1]}") ;; esac
  (( ${#toks} )) || return 1

  local shell=0
  for w in "${toks[@]}"; do
    case $w in ';'|'|'|'||'|'&'|'&&'|'<'|'>'|'>>'|'('|')') shell=1 ;; esac
  done
  if (( shell )); then
    words=(eval "${(j: :)toks}")
  else
    words=("${(@Q)toks}")
  fi
  return 0
}

# _OhmMenuLegacyAdd name group-path
_OhmMenuLegacyAdd() {
  local label key danger
  local -a words opts
  _OhmMenuLegacyParse "$1" || return 0
  opts=(-p "$2" -l "$label" -k "$key" -c "$PWD" -s "$_ohm_menu_src")
  (( danger )) && opts+=(-D)
  MenuAddItem "${opts[@]}" -- "${words[@]}"
}

# OhmMenuUser: compile $MENU_FILE (default user/m.mnu) into menu items
OhmMenuUser() {
  local file=${MENU_FILE:-${OHM_USER_PATH}/m.mnu}
  [[ -f $file ]] || return 0
  local _ohm_menu_src=${file/#$HOME/\~}

  # Declared here so the file's own `typeset -a topMenu menu` and the loaders it defines
  # assign to these (dynamic scope) instead of leaking globals.
  local -a topMenu=() menu=()
  local menuTitle=""
  if ! zsh -n "$file" 2>/dev/null; then
    MenuNotice "${_ohm_menu_src} has a syntax error and was skipped"
    return 0
  fi
  # No status check: menu files end by calling a loader, and loaders return 255 by convention.
  source "$file" >/dev/null

  local entry label key gpath item danger
  local -a words items
  if (( ${#topMenu} )); then
    for entry in "${topMenu[@]}"; do
      label="" key="" words=()
      _OhmMenuLegacyParse "$entry" || continue
      if [[ $entry == mnu_* && ${#words} -eq 1 ]] && (( $+functions[${words[1]}] )); then
        # a sub-menu: the loader fills `menu` (and returns 255 by convention)
        menu=(); menuTitle=""
        "${words[1]}" >/dev/null 2>&1
        items=("${menu[@]}")
        _StripControl "${label//\//∕}"; gpath=$REPLY
        [[ -n $gpath ]] || continue
        MenuGroup -p "$gpath" -l "$gpath" -k "$key"
        for item in "${items[@]}"; do _OhmMenuLegacyAdd "$item" "$gpath"; done
      else
        _OhmMenuLegacyAdd "$entry" ""
      fi
    done
  else
    for item in "${menu[@]}"; do _OhmMenuLegacyAdd "$item" ""; done
  fi
  return 0
}

# --- plugins ----------------------------------------------------------------------------------
# Each plugin's menu.zsh is sourced and calls MenuAddItem / MenuGroup / MenuNotice itself. It runs
# in this process (plugin code is trusted like your .zshrc), so the functions it defines are still
# there when its items run. A plugin that fails to load costs only its own items.

# OhmMenuPlugins
OhmMenuPlugins() {
  local d file
  local OHM_PLUGIN_DIR OHM_PLUGIN_NAME
  for d in ${(f)"$(OhmPluginDirs)"}; do
    file="$d/menu.zsh"
    [[ -f $file ]] || continue
    OHM_PLUGIN_DIR=${d:a}
    OHM_PLUGIN_NAME=${d:t}
    if ! zsh -n "$file" 2>/dev/null; then
      MenuNotice "plugin ${OHM_PLUGIN_NAME}: menu.zsh has a syntax error and was skipped"
      continue
    fi
    # No status check: a plugin may end with a command that returns non-zero.
    source "$file" >/dev/null
  done
  return 0
}
