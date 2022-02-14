#!/usr/bin/env bash
#  Copyright (c) 2022, Prasad Tengse
#
# shellcheck disable=SC2034,SC2155

set -o pipefail

# Script Constants
readonly CURDIR="$(cd -P -- "$(dirname -- "")" && pwd -P)"
readonly SCRIPT="$(basename "$0")"

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


# Checks if command is available
function has_command() {
    if command -v "$1" >/dev/null; then
        return 0
    else
        return 1
    fi
    return 1
}

# Checks if dependencies are installed
function check_deps() {
    local missing_deps=0
    log_debug "Checking dependencies"
    if ! has_command git-chglog; then
        log_error "Missing git-chglog. Please install git-chglog (v0.13 and above)"
        log_info "from https://github.com/git-chglog/git-chglog."
        ((missing_deps++))
    else
        log_debug "git-chgog is available"
    fi

    if ! has_command git; then
        log_error "Missing git. Please install git"
        ((missing_deps++))
    else
        log_debug "git is available"
    fi

    if [[ $missing_deps -ne 0 ]]; then
        log_error "Missing one or more dependencies!"
        exit 2
    fi
}

function build_regex() {
    if [[ -n ${NEXT_TAG} ]]; then
        log_info "Using next tag - ${NEXT_TAG}"
        if git show-ref --tags --quiet --verify -- "refs/tags/${NEXT_TAG}"; then
            log_error "Next tag specified already exists in git"
            exit 1
        fi
        tag="$NEXT_TAG"
    else
        log_debug "Get closest tag"
        tag="$(git describe --tags --abbrev=0 2>/dev/null)"
        if [[ -z $tag ]]; then
            log_error "There are no tags in this repository"
            log_error "Please use --next or create a tag"
            exit 1
        fi
    fi

    log_debug "Checking if tag - ${tag} is valid"

    # validate tag is a valid semver tag
    if [[ ${tag} =~ $SEMVER_REGEX ]]; then
        log_debug "Tag ${tag} is valid semver"
        major="${BASH_REMATCH[1]}"
        minor="${BASH_REMATCH[2]}"
        patch="${BASH_REMATCH[3]}"
        pre="${BASH_REMATCH[4]:1}"
        build="${BASH_REMATCH[8]:1}"
    else
        log_error "${tag} is not semver tag!"
        log_info "All tags must be semver compatible"
        exit 1
    fi

    log_info "Tag major=${major:-null}, minor=${minor:-null}, patch=${patch:-null}, pre=${pre:-null}, build=${build:-null}"

    # Build Regex to filter tags
    # https://regex101.com/r/0EiAvH/1/
    if [[ $pre == "" ]]; then
        tag_filter="[vV]?[\d]+\.[\d]+\.[\d]+\$"
    else
        tag_filter="^[vV]?(${major}\.${minor}\.${patch})(\-(alpha|beta|rc)(\.(0|[1-9][0-9]*))?)\$|(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\$"
    fi

    log_debug "Tag filter regex is ${tag_filter}"

}

function display_usage() {
    cat <<EOF
Generate changelog and release-notes using git-chglog/git-chglog.

Usage: ${SCRIPT} [OPTION]... changelog|release-notes

Arguments:
  Type of changelog to generate. It can either be "changelog", which
  includes full changlog or "release-notes", which is shorter but
  suitable as release notes.

Options:
  -o, output PATH       Output file path
  -r, --repo URL        Repository URL
  -n, --next TAG        Generate changelog for NEXT-TAG
  --header-file         Contents of this file will be added before generated changelog
  --footer-file         Contents of this filw will be added after the generated changelog
  -h, --help            Display help
  -v, --verbose         Enable debug logs
  --stdout              Log to stdout instead of stdout
  --version             Display script version

Environment:
  NEXT_TAG              Same as using --next option
  PROJECT_SOURCE        Git Repository URL same as specifying via --repository
  LOG_TO_STDOUT         Set this to 'true' to log to stdout.
  NO_COLOR              Set this to NON-EMPTY to disable all colors.
  CLICOLOR_FORCE        Set this to NON-ZERO to force colored output.
EOF
}

