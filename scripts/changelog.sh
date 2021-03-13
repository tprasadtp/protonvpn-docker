#!/usr/bin/env bash
# Copyright (c) 2021. Prasad Tengse
#

set -o pipefail

# Script Constants
readonly CURDIR="$(cd -P -- "$(dirname -- "")" && pwd -P)"
readonly SCRIPT="$(basename "$0")"

# Handle Use interrupt
# trap ctrl-c and call ctrl_c()
trap ctrl_c_handler INT

function ctrl_c_handler() {
  log_error "User Interrupt! CTRL-C"
  exit 4
}

## Script Variables

readonly SEMVER_REGEX="^[vV]?(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(\-(0|[1-9][0-9]*|[0-9]*[A-Za-z-][0-9A-Za-z-]*)(\.(0|[1-9][0-9]*|[0-9]*[A-Za-z-][0-9A-Za-z-]*))*)?(\+[0-9A-Za-z-]+(\.[0-9A-Za-z-]+)*)?$"

## BEGIN AUTO-GENERATED CONTENT ##

# Basic colors
readonly YELLOW=$'\e[38;5;221m'
readonly GREEN=$'\e[38;5;42m'
readonly RED=$'\e[38;5;197m'
readonly NC=$'\e[0m'

# Enhanced colors

readonly PINK=$'\e[38;5;212m'
readonly BLUE=$'\e[38;5;159m'
readonly ORANGE=$'\e[38;5;208m'
readonly TEAL=$'\e[38;5;192m'
readonly VIOLET=$'\e[38;5;219m'
readonly GRAY=$'\e[38;5;246m'
readonly DARK_GRAY=$'\e[38;5;242m'

# Script Defaults
LOG_LVL=0

# Default Log Handlers

function log_info()
{
    printf "• %s \n" "$@" 1>&2
}

function log_success()
{
    printf "%s• %s %s\n" "${GREEN}" "$@" "${NC}" 1>&2
}

function log_warning()
{
    printf "%s• %s %s\n" "${YELLOW}" "$@" "${NC}" 1>&2
}

function log_error()
{
    printf "%s• %s %s\n" "${RED}" "$@" "${NC}" 1>&2
}

function log_debug()
{
    if [[ $LOG_LVL -gt 0  ]]; then
        printf "%s• %s %s\n" "${GRAY}" "$@" "${NC}" 1>&2
    fi
}

function log_notice()
{
    printf "%s• %s %s\n" "${TEAL}" "$@" "${NC}" 1>&2
}

function log_variable()
{
    local var
    var="$1"
    if [[ $LOG_LVL -gt 0  ]]; then
        printf "%s» %-20s - %-10s %s\n" "${GRAY}" "${var}" "${!var}" "${NC}" 1>&2
    fi
}
## END AUTO-GENERATED CONTENT ##

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
function check_deps()
{
    local missing_deps=0

    if ! has_command git-chglog; then
        log_error "Missing git-chglog. Please install git-chglog (v0.11.2 and above)"
        log_info "from https://github.com/git-chglog/git-chglog."
        ((missing_deps++))
    else
        log_debug "deps: git-chgog is available"
    fi

    if ! has_command git; then
        log_error "Missing git. Please install git"
        ((missing_deps++))
    else
        log_debug "deps: git is available"
    fi

    if [[ $missing_deps -ne 0 ]]; then
        log_error "Missing one or more dependencies!"
        exit 2
    else
        log_debug "deps: satisfied"
    fi
}



