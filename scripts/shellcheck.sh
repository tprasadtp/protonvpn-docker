#!/usr/bin/env bash
# Copyright (c) 2021. Prasad Tengse
#
# shellcheck disable=SC2155,SC2034

set -o pipefail

# Script Constants
readonly CURDIR="$(cd -P -- "$(dirname -- "")" && pwd -P)"
readonly SCRIPT="$(basename "$0")"
# Default log level (debug logs are disabled)
LOG_LVL=0

# Handle Signals
# trap ctrl-c and SIGTERM
trap ctrl_c_signal_handler INT
trap term_signal_handler SIGTERM

function ctrl_c_signal_handler() {
  log_error "User Interrupt! CTRL-C"
  exit 4
}
function term_signal_handler() {
  log_error "Signal Interrupt! SIGTERM"
  exit 4
}

function get_abspath()
{
  # Generate absolute path from relative path
  # ARGUMENTS:
  # $1     : relative filename
  if [ -d "$1" ]; then
        # dir
        (cd "$1" || return ; pwd)
    elif [ -f "$1" ]; then
        # file
        if [[ $1 = /* ]]; then
            printf "%s" "$1"
        elif [[ $1 == */* ]]; then
            printf "%s" "$(cd "${1%/*}" || return ; pwd)/${1##*/}"
        else
            printf "%s" "$(pwd)/$1"
        fi
    fi
}

# Logging Handlers

# Define colors for logging
function define_colors()
{
  declare -gr YELLOW=$'\e[38;5;214m'
  declare -gr GREEN=$'\e[38;5;83m'
  declare -gr RED=$'\e[38;5;197m'
  declare -gr NC=$'\e[0m'

  # Enhanced colors
  declare -gr PINK=$'\e[38;5;212m'
  declare -gr BLUE=$'\e[38;5;81m'
  declare -gr ORANGE=$'\e[38;5;208m'
  declare -gr TEAL=$'\e[38;5;192m'
  declare -gr VIOLET=$'\e[38;5;219m'
  declare -gr GRAY=$'\e[38;5;250m'
  declare -gr DARK_GRAY=$'\e[38;5;246m'

  # Flag
  declare -gr COLORIZED=1
}

function undefine_colors()
{
  # Disable all colors
  declare -gr YELLOW=""
  declare -gr GREEN=""
  declare -gr RED=""
  declare -gr NC=""

  # Enhanced colors
  declare -gr PINK=""
  declare -gr BLUE=""
  declare -gr ORANGE=""
  declare -gr TEAL=""
  declare -gr VIOLET=""
  declare -gr GRAY=""
  declare -gr DARK_GRAY=""

  # Flag
  declare -gr COLORIZED=1
}

# Check for Colored output
if [[ -n ${CLICOLOR_FORCE} ]] && [[ ${CLICOLOR_FORCE} != "0" ]]; then
  # In CI/CD Forces colors
  define_colors
elif [[ -t 1 ]] && [[ -z ${NO_COLOR} ]] && [[ ${TERM} != "dumb" ]] ; then
  # Enables colors if Terminal is interactive and NOCOLOR is not empty
  define_colors
else
  # Disables colors
  undefine_colors
fi

## Check if logs should be written to stderr
## This is useful if script generates an output which can be piped or redirected
if [[ -z ${LOG_TO_STDERR} ]]; then
  LOG_TO_STDERR="false"
fi

# Log functions
function log_info()
{
  if [[ $LOG_TO_STDERR == "true" ]]; then
    printf "• %s \n" "$@" 1>&2
  else
    printf "• %s \n" "$@"
  fi
}

function log_success()
{
  if [[ $LOG_TO_STDERR == "true" ]]; then
    printf "%s• %s %s\n" "${GREEN}" "$@" "${NC}" 1>&2
  else
    printf "%s• %s %s\n" "${GREEN}" "$@" "${NC}"
  fi
}

function log_warning()
{
  if [[ $LOG_TO_STDERR == "true" ]]; then
    printf "%s• %s %s\n" "${YELLOW}" "$@" "${NC}" 1>&2
  else
    printf "%s• %s %s\n" "${YELLOW}" "$@" "${NC}"
  fi
}

function log_error()
{
  if [[ $LOG_TO_STDERR == "true" ]]; then
    printf "%s• %s %s\n" "${RED}" "$@" "${NC}" 1>&2
  else
    printf "%s• %s %s\n" "${RED}" "$@" "${NC}"
  fi
}

function log_debug()
{
  if [[ LOG_LVL -gt 0  ]]; then
    if [[ $LOG_TO_STDERR == "true" ]]; then
      printf "%s• %s %s\n" "${GRAY}" "$@" "${NC}" 1>&2
    else
      printf "%s• %s %s\n" "${GRAY}" "$@" "${NC}"
    fi
  fi
}

function log_notice()
{
  if [[ $LOG_TO_STDERR == "true" ]]; then
    printf "%s• %s %s\n" "${TEAL}" "$@" "${NC}" 1>&2
  else
    printf "%s• %s %s\n" "${TEAL}" "$@" "${NC}"
  fi
}

function log_variable()
{
  local var
  var="$1"
  if [[ ${LOG_LVL} -gt 0  ]]; then
    if [[ $LOG_TO_STDERR == "true" ]]; then
      printf "%s» %-20s - %-10s %s\n" "${GRAY}" "${var}" "${!var}" "${NC}" 1>&2
    else
      printf "%s» %-20s - %-10s %s\n" "${GRAY}" "${var}" "${!var}" "${NC}"
    fi
  fi
}

# Checks if command is available
function has_command() {
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
Bash script to run shellcheck usng docker on files specified.

Usage: ${TEAL}${SCRIPT} ${BLUE} [options] ${NC}
${VIOLET}
------------------------- Arguments ----------------------------${NC}
List of Files to run shellcheck on
${ORANGE}
---------------- Options with Required Argments-----------------${NC}
None
${GRAY}
--------------------- Debugging & Help -------------------------${NC}
[-v | --verbose]        Increase log verbosity
[--stderr]              Log to stderr instead of stdout
[-h | --help]           Display this help message${NC}
${TEAL}
------------------- Environment Variables ----------------------${NC}
${BLUE}LOG_TO_STDERR${NC}     - Set this to 'true' to log to stderr.
${BLUE}NO_COLOR${NC}          - Set this to NON-EMPTY to disable all colors.
${BLUE}CLICOLOR_FORCE${NC}    - Set this to NON-ZERO to force colored output.
                    Other color related conditions are ignored.
                  - Colors are disabled if output is not a TTY
EOF
}




function parse_options()
{
  NON_OPTION_ARGS=()
  while [[ ${1} != "" ]]; do
  case ${1} in
    --stderr)               LOG_TO_STDERR="true";;
    -v | --verbose)         $((LOG_LVL++));
                            log_debug "Log Level is set to: $LOG_LVL";;
    -h | --help )           display_usage;exit 0;;
    *)                      NON_OPTION_ARGS+=("${1}");;
  esac
  shift
  done
}



function main()
{
  parse_options "$@"

  if has_command docker; then
    log_debug "Docker cli exists!"
  else
    log_error "Docker not found!"
    log_error "This script uses docker to ensure consistancy in CI/CD systems"
    log_error "Please install docker and try again"
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
  else
    SHELLCHECK_VERSION="v0.7.2"
  fi

  log_notice "Using shellcheck version tag: ${SHELLCHECK_VERSION}"

  # check if docker image is available
  if docker inspect "koalaman/shellcheck:${SHELLCHECK_VERSION}" > /dev/null 2>&1; then
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
        --userns=host \
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
