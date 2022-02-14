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
