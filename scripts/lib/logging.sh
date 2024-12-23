#!/bin/bash

LOG_LEVEL="INFO"

LOG_LEVELS=("DEBUG" "INFO" "WARN" "ERROR")

COLOR_DEBUG="\033[0;34m" # Blue
COLOR_INFO="\033[0;32m"  # Green
COLOR_WARN="\033[0;33m"  # Yellow
COLOR_ERROR="\033[0;31m" # Red
COLOR_RESET="\033[0m"    # Reset

log_set_level() {
  local level="$1"
  LOG_LEVEL="$level"
}

log_level_index() {
  local level="$1"
  for i in "${!LOG_LEVELS[@]}"; do
    if [[ "${LOG_LEVELS[$i]}" == "$level" ]]; then
      echo "$i"
      return
    fi
  done
  echo "-1"
}

log_should_log() {
  local level="$1"
  local current_index
  local target_index

  current_index=$(log_level_index "$LOG_LEVEL")
  target_index=$(log_level_index "$level")

  [[ "$current_index" -le "$target_index" ]]
}

log_get_color() {
  case "$1" in
  "DEBUG") echo "$COLOR_DEBUG" ;;
  "INFO") echo "$COLOR_INFO" ;;
  "WARN") echo "$COLOR_WARN" ;;
  "ERROR") echo "$COLOR_ERROR" ;;
  *) echo "$COLOR_RESET" ;;
  esac
}

log_message() {
  local level="$1"
  local message="$2"
  local timestamp
  timestamp=$(date '+%Y-%m-%d %H:%M:%S')

  if log_should_log "$level"; then
    local color
    color=$(log_get_color "$level")
    echo -e "[$timestamp] [${color}$level${COLOR_RESET}] $message${COLOR_RESET}"
  fi
}

log_debug() {
  log_message "DEBUG" "$1"
}

log_info() {
  log_message "INFO" "$1"
}

log_warn() {
  log_message "WARN" "$1"
}

log_error() {
  log_message "ERROR" "$1"
}
