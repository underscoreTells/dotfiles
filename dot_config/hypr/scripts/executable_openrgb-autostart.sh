#!/usr/bin/env bash

set -Eeuo pipefail

readonly profile="${OPENRGB_PROFILE:-Default}"
readonly initial_delay="${OPENRGB_INITIAL_DELAY:-5}"
readonly retry_delay="${OPENRGB_RETRY_DELAY:-2}"
readonly max_attempts="${OPENRGB_MAX_ATTEMPTS:-4}"
readonly log_dir="${XDG_CONFIG_HOME:-$HOME/.config}/OpenRGB/logs"
readonly success_pattern='Profile loading: Succeeded for Kingston Fury DDR5 DRAM'
readonly failure_pattern='Profile loading: FAILED! for Kingston Fury DDR5 DRAM'

log() {
  printf '[openrgb-autostart] %s\n' "$*" >&2
}

latest_log() {
  shopt -s nullglob
  local logs=("$log_dir"/OpenRGB_*.log)

  if (( ${#logs[@]} == 0 )); then
    return 1
  fi

  ls -1t "${logs[@]}" 2>/dev/null | head -n 1
}

wait_for_profile_result() {
  local -r log_file="$1"
  local seconds=0

  while (( seconds < 12 )); do
    if [[ -f "$log_file" ]]; then
      if grep -qF "$success_pattern" "$log_file"; then
        return 0
      fi

      if grep -qF "$failure_pattern" "$log_file"; then
        return 1
      fi
    fi

    sleep 1
    (( seconds += 1 ))
  done

  return 2
}

main() {
  local openrgb_bin
  openrgb_bin="$(command -v openrgb)"

  local previous_log=""
  previous_log="$(latest_log || true)"

  sleep "$initial_delay"

  local attempt
  for (( attempt = 1; attempt <= max_attempts; attempt += 1 )); do
    "$openrgb_bin" --startminimized --profile "$profile" >/dev/null 2>&1 &
    local openrgb_pid=$!
    log "Attempt ${attempt}/${max_attempts} started OpenRGB (pid ${openrgb_pid})."

    local current_log=""
    local log_wait=0
    while (( log_wait < 10 )); do
      current_log="$(latest_log || true)"
      if [[ -n "$current_log" && "$current_log" != "$previous_log" ]]; then
        break
      fi

      sleep 1
      (( log_wait += 1 ))
    done

    if [[ -z "$current_log" || "$current_log" == "$previous_log" ]]; then
      log "No new OpenRGB log appeared for attempt ${attempt}; treating it as a failed detection."
    elif wait_for_profile_result "$current_log"; then
      log "Kingston Fury DDR5 profile loaded successfully on attempt ${attempt}."
      disown "$openrgb_pid" 2>/dev/null || true
      exit 0
    else
      log "Kingston Fury DDR5 profile did not fully load on attempt ${attempt}."
    fi

    previous_log="$current_log"

    if (( attempt == max_attempts )); then
      log "Keeping the final OpenRGB attempt running after ${max_attempts} tries."
      disown "$openrgb_pid" 2>/dev/null || true
      exit 0
    fi

    kill "$openrgb_pid" 2>/dev/null || true
    wait "$openrgb_pid" 2>/dev/null || true
    sleep "$retry_delay"
  done
}

main "$@"
