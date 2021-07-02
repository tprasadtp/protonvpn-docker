#!/usr/bin/env bash
# Copyright (c) 2021. Prasad Tengse
#
# shellcheck disable=SC2155,SC2034

set -o pipefail

# Script Constants
readonly CURDIR="$(cd -P -- "$(dirname -- "")" && pwd -P)"
readonly SCRIPT="$(basename "$0")"
readonly SCRIPT_VERSION="0.1"
[[ ! -v ${SHELLCHECK_VERSION}  ]] && readonly SHELLCHECK_VERSION="v0.7.2"

# Handle Signals
# trap ctrl-c and SIGTERM
trap ctrl_c_signal_handler INT
trap term_signal_handler SIGTERM

function ctrl_c_signal_handler()
{
  log_error "User Interrupt! CTRL-C"
  exit 4
}
function term_signal_handler()
{
  log_error "Signal Interrupt! SIGTERM"
  exit 4
}

#>> diana::snippet:bash-logger:begin <<#
# shellcheck shell=sh
# shellcheck disable=SC3043

# SHELL LOGGING LIBRARY
# See https://github.com/tprasadtp/dotfiles/libs/logger/README.md
# If included in other files, contents between snippet markers is
# automatically updated and all changes between markers wil be ignored.

# Logger core
__logger_core_event_handler()
{
  [ "$#" -lt 2 ] && return

  # Caller is same as level name
  local lvl_caller="${1:-info}"

  case $lvl_caller in
    log_trace | trace)
      lvl_caller="trace"
      level="0"
      ;;
    log_debug | debug)
      lvl_caller="debug"
      level="10"
      ;;
    log_info | info)
      lvl_caller="info"
      level="20"
      ;;
    log_success | success | ok)
      lvl_caller="success"
      level="20"
      ;;
    log_warning | warning | warn)
      lvl_caller="warning"
      level="30"
      ;;
    log_notice | notice)
      lvl_caller="notice"
      level="35"
      ;;
    log_error | error)
      lvl_caller="error"
      level="40"
      ;;
    *)
      level="40"
      ;;
  esac

  # Immediately return if log level is not enabled
  # If LOG_LVL is not set, defaults to 20 - info level
  [ "${LOG_LVL:-20}" -gt "$level" ] && return

  shift
  local lvl_msg="$*"

  # Detect whether to coloring is disabled based on env variables,
  # and if output Terminal is intractive. This supports both
  # - https://bixense.com/clicolors/ &
  # - https://no-color.org/ standards.

  # Forces colored logs
  # - if CLICOLOR_FORCE is set and non empty and not zero
  #
  if [ -n "${CLICOLOR_FORCE}" ] && [ "${CLICOLOR_FORCE}" != "0" ]; then
    local lvl_colorized="true"
    # shellcheck disable=SC2155
    local lvl_color_reset="$(printf '\e[0m')"

  # Disable colors if one of the conditions are true
  # - CLICOLOR = 0
  # - NO_COLOR is set to non empty value
  # - TERM is set to dumb
  elif [ -n "$NO_COLOR" ] || [ "$CLICOLOR" = "0" ] || [ "$TERM" = "dumb" ]; then
    local lvl_colorized="false"
    local lvl_color=""
    local lvl_color_reset=""

  # Enable colors if not already disabled or forced and terminal is interactive
  elif [ -t 1 ]; then
    local lvl_colorized="true"
    # shellcheck disable=SC2155
    local lvl_color_reset="$(printf '\e[0m')"

  # Default=disable colors
  else
    local lvl_colorized="false"
    local lvl_color=""
    local lvl_color_reset=""
  fi

  # Log and Date formatter
  if [ "${LOG_FMT:-pretty}" = "pretty" ] && [ "$lvl_colorized" = "true" ]; then
    local lvl_string="•"
  elif [ "${LOG_FMT}" = "full" ] || [ "${LOG_FMT}" = "long" ]; then
    local lvl_prefix="name+ts"
    # shellcheck disable=SC2155
    local lvl_ts="$(date --rfc-3339=s)"
  else
    local lvl_prefix="name"
  fi

  # Define level, color and timestamp
  # By default we do not show log level and timestamp.
  # However, if LOG_FMT is set to "full" or "long" or if colors are disabled,
  # we will enable long format with timestamps
  case "$lvl_caller" in
    trace)
      [ "$lvl_prefix" = "name" ] && local lvl_string="[TRACE ]"
      [ "$lvl_prefix" = "name+ts" ] && local lvl_string="$lvl_ts [TRACE ]"
      # shellcheck disable=SC2155
      [ "$lvl_colorized" = "true" ] && local lvl_color="$(printf '\e[38;5;246m')"
      ;;
    debug)
      [ "$lvl_prefix" = "name" ] && local lvl_string="[DEBUG ]"
      [ "$lvl_prefix" = "name+ts" ] && local lvl_string="$lvl_ts [DEBUG ]"
      # shellcheck disable=SC2155
      [ "$lvl_colorized" = "true" ] && local lvl_color="$(printf '\e[38;5;250m')"
      ;;
    info)
      [ "$lvl_prefix" = "name" ] && local lvl_string="[INFO  ]"
      [ "$lvl_prefix" = "name+ts" ] && local lvl_string="$lvl_ts [INFO  ]"
      # Avoid printing color reset sequence as this level is not colored
      [ "$lvl_colorized" = "true" ] && lvl_color_reset=""
      ;;
    success)
      [ "$lvl_prefix" = "name" ] && local lvl_string="[OK    ]"
      [ "$lvl_prefix" = "name+ts" ] && local lvl_string="$lvl_ts [OK    ]"
      # shellcheck disable=SC2155
      [ "$lvl_colorized" = "true" ] && local lvl_color="$(printf '\e[38;5;83m')"
      ;;
    warning)
      [ "$lvl_prefix" = "name" ] && local lvl_string="[WARN  ]"
      [ "$lvl_prefix" = "name+ts" ] && local lvl_string="$lvl_ts [WARN  ]"
      # shellcheck disable=SC2155
      [ "$lvl_colorized" = "true" ] && local lvl_color="$(printf '\e[38;5;214m')"
      ;;
    notice)
      [ "$lvl_prefix" = "name" ] && local lvl_string="[NOTICE]"
      [ "$lvl_prefix" = "name+ts" ] && local lvl_string="$lvl_ts [NOTICE]"
      # shellcheck disable=SC2155
      [ "$lvl_colorized" = "true" ] && local lvl_color="$(printf '\e[38;5;81m')"
      ;;
    error)
      [ "$lvl_prefix" = "name" ] && local lvl_string="[ERROR ]"
      [ "$lvl_prefix" = "name+ts" ] && local lvl_string="$lvl_ts [ERROR ]"
      # shellcheck disable=SC2155
      [ "$lvl_colorized" = "true" ] && local lvl_color="$(printf '\e[38;5;197m')"
      ;;
    *)
      [ "$lvl_prefix" = "name" ] && local lvl_string="[UNKOWN]"
      [ "$lvl_prefix" = "name+ts" ] && local lvl_string="$lvl_ts [UNKNOWN]"
      # Avoid printing color reset sequence as this level is not colored
      [ "$lvl_colorized" = "true" ] && lvl_color_reset=""
      ;;
  esac

  if [ "${LOG_TO_STDERR:-false}" = "true" ]; then
    printf "%s%s %s %s\n" "$lvl_color" "${lvl_string}" "$lvl_msg" "${lvl_color_reset}" 1>&2
  else
    printf "%s%s %s %s\n" "$lvl_color" "${lvl_string}" "$lvl_msg" "${lvl_color_reset}"
  fi
}

