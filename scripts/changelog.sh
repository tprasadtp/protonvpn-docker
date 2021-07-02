#!/usr/bin/env bash
# Copyright (c) 2021. Prasad Tengse
#
# shellcheck disable=SC2155,SC2034

set -o pipefail

# Script Constants
readonly CURDIR="$(cd -P -- "$(dirname -- "")" && pwd -P)"
readonly SCRIPT="$(basename "$0")"

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

# Checks if dependencies are installed
function check_deps()
{
  local missing_deps=0
  log_notice "Checking dependencies"
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


function display_usage()
{
  cat <<EOF
Generate changelog and release-notes using git-chglog/git-chglog.

Usage: ${SCRIPT} [OPTION]... changelog|release-notes

Arguments:
  Type of changelog to generate. It can either be "changelog", which
  includes full changlog or "release-notes", which is shorter but
  suitable as release notes.

Options:
  -o, output            Output file path
  -r, --repo [URL]      Repository URL
  -n, --next [TAG]      Generate changelog for NEXT-TAG
  --header-file         Contents of this file will be added before generated changelog
  --footer-file         Contents of this filw will be added after the generated changelog
  -h, --help            Display help
  -v, --verbose         Increase log verbosity
  --stderr              Log to stderr instead of stdout
  --version             Display script version

Environment:
  NEXT_TAG              Same as using --next option
  PROJECT_SOURCE        Git Repository URL same as specifying via --repository
  LOG_TO_STDERR         Set this to 'true' to log to stderr.
  NO_COLOR              Set this to NON-EMPTY to disable all colors.
  CLICOLOR_FORCE        Set this to NON-ZERO to force colored output.
EOF
}

function main()
{
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
      -n | --next)
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
      --stderr) LOG_TO_STDERR="true" ;;
      -d | --debug)
        LOG_LVL="1"
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

  if [[ -z $PROJECT_SOURCE ]]; then
    log_error "Repository URL is not defined!"
    log_error "Either define PROJECT_SOURCE or use --repository flag"
    display_usage
    exit 1
  fi

  local -r SEMVER_REGEX="^[vV]?(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(\-(0|[1-9][0-9]*|[0-9]*[A-Za-z-][0-9A-Za-z-]*)(\.(0|[1-9][0-9]*|[0-9]*[A-Za-z-][0-9A-Za-z-]*))*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$"

  # validate --next is a valid semver tag
  if [[ $bool_use_next_mode == "true" ]]; then
    if [[ ! $NEXT_TAG =~ $SEMVER_REGEX ]]; then
      log_error "--next tag $NEXT_TAG is invalid"
      exit 1
    else
      log_info "--next tag is valid semver tag"
    fi
  fi

  # Header file
  if [[ $header_file != "" ]]; then
    log_info "Using header file: ${header_file}"
    if [[ ! -e $header_file ]]; then
      log_error "Specified header file ${header_file} not found!"
      exit 1
    else
      local -r HEADER_FILE_CONTENTS="$(cat "$header_file")"
      if [[ -z $HEADER_FILE_CONTENTS ]]; then
        log_warning "Header file is empty!"
      fi
    fi
  fi

  # Footer file
  if [[ $footer_file != "" ]]; then
    log_info "Using footer file: ${footer_file}"
    if [[ ! -e $footer_file ]]; then
      log_error "Specified footer file ${footer_file} not found!"
      exit 1
    else
      local -r FOOTER_FILE_CONTENTS="$(cat "$footer_file")"
      if [[ -z $FOOTER_FILE_CONTENTS ]]; then
        log_warn "Footer file is empty!"
      fi
    fi
  fi

  # Output file is specified
  if [[ -n $output_file ]]; then
    output_dir="$(dirname "${output_file}")"
    log_info "Output will be saved to dir=$output_dir, file=$(basename "$output_file")"
    if [[ ! -d ${output_dir} ]] || [[ ! -w ${output_dir} ]] ; then
      log_error "Output was specified but dir $output_dir does not exist or is not writable!"
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
    log_info "Will generate changelog starting from tag - $oldest_tag"
    if ! git show-ref --tags --quiet --verify -- "refs/tags/${oldest_tag}"; then
      log_error "Oldest tag specified but the tag does not exist in git!"
      exit 1
    fi
    local -r CHANGELOG_ARGS="$oldest_tag.."
  fi

  # check for deps
  check_deps

  # acquire_tag_tag
  if [[ -n ${NEXT_TAG} ]]; then
    log_info "Using next tag - ${NEXT_TAG}"
    if git show-ref --tags --quiet --verify -- "refs/tags/${NEXT_TAG}"; then
      log_error "Next tag specified already exists in git"
      exit 1
    fi
    tag="$NEXT_TAG"
  else
    log_info "Get closest tag"
    tag="$(git describe --tags --abbrev=0 2>/dev/null)"
    if [[ -z $tag ]]; then
      log_error "There are no tags in this repository"
      log_error "Please use --next or create a tag"
      exit 1
    fi
  fi

  log_trace "Parsing tag: ${tag}"

  # validate tag is a valid semver tag
  if [[ ${tag} =~ $SEMVER_REGEX ]]; then
    log_info "${tag} is valid semver"
    major="${BASH_REMATCH[1]}"
    minor="${BASH_REMATCH[2]}"
    patch="${BASH_REMATCH[3]}"
    pre="${BASH_REMATCH[4]:1}"
    build="${BASH_REMATCH[8]:1}"
  else
    log_error "${tag} is not semver tag!"
    log_info "all tags must be semver compatible"
    exit 1
  fi

  log_info "tag major - $major"
  log_info "tag minor - $minor"
  log_info "tag patch - $patch"
  log_info "tag pre   - $pre"
  log_info "tag build - $build"

  # Build Regex to filter tags
  # https://regex101.com/r/0EiAvH/1/
  if [[ $pre == "" ]]; then
    tag_filter="[vV]?[\d]+\.[\d]+\.[\d]+\$"
  else
    tag_filter="^[vV]?(${major}\.${minor}\.${patch})(\-(alpha|beta|rc)(\.(0|[1-9][0-9]*))?)\$|(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\$"
  fi

  log_info "Tag filter regex is ${tag_filter}"

  if [[ ${mode:-changelog} == "changelog" ]]; then
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
        log_info "saving changelog to $output_file"
        echo "${HEADER_FILE_CONTENTS}${CHANGELOG_CONTENT}${FOOTER_FILE_CONTENTS}" >"${output_file}"
      else
        echo "${HEADER_FILE_CONTENTS}${CHANGELOG_CONTENT}${FOOTER_FILE_CONTENTS}"
      fi
    fi

  # release notes
  elif [[ ${mode:-changelog} == "release-notes" ]]; then
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
        log_info "Saving release notes to $output_file"
        echo "${HEADER_FILE_CONTENTS}${RN_CONTENT}" >"${output_file}"
      else
        echo "${HEADER_FILE_CONTENTS}${RN_CONTENT}"
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
