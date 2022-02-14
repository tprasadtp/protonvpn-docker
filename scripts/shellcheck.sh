#!/usr/bin/env bash
# Copyright (c) 2021. Prasad Tengse
#
# shellcheck disable=SC2155,SC2034

set -o pipefail

# Script Constants
readonly CURDIR="$(cd -P -- "$(dirname -- "")" && pwd -P)"
readonly SCRIPT="$(basename "$0")"
readonly SCRIPT_VERSION="0.1"

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

#diana::snippet:shlib-logger:begin#
# shellcheck shell=sh
# shellcheck disable=SC3043

# SHELL LOGGING LIBRARY
# See https://github.com/tprasadtp/shlibs/logger/README.md
# If included in other files, contents between snippet markers
# might automatically be updated (depending on who manages it)
# and all changes between markers might be ignored.

# Logger core ::internal::
# This function should NOT be called directly.
__logger_core_event_handler() {
    [ "$#" -lt 2 ] && return 1

    local lvl_caller="${1:-info}"

    # Logging levels are similar to python's logging levels
    case ${lvl_caller} in
    trace)
        level="0"
        ;;
    debug)
        level="10"
        ;;
    info)
        level="20"
        ;;
    success)
        level="20"
        ;;
    notice)
        level="25"
        ;;
    warning)
        level="30"
        ;;
    error)
        level="40"
        ;;
    critical)
        level="50"
        ;;
    *)
        level="100"
        ;;
    esac

    # Immediately return if log level is not enabled
    # If LOG_LVL is not set, defaults to 20 - info level
    [ "${LOG_LVL:-20}" -gt "${level}" ] && return

    shift
    local lvl_msg="$*"

    # Detect whether to coloring is disabled based on env variables,
    # and if output Terminal is intractive.
    # This supports following standards.
    #  - https://bixense.com/clicolors/
    #  - https://no-color.org/

    local lvl_color
    local lvl_colorized
    local lvl_color_reset

    # Forces colored logs
    # - if CLICOLOR_FORCE is set and is not zero
    if [ -n "${CLICOLOR_FORCE}" ] && [ "${CLICOLOR_FORCE}" != "0" ]; then
        lvl_colorized="true"
        # shellcheck disable=SC2155
        lvl_color_reset="\e[0m"

    # Disable colors if one of the conditions are true
    # - CLICOLOR = 0
    # - NO_COLOR is set to non empty value
    # - TERM is set to dumb
    elif [ -n "${NO_COLOR}" ] || [ "${CLICOLOR}" = "0" ] || [ "${TERM}" = "dumb" ]; then
        lvl_colorized="false"

    # Enable colors if not already disabled or forced and terminal is interactive
    elif [ -t 1 ] && [ -t 2 ]; then
        lvl_colorized="true"
        # shellcheck disable=SC2155
        lvl_color_reset="\e[0m"
    fi

    # Level name in string format
    local lvl_prefix
    # Level name in string format with timestamp if enabled or level symbol
    local lvl_string

    # Log format
    if [ "${LOG_FMT:-pretty}" = "pretty" ] && [ "${lvl_colorized}" = "true" ]; then
        lvl_string="•"
    elif [ "${LOG_FMT}" = "full" ] || [ "${LOG_FMT}" = "long" ]; then
        # shellcheck disable=SC2155
        lvl_prefix="$(date --rfc-3339=s) "
    fi

    # Define level, color and timestamp
    # By default we do not show log level and timestamp.
    # However, if LOG_FMT is set to "full" or "long",
    # we will enable long format with timestamps
    case "$lvl_caller" in
    trace)
        # if lvl_string is set earlier, that means LOG_FMT is default or pretty
        # we dont display timestamp or level name in this case. otherwise
        # append level name to lvl_prefix
        # (lvl_prefix is populated with timestamp if LOG_FMT is full or long)
        [ -z "${lvl_string}" ] && lvl_string="${lvl_prefix}[TRACE   ]"
        [ "${lvl_colorized}" = "true" ] && lvl_color="\e[38;5;246m"
        ;;
    debug)
        [ -z "${lvl_string}" ] && lvl_string="${lvl_prefix}[DEBUG   ]"
        [ "${lvl_colorized}" = "true" ] && lvl_color="\e[38;5;250m"
        ;;
    info)
        [ -z "${lvl_string}" ] && lvl_string="${lvl_prefix}[INFO    ]"
        # Avoid printing color reset sequence as this level is not colored
        [ "${lvl_colorized}" = "true" ] && lvl_color_reset=""
        ;;
    success)
        [ -z "${lvl_string}" ] && lvl_string="${lvl_prefix}[INFO    ]"
        [ "${lvl_colorized}" = "true" ] && lvl_color="\e[38;5;83m"
        ;;
    notice)
        [ -z "${lvl_string}" ] && lvl_string="${lvl_prefix}[NOTICE  ]"
        # shellcheck disable=SC2155
        [ "${lvl_colorized}" = "true" ] && lvl_color="\e[38;5;81m"
        ;;
    warning)
        [ -z "${lvl_string}" ] && lvl_string="${lvl_prefix}[WARNING ]"
        # shellcheck disable=SC2155
        [ "${lvl_colorized}" = "true" ] && lvl_color="\e[38;5;214m"
        ;;
    error)
        [ -z "${lvl_string}" ] && lvl_string="${lvl_prefix}[ERROR   ]"
        # shellcheck disable=SC2155
        [ "${lvl_colorized}" = "true" ] && lvl_color="\e[38;5;197m"
        ;;
    critical)
        [ -z "${lvl_string}" ] && lvl_string="${lvl_prefix}[CRITICAL]"
        # shellcheck disable=SC2155
        [ "${lvl_colorized}" = "true" ] && lvl_color="\e[38;5;196m"
        ;;
    *)
        [ -z "${lvl_string}" ] && lvl_string="${lvl_prefix}[UNKNOWN ]"
        # Avoid printing color reset sequence as this level is not colored
        [ "${lvl_colorized}" = "true" ] && lvl_color_reset=""
        ;;
    esac

    # By default logs are written to stderr
    case "${LOG_TO_STDOUT:-false}" in
    true | True | TRUE | Yes | yes | YES | 1)
        printf "${lvl_color}%s %s ${lvl_color_reset}\n" "${lvl_string}" "$lvl_msg"
        ;;
    *)
        printf "${lvl_color}%s %s ${lvl_color_reset}\n" "${lvl_string}" "$lvl_msg" 1>&2
        ;;
    esac
}