function build_regex()
{
    if [[ -n ${NEXT_TAG} ]]; then
        log_debug "build-regex: using next tag - ${NEXT_TAG}"
        if git show-ref --tags --quiet --verify -- "refs/tags/${NEXT_TAG}"; then
            log_error "build-regex: next tag specified already exists in git"
            exit 1
        fi
        tag="$NEXT_TAG"
    else
        log_debug  "build-regex: get closest tag"
        tag="$(git describe --tags --abbrev=0 2> /dev/null)"
        if [[ -z $tag ]]; then
            log_error "build-regex: there are no tags in this repository"
            log_error "build-regex: please use --next or create a tag"
            exit 1
        fi
    fi

    # validate tag is a valid semver tag
    if [[ ${tag} =~ $SEMVER_REGEX ]]; then
        log_debug "build-regex: ${tag} is valid semver"
        major="${BASH_REMATCH[1]}"
        minor="${BASH_REMATCH[2]}"
        patch="${BASH_REMATCH[3]}"
        pre="${BASH_REMATCH[4]:1}"
        build="${BASH_REMATCH[8]:1}"
    else
        log_error "build-regex: ${tag} is not semver tag!"
        log_debug "build-regex: all tags must be semver compatible"
        exit 1
    fi


    log_debug "build-regex: tag major - $major"
    log_debug "build-regex: tag minor - $minor"
    log_debug "build-regex: tag patch - $patch"
    log_debug "build-regex: tag pre   - $pre"
    log_debug "build-regex: tag build - $build"

    # Build Regex to filter tags
    # https://regex101.com/r/0EiAvH/1/
    if [[ $pre == "" ]]; then
        tag_filter="[vV]?[\d]+\.[\d]+\.[\d]+\$"
    else
        tag_filter="[vV]?${major}\.${minor}\.${patch}-(alpha|beta|rc|qa|migration)([0-9]+)?\$|[0-9]+\.[0-9]+\.[0-9]+\$"
    fi

    log_debug "build-regex: chglog tag filter regex is ${tag_filter}"

}


function display_usage()
{
cat 1>&2 <<EOF
Changelog and Release Notes generation helper.

Usage: ${TEAL}${SCRIPT} ${BLUE} [options] ${NC}${VIOLET}
------------------------- Options ------------------------------${NC}
[-c | --changelog]        Generate Changelog
[-r | --release-notes]    Generate Release notes
${ORANGE}
---------------- Options with Required Argments-----------------${NC}
[-o | --output]           Save changelog to a file specified

[-n | --next]             Specify next version.
[--olderst-tag]           Oldest semver tag till which changelog
                          will be generated. This must exist and
                          has no effect on release-notes option.
[--header-file]           This file will be appended to begining of the
                          changelog.
[--footer-file]           This file will be appended to end of the
                          changelog.
--------------------- Debugging & Help -------------------------${NC}
[-v | --verbose]          Enable verbose loggging.
[-h | --help]             Display this help message.
EOF
}


