# shellcheck disable=SC2034,SC2086,SC1090,SC2120,SC2154

ohm_prefix() {
  printf "\e[91mΩ\e[0m %s" "${1}"
}

# maybe_source <file>
# Sources the given file if it exists.
source_if_exists() {
  [[ -f "$1" ]] && source $1
}

# add_path <dir>
# Safely appends <dir> to $PATH only if it is not already present.
add_path() {
  case ":$PATH:" in
    *":$1:"*) ;; # already there, do nothing
    *) PATH="$PATH:$1" ;;
  esac
  export PATH
}

# insert_path <dir>
# Safely prepends <dir> to $PATH only if it is not already present.
insert_path() {
  case ":$PATH:" in
    *":$1:"*) ;; # already there, do nothing
    *) PATH="$1:$PATH" ;;
  esac
  export PATH
}

# and this is where we begin.

export OHM_PATH=${0:A:h}
add_path "$OHM_PATH"

source_if_exists ${OHM_PATH}/USER/lib_${USER}
source_if_exists ${OHM_PATH}/USER/lib_${USER}_${HOST%%.*}
