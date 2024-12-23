#!/bin/bash
source scripts/lib/logging.sh

DEFAULT_LOG_LEVEL="INFO"
REPO=""

show_help() {
  cat <<EOF
Usage: $(basename "$0") [OPTIONS]

Options:
  --verbose, -v           Enable verbose logging (DEBUG level).
  --quiet, -q             Enable quiet mode (ERROR level only).
  --repo <path>           Specify the repository path (required).
  --help, -h              Show this help message and exit.

Examples:
  $(basename "$0") --repo /path/to/repo
  $(basename "$0") --verbose --repo /path/to/repo
  $(basename "$0") --quiet --repo /path/to/repo
EOF
}

parse_arguments() {
  for arg in "$@"; do
    case "$arg" in
    --verbose | -v)
      log_set_level "DEBUG"
      ;;
    --quiet | -q)
      log_set_level "ERROR"
      ;;
    --repo)
      shift
      if [[ -n "$1" && "$1" != "--"* ]]; then
        REPO="$1"
      else
        log_error "Missing value for --repo argument."
        exit 1
      fi
      ;;
    --help | -h)
      show_help
      exit 0
      ;;
    *) ;;
    esac
  done
}

log_set_level "$DEFAULT_LOG_LEVEL"

parse_arguments "$@"

if [[ -z "$REPO" ]]; then
  log_error "The --repo argument is required."
  exit 1
fi

log_info "Repository provided: $REPO"

log_info "Adding labels"

create_github_label() {
  local name="$1"
  local color="$2"
  local description="$3"

  log_debug "Checking if REPO environment variable is set."

  if [[ -z "$REPO" ]]; then
    log_error "The REPO environment variable is not set. Please set it to the target repository (e.g., export REPO=user/repo)."
    return 1
  fi

  log_debug "REPO is set to '$REPO'."

  log_debug "Validating arguments: name='$name', color='$color', description='$description'."
  if [[ -z "$name" || -z "$color" || -z "$description" ]]; then
    log_error "All arguments are required: name, color, and description."
    return 1
  fi

  log_debug "Arguments validated successfully."

  log_info "Creating label '$name' in repository '$REPO' with color '$color' and description '$description'."
  log_debug "Running: gh label create '$name' --repo '$REPO' --color '$color' --description '$description'."

  gh label create "$name" \
    --repo "$REPO" \
    --color "$color" \
    --description "$description" \
    --force

  if [[ $? -eq 0 ]]; then
    log_info "Label '$name' created successfully in repository '$REPO'."
  else
    log_error "Failed to create label '$name' in repository '$REPO'."
    log_debug "Command failed. Please verify the REPO environment variable and $(gh) CLI configuration."
    return 1
  fi
}

create_github_label "e0 🌵" "0E8A16" "Low effort"
create_github_label "e1 ⚡️" "FBCA04" "Medium effort"
create_github_label "e2 🔥" "D93F0B" "High effort"
create_github_label "i0 🌵" "0E8A16" "Low impact"
create_github_label "i1 ⚡️" "FBCA04" "Medium impact"
create_github_label "i2 🔥" "D93F0B" "High impact"