# Leveled Loggers
log_trace() {
    __logger_core_event_handler "trace" "$@"
}

log_debug() {
    __logger_core_event_handler "debug" "$@"
}

log_info() {
    __logger_core_event_handler "info" "$@"
}

log_success() {
    __logger_core_event_handler "success" "$@"
}

log_warning() {
    __logger_core_event_handler "warning" "$@"
}

log_warn() {
    __logger_core_event_handler "warning" "$@"
}

log_notice() {
    __logger_core_event_handler "notice" "$@"
}

log_error() {
    __logger_core_event_handler "error" "$@"
}

log_critical() {
    __logger_core_event_handler "critical" "$@"
}

# For logging command outputs
# Pipe output of your command to this function
# This is EXPERIMENTAL FEATURE!!
# If used without a pipe causes script to hang!
# - Accepts two optional arguments.
#  ARG 1 (str) - msg prefix, this will be prefixed with every line of output
log_tail() {
    local line prefix
    [ -n "$1" ] && prefix="($1) "
    while read -r line; do
        __logger_core_event_handler "trace" "$prefix$line"
    done
}
#diana::snippet:shlib-logger:end#

function get_abspath() {
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
function has_command() {
    if command -v "$1" >/dev/null; then
        return 0
    else
        return 1
    fi
    return 1
}

function display_usage() {
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
  LOG_TO_STOUT        Set this to 'true' to log to stdout.
  NO_COLOR            Set this to NON-EMPTY to disable all colors.
  CLICOLOR_FORCE      Set this to NON-ZERO to force colored output.
EOF
}

function parse_options() {
    NON_OPTION_ARGS=()
    while [[ ${1} != "" ]]; do
        case ${1} in
        --stderr) LOG_TO_STDOUT="true" ;;
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

function main() {
    parse_options "$@"

    if has_command docker; then
        log_debug "Docker cli exists!"
    else
        log_error "Docker not found!"
        log_error "This script uses docker to ensure consistancy in CI/CD systems"
        log_error "Please install docker and try again"
        exit 1
    fi

    [[ -z $SHELLCHECK_VERSION ]] && SHELLCHECK_VERSION="v0.7.2"

    # Check if shellcheck version is valid
    if [[ -n ${SHELLCHECK_VERSION} ]]; then
        declare -r SHELLCHECK_VERSION_REGEX="^v?(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\$"
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
        local userns
        declare -a extra_args
        if docker info --format "{{ .SecurityOptions }}" | grep -q "name=userns"; then
            log_info "Skpping userns to avoid issues with mounted paths"
            extra_args+=("--userns=host")
        fi

        # Use shellcheck docker image for consistancy
        for file in "${SHELLCHECK_FILES[@]}"; do
            file_basename="$(basename "${file}")"
            log_info "$file"
            docker run \
                --rm "${extra_args[@]}" \
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
