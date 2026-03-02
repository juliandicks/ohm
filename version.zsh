# version.zsh — Ohm version information
# shellcheck disable=SC2034

export OHM_VERSION="0.1.0"
export OHM_VERSION_DATE="2026-01-30"
export OHM_VERSION_NAME="Genesis"

# Check if there are pending updates from upstream
# Returns: 0 if up to date, 1 if updates available, 2 if unable to check
ohm_check_updates() {
  local remote_branch local_hash remote_hash

  # Silently fetch latest from origin (timeout after 5 seconds)
  # Disable job control temporarily to suppress messages
  setopt local_options no_monitor

  git -C "${OHM_PATH}" fetch origin --quiet 2>/dev/null &
  local fetch_pid=$!

  # Wait for fetch with timeout
  local count=0
  while kill -0 $fetch_pid 2>/dev/null; do
    sleep 0.1
    ((count++))
    (( count > 50 )) && { kill $fetch_pid 2>/dev/null; return 2; }
  done
  wait $fetch_pid 2>/dev/null

  # Get current branch
  remote_branch=$(git -C "${OHM_PATH}" rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null) || return 2

  # Compare local and remote hashes
  local_hash=$(git -C "${OHM_PATH}" rev-parse HEAD 2>/dev/null) || return 2
  remote_hash=$(git -C "${OHM_PATH}" rev-parse "${remote_branch}" 2>/dev/null) || return 2

  [[ "$local_hash" == "$remote_hash" ]] && return 0 || return 1
}

# Display version information
ohm_version() {
  source ${OHM_PATH}/banner.zsh
  echo ""
  echo "  Version: ${OHM_VERSION} (${OHM_VERSION_NAME})"
  echo "     Date: ${OHM_VERSION_DATE}"
  echo "     Path: ${OHM_PATH}"

  # Check for updates
  ohm_check_updates
  case $? in
    0) echo "  Updates: ✓ No" ;;
    1) echo "  Updates: ✗ Updates available (run 'update')" ;;
    2) echo "  Updates: ? Unable to check" ;;
  esac
  echo ""
}
