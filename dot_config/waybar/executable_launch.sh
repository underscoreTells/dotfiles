#!/bin/sh
# Waybar auto-detect launcher
# - Desktop: use config-desktop.jsonc (both bars)
# - Laptop:  use config-laptop.jsonc (single main bar on any output)
# You can also force a profile by passing "desktop" or "laptop" as the first argument.

set -eu

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
DESKTOP_CFG="$CONFIG_DIR/config-desktop.jsonc"
LAPTOP_CFG="$CONFIG_DIR/config-laptop.jsonc"
STYLE="$CONFIG_DIR/style.css"
WAYBAR_BIN="$CONFIG_DIR/bin/waybar"
WAYBAR_LIB_DIR="$CONFIG_DIR/lib"

# Optional: force profile via first argument
PROFILE="${1:-}"

# Auto-detect when not forced
if [ -z "${PROFILE}" ]; then
  if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
    PROFILE="laptop"
  else
    PROFILE="desktop"
  fi
fi

# Choose config by profile
case "${PROFILE}" in
  laptop) CFG="${LAPTOP_CFG}" ;;
  desktop) CFG="${DESKTOP_CFG}" ;;
  *)
    # Fallback to auto-detect if an unknown profile was provided
    if ls /sys/class/power_supply/BAT* >/dev/null 2>&1; then
      CFG="${LAPTOP_CFG}"
    else
      CFG="${DESKTOP_CFG}"
    fi
    ;;
esac

# Fallback to legacy single config if the selected file doesn't exist
if [ ! -f "${CFG}" ] && [ -f "${CONFIG_DIR}/config.jsonc" ]; then
  CFG="${CONFIG_DIR}/config.jsonc"
fi

# Prefer a locally installed Waybar binary when present.
if [ -x "${WAYBAR_BIN}" ]; then
  WAYBAR_CMD="${WAYBAR_BIN}"
  WAYBAR_ENV="LD_LIBRARY_PATH=${WAYBAR_LIB_DIR}${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
elif command -v waybar >/dev/null 2>&1; then
  WAYBAR_CMD="$(command -v waybar)"
  WAYBAR_ENV=""
else
  printf '%s\n' "waybar not found in PATH; aborting launch." >&2
  exit 0
fi

# Stop existing waybar instances (if any)
if pgrep -x waybar >/dev/null 2>&1; then
  pkill -x waybar || true
  # Allow compositor/monitors to settle
  sleep 0.3
fi

# Start waybar with chosen config and stylesheet
LOG_FILE="${XDG_STATE_HOME:-$HOME/.local/state}/waybar-launch.log"
mkdir -p "$(dirname "${LOG_FILE}")" || true

if [ -n "${WAYBAR_ENV}" ]; then
  nohup env ${WAYBAR_ENV} "${WAYBAR_CMD}" -c "${CFG}" -s "${STYLE}" >>"${LOG_FILE}" 2>&1 &
else
  nohup "${WAYBAR_CMD}" -c "${CFG}" -s "${STYLE}" >>"${LOG_FILE}" 2>&1 &
fi

exit 0