function main()
{
    if [[ $# -lt 1 ]]; then
      log_error "No arguments specified"
      display_usage
    fi

    while [[ ${1} != "" ]]; do
        case ${1} in
            -c | --changelog)       mode="changelog";;
            -r | --release-notes)   mode="release-notes";;
            # Options
            -n | --next)            readonly bool_use_next_mode="true";
                                    shift;readonly NEXT_TAG="${1}";;
            # Header and Footer Files
            -o | --output)          shift;readonly output_file="${1}";;
            --header-file)          shift;readonly header_file="${1}";;
            --footer-file)          shift;readonly footer_file="${1}";;
            # useful to merge old changelogs with autogenerated ones
            --oldest-tag)           shift;readonly oldest_tag="${1}";;
            # Debugging options
            -d | --debug)           LOG_LVL="1";
                                    log_debug "main: enable verbose logging";;
            -h | --help )           display_usage;exit 0;;
            * )                     log_error "Invalid argument(s). See usage below.";
                                    display_usage;
                                    exit 1;
        esac
        shift
    done

    # validate --next is a valid semver tag
    if [[ $bool_use_next_mode == "true" ]]; then
        if [[ ! $NEXT_TAG =~ $SEMVER_REGEX ]]; then
            log_error "main: --next tag $NEXT_TAG is invalid"
            exit 1
        else
            log_debug "main: --next tag is valid semver tag"
        fi
    fi

    # Header file
    if [[ $header_file != "" ]]; then
        log_debug "main: using header file: ${header_file}"
        if [[ ! -e $header_file ]]; then
            log_error "man: specified header file ${header_file} not found!"
            exit 1
        else
            readonly HEADER_FILE_CONTENTS="$(cat "$header_file")"
            if [[ -z $FOOTER_FILE_CONTENTS ]]; then
                log_error "main: footer file is empty!"
                exit 1
            fi
        fi
    fi

    # Footer file
    if [[ $footer_file != "" ]]; then
        log_debug "main: using footer file: ${footer_file}"
        if [[ ! -e $footer_file ]]; then
            log_error "main: specified footer file ${footer_file} not found!"
            exit 1
        else
            readonly FOOTER_FILE_CONTENTS="$(cat "$footer_file")"
            if [[ -z $FOOTER_FILE_CONTENTS ]]; then
                log_error "main: footer file is empty!"
                exit 1
            fi
        fi
    fi

    # Output file is specified
    if [[ -n $output_file ]]; then
        output_dir="$(dirname "${output_file}")"
        log_debug "main: output will be saved to dir=$output_dir, file=$(basename "$output_file")"
        if [[ ! -d ${output_dir} ]]; then
            log_error "output was specified but dir $output_dir does not exist!"
            exit 1
        fi
    fi

    # check if a git repo
    if [[ $(git rev-parse --is-inside-work-tree) != "true" ]]; then
        log_error "main: not a git repository!"
        exit 1
    fi

    # if oldest tag was specified
    if [[ -n $oldest_tag ]]; then
        log_debug "main: will generate tags till oldest tag - $oldest_tag"
        if ! git show-ref --tags --quiet --verify -- "refs/tags/${oldest_tag}"; then
            log_error "main: oldest tag was specified but the tag does not exist in git!"
            exit 1
        fi
        readonly CHANGELOG_ARGS="$oldest_tag.."
    fi

    # check for deps
    check_deps

    # acquire_tag_tag
    build_regex

    if [[ $mode == "changelog" ]]; then
        log_debug "main: generating changelog"

        if [[ -n ${NEXT_TAG} ]]; then
            CHANGELOG_CONTENT="$(git-chglog \
                --next-tag="${NEXT_TAG}" \
                --tag-filter-pattern="${tag_filter}" \
                "${CHANGELOG_ARGS}")"
        else
            CHANGELOG_CONTENT="$(git-chglog \
                --tag-filter-pattern="${tag_filter}" \
                "${CHANGELOG_ARGS}")"
        fi

        if [[ -z $CHANGELOG_CONTENT ]]; then
            log_error "main: failed to generate changelog"
            exit 1
        else
            if [[ -n $output_file ]]; then
                log_debug "main: saving changelog to $output_file"
                echo "${HEADER_FILE_CONTENTS}${CHANGELOG_CONTENT}${FOOTER_FILE_CONTENTS}" > "${output_file}"
            else
                echo "${HEADER_FILE_CONTENTS}${CHANGELOG_CONTENT}${FOOTER_FILE_CONTENTS}"
            fi
        fi

    # release notes
    elif [[ $mode == "release-notes" ]]; then
        log_debug "main: generating release notes"

        if [[ -n ${NEXT_TAG} ]]; then
            RN_CONTENT="$(git-chglog \
                --template "${REPO_ROOT:-.}/.chglog/RELEASE_NOTES.md.tpl" \
                --next-tag="${NEXT_TAG}" \
                --tag-filter-pattern="${tag_filter}" \
                "${tag}")"
        else
            RN_CONTENT="$(git-chglog \
                --template "${REPO_ROOT:-.}/.chglog/RELEASE_NOTES.md.tpl" \
                --tag-filter-pattern="${tag_filter}" \
                "${tag}")"
        fi

        if [[ -z $RN_CONTENT ]]; then
            log_error "main: failed to generate release notes"
            exit 1
        else
            if [[ -n $output_file ]]; then
                log_debug "main: saving release notes to $output_file"
                echo "${HEADER_FILE_CONTENTS}${RN_CONTENT}" > "${output_file}"
            else
                echo "${HEADER_FILE_CONTENTS}${RN_CONTENT}"
            fi
        fi
    else
        log_error "main: no mode specified"
        exit 1
    fi

}

main "$@"