# Leveled Loggers
log_trace()
{
  __logger_core_event_handler "trace" "$@"
}

log_debug()
{
  __logger_core_event_handler "debug" "$@"
}

log_info()
{
  __logger_core_event_handler "info" "$@"
}

log_success()
{
  __logger_core_event_handler "ok" "$@"
}

log_warning()
{
  __logger_core_event_handler "warn" "$@"
}

log_warn()
{
  __logger_core_event_handler "warn" "$@"
}

log_notice()
{
  __logger_core_event_handler "notice" "$@"
}

log_error()
{
  __logger_core_event_handler "error" "$@"
}
#>> diana::snippet:bash-logger:end <<#

function get_abspath()
{
  # Generate absolute path from relative path
  # ARGUMENTS:
  # $1     : relative filename
  if [ -d "$1" ]; then
    # dir
    (
      cd "$1" || return
      pwd
    )
  elif [ -f "$1" ]; then
    # file
    if [[ $1 = /* ]]; then
      printf "%s" "$1"
    elif [[ $1 == */* ]]; then
      printf "%s" "$(
        cd "${1%/*}" || return
        pwd
      )/${1##*/}"
    else
      printf "%s" "$(pwd)/$1"
    fi
  fi
}

# Checks if command is available
function has_command()
{
  if command -v "$1" >/dev/null; then
    return 0
  else
    return 1
  fi
  return 1
}

function display_usage()
{
  #Prints out help menu
  cat <<EOF
Run shellcheck using docker on files specified.

Usage: ${SCRIPT} [OPTION]... FILES

Arguments:
  List of Files to run shellcheck on

Options:
  -h, --help          Display help
  -v, --verbose       Increase log verbosity
  --stderr            Log to stderr instead of stdout
  --version           Display script version

Examples:
  ${SCRIPT} build.sh  Run shellcheck on build.sh
  ${SCRIPT} --help    Display help

Environment:
  SHELLCHECK_VERSION  Version of shellcheck to use.(default=$SHELLCHECK_VERSION)
  LOG_TO_STDERR       Set this to 'true' to log to stderr.
  NO_COLOR            Set this to NON-EMPTY to disable all colors.
  CLICOLOR_FORCE      Set this to NON-ZERO to force colored output.
EOF
}