function main() {
    if [[ $# -lt 1 ]]; then
        log_error "No arguments specified"
        display_usage
        exit 1
    fi

    while [[ ${1} != "" ]]; do
        case ${1} in
        changelog) mode="changelog" ;;
        release-notes) mode="release-notes" ;;
        # Options
        -r | --repo)
            shift
            PROJECT_SOURCE="${1}"
            ;;
        -n | --next | --next-tag)
            readonly bool_use_next_mode="true"
            shift
            readonly NEXT_TAG="${1}"
            ;;
        # Header and Footer Files
        -o | --output)
            shift
            readonly output_file="${1}"
            ;;
        --header-file)
            shift
            readonly header_file="${1}"
            ;;
        --footer-file)
            shift
            readonly footer_file="${1}"
            ;;
        # useful to merge old changelogs with autogenerated ones
        --oldest-tag)
            shift
            readonly oldest_tag="${1}"
            ;;
        # Debugging options
        --stdout) LOG_TO_STDOUT="true" ;;
        -v | --verbose)
            LOG_LVL="0"
            log_info "Enable verbose logging"
            ;;
        -h | --help)
            display_usage
            exit 0
            ;;
        *)
            log_error "Invalid argument(s). See usage below."
            display_usage
            exit 1
            ;;
        esac
        shift
    done

    if [[ -z $mode ]]; then
        log_error "No mode specified!"
        display_usage
        exit 1
    fi

    if [[ -z $PROJECT_SOURCE ]]; then
        log_error "Repository URL is not defined!"
        log_error "Either define PROJECT_SOURCE or use --repository flag"
        display_usage
        exit 1
    fi

    GITHUB_R_REGEX="^(github|gh):([A-Za-z0-9-]+)\/([A-Za-z0-9-]+)\$"
    GITLAB_R_REGEX="^gitlab:([A-Za-z0-9-]+)\/([A-Za-z0-9-]+)\$"
    BITBUCKET_R_REGEX="^bitbucket:([A-Za-z0-9-]+)\/([A-Za-z0-9-]+)\$"

    if [[ $PROJECT_SOURCE =~ $GITHUB_R_REGEX ]]; then
        PROJECT_SOURCE="https://github.com/${BASH_REMATCH[2]}/${BASH_REMATCH[3]}"
    elif [[ $PROJECT_SOURCE =~ $GITLAB_R_REGEX ]]; then
        PROJECT_SOURCE="https://gitlab.com/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    elif [[ $PROJECT_SOURCE =~ $BITBUCKET_R_REGEX ]]; then
        PROJECT_SOURCE="https://bitbucket.org/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
    fi

    log_debug "Project Repository URL is - ${PROJECT_SOURCE}"

    # validate --next is a valid semver tag
    if [[ $bool_use_next_mode == "true" ]]; then
        if [[ ! $NEXT_TAG =~ $SEMVER_REGEX ]]; then
            log_error "--next tag $NEXT_TAG is invalid"
            exit 1
        else
            log_debug "--next tag $NEXT_TAG is valid semver"
        fi
    fi

    # Header file
    if [[ -n $header_file ]]; then
        log_info "Using header file: ${header_file}"
        if [[ ! -e $header_file ]]; then
            log_error "Specified header file ${header_file} not found!"
            exit 1
        else
            readonly HEADER_FILE_CONTENTS="$(cat "$header_file")"
            if [[ -z $HEADER_FILE_CONTENTS ]]; then
                log_error "Header file is empty!"
                exit 1
            fi
        fi
    fi

    # Footer file
    if [[ -n $footer_file ]]; then
        log_info "Using footer file: ${footer_file}"
        if [[ ! -e $footer_file ]]; then
            log_error "Specified footer file ${footer_file} not found!"
            exit 1
        else
            readonly FOOTER_FILE_CONTENTS="$(cat "$footer_file")"
            if [[ -z $FOOTER_FILE_CONTENTS ]]; then
                log_error "Footer file is empty!"
                exit 1
            fi
        fi
    fi

    # Output file is specified
    if [[ -n $output_file ]]; then
        output_dir="$(dirname "${output_file}")"
        log_notice "Output will be saved to dir=$output_dir, file=$(basename "$output_file")"
        if [[ ! -d ${output_dir} ]]; then
            log_error "Output was specified but dir $output_dir does not exist!"
            exit 1
        fi
    fi

    # check if a git repo
    if [[ $(git rev-parse --is-inside-work-tree) != "true" ]]; then
        log_error "Not a git repository!"
        exit 1
    fi

    # if oldest tag was specified
    if [[ -n $oldest_tag ]]; then
        log_debug "Will generate tags till oldest tag - $oldest_tag"
        if ! git show-ref --tags --quiet --verify -- "refs/tags/${oldest_tag}"; then
            log_error "Oldest tag was specified but the tag does not exist in git!"
            exit 1
        fi
        readonly CHANGELOG_ARGS="$oldest_tag.."
    fi

    # check for deps
    check_deps

    # acquire_tag_tag
    build_regex

    if [[ $mode == "changelog" ]]; then
        log_info "Generating changelog"

        if [[ -n ${NEXT_TAG} ]]; then
            CHANGELOG_CONTENT="$(git-chglog \
                --repository-url="${PROJECT_SOURCE}" \
                --next-tag="${NEXT_TAG}" \
                --tag-filter-pattern="${tag_filter}" \
                "${CHANGELOG_ARGS}")"
        else
            CHANGELOG_CONTENT="$(git-chglog \
                --repository-url="${PROJECT_SOURCE}" \
                --tag-filter-pattern="${tag_filter}" \
                "${CHANGELOG_ARGS}")"
        fi

        if [[ -z $CHANGELOG_CONTENT ]]; then
            log_error "Failed to generate changelog"
            exit 1
        else
            if [[ -n $output_file ]]; then
                if echo "${HEADER_FILE_CONTENTS}${CHANGELOG_CONTENT}${FOOTER_FILE_CONTENTS}" >"${output_file}"; then
                    log_success "Saved changelog to $output_file"
                else
                    log_error "Failed to save changelog to $output_file"
                    exit 1
                fi
            else
                echo "${HEADER_FILE_CONTENTS}${CHANGELOG_CONTENT}${FOOTER_FILE_CONTENTS}"
            fi
        fi

    # release notes
    elif [[ $mode == "release-notes" ]]; then
        log_info "Generating release notes"

        if [[ -n ${NEXT_TAG} ]]; then
            RN_CONTENT="$(git-chglog \
                --template "${REPO_ROOT:-.}/.chglog/RELEASE_NOTES.md.tpl" \
                --repository-url="${PROJECT_SOURCE}" \
                --next-tag="${NEXT_TAG}" \
                --tag-filter-pattern="${tag_filter}" \
                "${tag}")"
        else
            RN_CONTENT="$(git-chglog \
                --template "${REPO_ROOT:-.}/.chglog/RELEASE_NOTES.md.tpl" \
                --repository-url="${PROJECT_SOURCE}" \
                --tag-filter-pattern="${tag_filter}" \
                "${tag}")"
        fi

        if [[ -z $RN_CONTENT ]]; then
            log_error "Failed to generate release notes"
            exit 1
        else
            if [[ -n $output_file ]]; then
                if echo "${HEADER_FILE_CONTENTS}${RN_CONTENT}${FOOTER_FILE_CONTENTS}" >"${output_file}"; then
                    log_success "Saved release notes to $output_file"
                else
                    log_error "Failed to save release notes to $output_file"
                    exit 1
                fi
            else
                echo "${HEADER_FILE_CONTENTS}${RN_CONTENT}${FOOTER_FILE_CONTENTS}"
            fi
        fi
    else
        log_error "Invalid mode specified: $mode"
        exit 1
    fi

}

main "$@"

# diana:{diana_urn_flavor}:{remote}:{source}:{version}:{remote_path}:{type}
# diana:2:github:tprasadtp/templates::common/scripts/changelog.sh:static