function parse_options()
{
  NON_OPTION_ARGS=()
  while [[ ${1} != "" ]]; do
    case ${1} in
      --stderr) LOG_TO_STDERR="true" ;;
      -v | --verbose)
        LOG_LVL="0"
        log_debug "Enabled verbose logging"
        ;;
      --version)
        printf "%s version %s\n" "${SCRIPT}" "${SCRIPT_VERSION:-master}"
        exit 0
        ;;
      -h | --help)
        display_usage
        exit 0
        ;;
      *) NON_OPTION_ARGS+=("${1}") ;;
    esac
    shift
  done
}

function main()
{
  parse_options "$@"

  if ! has_command docker; then
    log_error "Docker command not found!"
    log_error "This script uses docker to ensure consistancy in CI/CD systems"
    log_error "Please install docker and try again"
    exit 1
  fi

  if [[ -n $DOCKER_HOST ]]; then
    log_error "DOCKER_HOST" "$DOCKER_HOST"
    log_error "Remote docker daemon is unsupported!"
    log_error "To use local daemon, without changing env variable, run with DOCKER_HOST='' ${SCRIPT}"
    exit 1
  fi

  # Check if shellcheck version should be changed?
  if [[ -n $SHELLCHECK_VERSION ]]; then
    declare -r SHELLCHECK_VERSION_REGEX="^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\$"
    if [[ ! $SHELLCHECK_VERSION =~ ^v ]]; then
      log_debug "Shellcheck version specified does not start with prefix v, append it"
      SHELLCHECK_VERSION="v${SHELLCHECK_VERSION}"
    fi

    if [[ $SHELLCHECK_VERSION =~ $SHELLCHECK_VERSION_REGEX ]]; then
      log_debug "Shellcheck version is valid"
    else
      log_error "Invalid shellcheck version"
      log_error "Version specified must match regex: ${SHELLCHECK_VERSION_REGEX}"
      exit 1
    fi
  fi

  log_notice "Using shellcheck version tag: ${SHELLCHECK_VERSION}"

  # check if docker image is available
  if docker inspect "koalaman/shellcheck:${SHELLCHECK_VERSION}" >/dev/null 2>&1; then
    log_debug "Using existing image - koalaman/shellcheck:${SHELLCHECK_VERSION}"
  else
    log_info "Pull docker image: koalaman/shellcheck:${SHELLCHECK_VERSION} "
    if docker pull koalaman/shellcheck:${SHELLCHECK_VERSION}; then
      log_success "Pull OK"
    else
      log_error "Shellcheck image specified is not present on local system"
      log_error "or on dockerhub. No image - koalaman/shellcheck:${SHELLCHECK_VERSION}"
      exit 1
    fi
  fi

  declare -ga SHELLCHECK_FILES
  declare -ga SHELLCHECK_ERRORS
  declare abs_file_path

  # Loop over non option arguments and check if the files are
  # present and are readable
  for file in "${NON_OPTION_ARGS[@]}"; do
    abs_file_path=""
    # absolute path takes priority
    if [[ -r ${file} ]]; then
      log_debug "Readable file: ${file}"
      abs_file_path="$(get_abspath "${file}")"
    # search in REPO_ROOT if REPO_ROOT is defined
    elif [[ -r ${REPO_ROOT}/${file} ]] && [[ -n ${REPO_ROOT} ]]; then
      log_debug "Readable file: ${REPO_ROOT}/${file} (REPO_ROOT)"
      abs_file_path="$(get_abspath "${REPO_ROOT}/${file}")"
    else
      log_error "File not found : ${file}"
    fi

    if [[ -n ${abs_file_path} ]]; then
      log_debug "Adding ${abs_file_path} to file list"
      SHELLCHECK_FILES+=("${abs_file_path}")
    fi
  done

  if [[ ${#SHELLCHECK_FILES[@]} -eq 0 ]]; then
    log_error "No files to shellcheck!"
    exit 1
  else
    local res
    # Use shellcheck docker image for consistancy
    for file in "${SHELLCHECK_FILES[@]}"; do
      file_basename="$(basename "${file}")"
      log_info "$file"
      docker run \
        --rm \
        --workdir=/app/ \
        --network=none \
        -v "${file}:/app/${file_basename}:ro" \
        koalaman/shellcheck:"${SHELLCHECK_VERSION}" \
        --color=always \
        "/app/${file_basename}"
      res="$?"
      if [[ $res -eq 0 ]]; then
        log_success "OK"
      else
        SHELLCHECK_ERRORS+=("${file}")
        log_error "FAILED"
      fi
    done
  fi

  if [ ${#SHELLCHECK_ERRORS[@]} -eq 0 ]; then
    log_notice "Hooray! All files passed shellcheck."
  else
    log_error "${#SHELLCHECK_ERRORS[*]} file(s) failed shellcheck: ${SHELLCHECK_ERRORS[*]}"
    exit 1
  fi
}

main "$@"

# diana:{diana_urn_flavor}:{remote}:{source}:{version}:{remote_path}:{type}
# diana:2:github:tprasadtp/templates::scripts/shellcheck.sh:static
