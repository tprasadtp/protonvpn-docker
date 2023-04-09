#!/bin/bash
# Copyright (c) 2022, Prasad Tengse
# SPDX-License-Identifier: GPL-3.0

set -o pipefail

# Minimum bash version checks
if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
    printf "protonwire requires Bash version >= 4.2" 1>&2
    exit 1
elif [[ ${BASH_VERSINFO[1]} -eq 4 ]] && [[ ${BASH_VERSINFO[1]} -lt 2 ]]; then
    printf "protonwire requires Bash version >= 4.2" 1>&2
    exit 1
fi

# Handle Signals
trap __cleanup_bg_tasks EXIT
trap __sigterm_handler SIGTERM
trap __sigint_handler SIGINT
trap __sigabrt_handler SIGABRT

function __sigterm_handler() {
    log_warning "Received SIGTERM, exiting..."
    if __protonvpn_disconnect; then
        log_info "Helathcheck errors - $__PROTONWIRE_HC_ERRORS"
        if [[ $__PROTONWIRE_HC_ERRORS == "0" ]]; then
            exit 0
        fi
    fi
    exit 1
}

function __sigint_handler() {
    log_warning "Received SIGINT, exiting..."
    __protonvpn_disconnect
    exit 1
}

# SIGABRT is not supported on containers
# It will never be trapped as tini or catatonit
# will never forward the signal to the process
# Its here for systemd watchdog compatibility
function __sigabrt_handler() {
    log_warning "Received SIGABRT, exiting..."
    __protonvpn_disconnect
    exit 1
}

function __print_version() {
    local GORELEASER_DYN_VERSION="dev"
    local GORELEASER_DYN_COMMMIT="HEAD"
    printf "protonwire version %s(%s)\n" "$GORELEASER_DYN_VERSION" "$GORELEASER_DYN_COMMMIT"
}

#diana::snippet:bashlib-logger:begin#
# shellcheck shell=bash
# shellcheck disable=SC3043

# SHELL LOGGING LIBRARY
# See https://github.com/tprasadtp/shlibs/logger/README.md
# If included in other files, contents between snippet markers
# might automatically be updated (depending on who manages it)
# and all changes between markers might be ignored.

function __is_stderr_colorable() {
    # CLIFORCE is set and CLIFORCE != 0, force colors
    if [[ -n ${CLIFORCE} ]] && [[ ${CLIFORCE} != "0" ]]; then
        return 0

    # CLICOLOR == 0 or NO_COLOR is set and not empty
    # TERM is dumb or linux
    elif [[ -n ${NO_COLOR} ]] ||
        [[ ${CLICOLOR} == "0" ]] ||
        [[ ${TERM} == "dumb" ]] ||
        [[ ${TERM} == "linux" ]]; then
        return 1
    fi

    if [[ -t 2 ]]; then
        return 0
    fi
    return 1
}

function __is_stdout_colorable() {
    # CLIFORCE is set and CLIFORCE != 0, force colors
    if [[ -n ${CLIFORCE} ]] && [[ ${CLIFORCE} != "0" ]]; then
        return 0

    # CLICOLOR == 0 or NO_COLOR is set and not empty
    # TERM is dumb or linux
    elif [[ -n ${NO_COLOR} ]] ||
        [[ ${CLICOLOR} == "0" ]] ||
        [[ ${TERM} == "dumb" ]] ||
        [[ ${TERM} == "linux" ]]; then
        return 1
    fi

    if [[ -t 1 ]]; then
        return 0
    fi
    return 1
}

# Logger core ::internal::
# This function should NOT be called directly.
function __logger_core_event_handler() {
    [[ $# -lt 2 ]] && return 1

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
    [[ ${LOG_LVL:-20} -gt "${level}" ]] && return

    shift
    local lvl_msg="$*"

    local lvl_color
    local lvl_colorized
    local lvl_reset

    if __is_stderr_colorable; then
        lvl_colorized="true"
        # shellcheck disable=SC2155
        lvl_reset="\e[0m"
    fi

    # Level name in string format
    local lvl_prefix
    # Level name in string format with timestamp if enabled or level symbol
    local lvl_string

    # Log format
    if [[ ${LOG_FMT:-pretty} == "pretty" ]] && [[ -n ${lvl_colorized} ]]; then
        lvl_string="[•]"
    elif [[ ${LOG_FMT} = "full" ]] || [[ ${LOG_FMT} = "long" ]]; then
        printf -v lvl_prefix "%(%FT%TZ)T " -1
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
        [[ -z ${lvl_string} ]] && lvl_string="${lvl_prefix}[TRACE   ]"
        [[ -n "${lvl_colorized}" ]] && lvl_color="\e[38;5;246m"
        ;;
    debug)
        [[ -z ${lvl_string} ]] && lvl_string="${lvl_prefix}[DEBUG   ]"
        [[ -n "${lvl_colorized}" ]] && lvl_color="\e[38;5;250m"
        ;;
    info)
        [[ -z ${lvl_string} ]] && lvl_string="${lvl_prefix}[INFO    ]"
        # Avoid printing color reset sequence as this level is not colored
        [[ -n "${lvl_colorized}" ]] && lvl_reset=""
        ;;
    success)
        [[ -z ${lvl_string} ]] && lvl_string="${lvl_prefix}[SUCCESS ]"
        [[ -n "${lvl_colorized}" ]] && lvl_color="\e[38;5;83m"
        ;;
    notice)
        [[ -z ${lvl_string} ]] && lvl_string="${lvl_prefix}[NOTICE  ]"
        # shellcheck disable=SC2155
        [[ -n "${lvl_colorized}" ]] && lvl_color="\e[38;5;81m"
        ;;
    warning)
        [[ -z ${lvl_string} ]] && lvl_string="${lvl_prefix}[WARNING ]"
        # shellcheck disable=SC2155
        [[ -n "${lvl_colorized}" ]] && lvl_color="\e[38;5;214m"
        ;;
    error)
        [[ -z ${lvl_string} ]] && lvl_string="${lvl_prefix}[ERROR   ]"
        # shellcheck disable=SC2155
        [[ -n "${lvl_colorized}" ]] && lvl_color="\e[38;5;197m"
        ;;
    critical)
        [[ -z ${lvl_string} ]] && lvl_string="${lvl_prefix}[CRITICAL]"
        # shellcheck disable=SC2155
        [[ -n "${lvl_colorized}" ]] && lvl_color="\e[38;5;196m"
        ;;
    *)
        [[ -z ${lvl_string} ]] && lvl_string="${lvl_prefix}[UNKNOWN ]"
        # Avoid printing color reset sequence as this level is not colored
        [[ -n "${lvl_colorized}" ]] && lvl_reset=""
        ;;
    esac

    printf "${lvl_color}%s %s ${lvl_reset}\n" "${lvl_string}" "$lvl_msg" 1>&2
}

# Leveled Loggers
function log_trace() {
    __logger_core_event_handler "trace" "$@"
}

function log_debug() {
    __logger_core_event_handler "debug" "$@"
}

function log_info() {
    __logger_core_event_handler "info" "$@"
}

function log_success() {
    __logger_core_event_handler "success" "$@"
}

function log_warning() {
    __logger_core_event_handler "warning" "$@"
}

function log_warn() {
    __logger_core_event_handler "warning" "$@"
}

function log_notice() {
    __logger_core_event_handler "notice" "$@"
}

function log_error() {
    __logger_core_event_handler "error" "$@"
}

function log_critical() {
    __logger_core_event_handler "critical" "$@"
}

function log_variable() {
    local var="$1"
    local __msg_string
    printf -v __msg_string "%-${4:-22}s : %s" "${var}" "${!var}"
    __logger_core_event_handler "debug" "${__msg_string}"
}

# For logging command outputs
# Pipe output of your command to this function
# This is EXPERIMENTAL FEATURE!!
# If used without a pipe causes script to hang!
# - Accepts two optional arguments.
#  ARG 1 (str) - msg prefix, this will be prefixed with every line of output
function log_tail() {
    local line prefix
    [[ -n $1 ]] && prefix="($1) "
    while read -r line; do
        __logger_core_event_handler "trace" "$prefix$line"
    done
}
#diana::snippet:bashib-logger:end#

# cleanup background tasks
function __cleanup_bg_tasks() {
    declare -a pending_tasks
    readarray -t pending_tasks < <(jobs -p)
    log_debug "Cleaning up background tasks - ${pending_tasks[*]:-NONE}"
    for pid in "${pending_tasks[@]}"; do
        log_debug "Killing PID - $pid with SIGTERM"
        if ! kill -s TERM "$pid" >/dev/null 2>&1; then
            log_warning "Failed to kill PID - $pid"
        fi
    done
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

# Data validation and manipulation
# --------------------------------------------------
function __is_int() {
    if [[ $1 =~ ^[1-9][0-9]+$ ]]; then
        return 0
    fi
    return 1
}

# Validate IPv4 or CIDR.
function __is_valid_ipv4() {
    local IPV4_REGEX="(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))"
    local IPV4_REGEX_SUBNET="([0-9]|[12][0-9]|3[012])"

    local address

    while [[ ${1} != "" ]]; do
        case $1 in
        --cidr | --subnet)
            IPV4_REGEX="${IPV4_REGEX}/${IPV4_REGEX_SUBNET}"
            ;;
        --ip) ;;

        -*)
            log_error "Unknown option: $1"
            return 1
            ;;
        *)
            address="$1"
            ;;
        esac
        shift
    done

    if [[ $address =~ ^$IPV4_REGEX$ ]]; then
        return 0
    fi
    return 1
}

function __is_valid_ipv6() {
    # Yup, its ugly.
    local IPV6_REGEX="(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:))"
    local IPV6_REGEX_SUBNET="([0-9]{1,2}|1[01][0-9]|12[0-8])"

    local address

    while [[ ${1} != "" ]]; do
        case $1 in
        --cidr | --subnet)
            IPV6_REGEX="${IPV6_REGEX}/${IPV6_REGEX_SUBNET}"
            ;;
        --ip) ;;

        -*)
            log_error "Unknown option: $1"
            return 1
            ;;
        *)
            address="$1"
            ;;
        esac
        shift
    done

    if [[ $address =~ ^$IPV6_REGEX$ ]]; then
        return 0
    fi
    return 1
}

# checks if IPv6 is enabled on the system
function __is_ipv6_disabled() {
    if [[ $(sysctl -n net.ipv6.conf.all.disable_ipv6) == "1" ]]; then
        return 0
    elif [[ $(sysctl -n net.ipv6.conf.default.disable_ipv6) == "1" ]]; then
        return 0
    fi
    return 1
}

# Runtime config checks
# --------------------------------------------------
# Check if DEBUG is set
function __is_debug() {
    case "${DEBUG,,}" in
    true | yes | enable | enabled | on | 1)
        return 0
        ;;
    esac
    return 1
}

# Check if DNS leak protection disbaled
function __is_skip_cfg_dns() {

    if [[ ${__PROTONWIRE_DNS_UPDATER,,} == "none" ]]; then
        return 0
    fi

    case ${SKIP_DNS,,} in
    yes | true | enable | enabled | on | 1)
        return 0
        ;;
    esac

    return 1
}

function __is_enable_killswitch() {
    case ${KILLSWITCH,,} in
    yes | true | enable | enabled | on | 1)
        return 0
        ;;
    esac
    return 1
}

# Systemd Checks and wrappers
# -----------------------------------------------------
function __has_notify_socket() {
    if [[ -n $NOTIFY_SOCKET ]]; then
        if [[ -S ${NOTIFY_SOCKET} ]]; then
            return 0
        else
            log_warning "Notify socket '${NOTIFY_SOCKET}' is not a socket!"
        fi
    fi
    return 1
}

# Wrapper for systemd-notify
function __systemd_notify() {

    local status
    local status_prefix
    local status_lock=0

    while [[ ${1} != "" ]]; do
        case ${1} in
        --ready | -r | ready)
            status_prefix="READY="
            status="1"
            ;;
        --stopping)
            status_prefix="STOPPING="
            status="1"
            ;;
        --reloading)
            status_prefix="RELOADING="
            status="1"
            ;;
        --status | -s | status)
            shift
            status_prefix="STATUS="
            status="$1"
            ;;
        --watchdog | -w)
            status_prefix="WATCHDOG="
            status="1"
            ;;
        -*)
            log_warning "Invalid Usage - $1, can only be --status [STATUS] or --ready"
            return 1
            ;;
        *)
            if [[ $1 =~ ^(STATUS|WATCHDOG|READY|STOPPING|RELOADING)=(.*) ]]; then
                status="$1"
            else
                log_error "sd-notify - Invalid status type/message ${1}"
            fi
            ;;
        esac
        shift
    done

    # check if status message is defined
    if [[ -z $status ]]; then
        log_error "Status is not defined or empty!"
        return 1
    fi

    if has_command systemd-notify; then
        if timeout 2s \
            systemd-notify "${status_prefix}${status}" 2>&1 | log_tail "systemd-notify"; then
            return 0
        else
            log_debug "systemd-notify failed to send status ${status}"
        fi
    elif has_command nc; then
        if printf "%s%s" "${status_prefix}" "${status}" |
            timeout 2s nc -w 0 -uU "$NOTIFY_SOCKET" 2>&1 | log_tail "nc-notify"; then
            return 0
        else
            log_debug "nc failed to send status ${status}"
        fi
    else
        log_error "Neither systemd-notify nor nc is available!"
    fi
    return 1
}

# systemd-resolved support default routes in >= 241
function __check_systemd_version() {
    local systemd_version="0"
    if has_command systemctl; then
        declare -a systemctl_version_output
        # systemtl --version usually gives, something like:
        # systemd 248 (248.3-1ubuntu8.2)
        # +PAM +AUDIT +SELINUX ..... <snip>
        # So we need to extract the version number in first line
        readarray -t systemctl_version_output < <(systemctl --version 2>/dev/null)
        log_debug "systemctl --version output: ${systemctl_version_output[0]}"
        if [[ ${#systemctl_version_output[@]} -gt 0 ]]; then
            if [[ ${systemctl_version_output[0]} =~ ^systemd[[:space:]]+([0-9]+)[[:space:]]+\(.*\)$ ]]; then
                systemd_version="${BASH_REMATCH[1]}"
            else
                log_error "systemctl --version did not match expected format"
                return 1
            fi
        else
            log_warning "systemctl --version did not return any output!"
            return 1
        fi
    else
        log_error "systemd is not installed"
        return 1
    fi

    if [[ $systemd_version =~ ^[0-9]+$ ]]; then
        log_debug "systemd version - $systemd_version"
        if [[ $systemd_version -ge 242 ]]; then
            return 0
        else
            log_error "systemd version is too old ($systemd_version), please upgrade to systemd 241 or later"
        fi
    else
        log_error "systemd version is invalid ($systemd_version)"
    fi
    return 1
}

# detect dns update handler
function __detect_dns_updater() {
    log_variable "__PROTONWIRE_DNS_UPDATER"
    if [[ -n $__PROTONWIRE_DNS_UPDATER ]]; then
        return 0
    fi

    if ! __is_skip_cfg_dns; then
        log_debug "Detecting DNS server"
        if has_command systemctl; then
            log_debug "Checking if systemd-resolved is enabled"
            if systemctl is-active --quiet systemd-resolved; then
                log_info "Using systemd-resolved for DNS"
                __PROTONWIRE_DNS_UPDATER="systemd-resolved"
            else
                log_info "systemd-resolved is not running, using resolvconf(8) for DNS"
                __PROTONWIRE_DNS_UPDATER="resolvconf"
            fi
        else
            log_info "Systemd is not installed, using resolvconf(8) for DNS"
            __PROTONWIRE_DNS_UPDATER="resolvconf"
        fi
    else
        log_debug "Skipping DNS configuration"
        __PROTONWIRE_DNS_UPDATER="none"
    fi
    log_variable "__PROTONWIRE_DNS_UPDATER"
}

# sd-notify and watchdog checks
function __sd_notify_checks() {
    local errs=0
    local sd_socket_check="false"

    # sd-watchdog checks
    # check watchdog
    if [[ ${WATCHDOG_USEC} =~ ^[1-9][0-9]+$ ]]; then
        local ping_interval
        ping_interval="$((WATCHDOG_USEC / 2000000))"
        if [[ $ping_interval -lt 10 ]]; then
            log_error "Watchdog ping interval is too low($ping_interval) should be at least 10 secs"
            ((++errs))
        else
            log_debug "Watchdog ping interval is $ping_interval secs"
        fi
    else
        log_debug "WATCHDOG_USEC is not set or invalid"
    fi

    if [[ -n $NOTIFY_SOCKET ]]; then
        if [[ -S $NOTIFY_SOCKET ]]; then
            log_debug "NOTIFY_SOCKET is set to $NOTIFY_SOCKET"
            if ! __systemd_notify --status "Initializing"; then
                log_error "sd_notify socket is not working!"
                ((++errs))
            fi
        else
            log_warning "NOTIFY_SOCKET is set but not a socket"
        fi
    fi

    if [[ $errs -eq 0 ]]; then
        return 0
    fi
    return 1
}

# checks capabilities
function __check_caps() {
    if capsh --has-p=CAP_NET_ADMIN >/dev/null 2>&1; then
        return 0
    else
        log_error "CAP_NET_ADMIN capability is not available!"
        log_error "If running as systemd unit ensure 'AmbientCapabilities' is set to 'CAP_NET_ADMIN'"
        log_error "If running as podman/docker use --cap-add=CAP_NET_ADMIN flag."
    fi
    return 1
}

# check dependencies
function __run_checks() {
    local errs=0

    log_debug "Checking requirements"

    declare -a commands=(
        "curl"    # curl
        "jq"      # jq
        "ip"      # iproute2
        "capsh"   # libcap/libcap2-bin (pulled by iproute2)
        "timeout" # coreutils
        "wg"      # wireguard-tools | wireguard-tools-wg
        "sysctl"  # procps
    )

    # Detect how to update DNS and add required commands
    # to list of commands to check
    __detect_dns_updater

    case ${__PROTONWIRE_DNS_UPDATER,,} in
    systemd-resolved)
        commands+=(
            "resolvectl" # systemd
        )
        ;;
    resolvconf)
        commands+=(
            "resolvconf" # resolvconf | openresolv
        )
        # Check if resolvconf can update /etc/resolv.conf
        if [[ ! -w /etc/resolv.conf ]]; then
            log_error "Cannot update DNS, /etc/resolv.conf is not writable"
            ((++errs))
        else
            log_debug "/etc/resolv.conf is writable"
        fi
        ;;
    none) ;;
    *)
        log_error "Unknown __PROTONWIRE_DNS_UPDATER - ${__PROTONWIRE_DNS_UPDATER:-NA}"
        ((++errs))
        ;;
    esac

    # systemctl is required for checking systemd version,
    # and systemd-resolved status.
    if [[ ${__PROTONWIRE_LOOPER,,} == "systemd" ]] ||
        [[ $__PROTONWIRE_DNS_UPDATER == "systemd-resolved" ]]; then
        commands+=(
            "systemctl" # systemd
        )
    fi

    # Check if all commands are available
    declare -a missing_commands
    for command in "${commands[@]}"; do
        if ! has_command "$command"; then
            ((++errs))
            missing_commands+=("$command")
        fi
    done

    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        log_error "Following commands are missing - ${missing_commands[*]}"
        ((++errs))
    fi

    if [[ $errs -gt 0 ]]; then
        return 1
    fi

    # check systemd requirements
    # Triggered by using
    # - systemd-resolved or
    # - running as a systemd unit
    if [[ $__PROTONWIRE_LOOPER == "systemd" ]] ||
        [[ $__PROTONWIRE_DNS_UPDATER == "systemd-resolved" ]]; then
        if ! __check_systemd_version; then
            return 1
        else
            log_debug "Systemd version is OK"
        fi
    fi

    # If running as loop via --systemd or --container
    # then check if NOTIFY_SOCKET is set
    if [[ $__PROTONWIRE_LOOPER == "systemd" ]]; then
        if ! __sd_notify_checks; then
            ((++errs))
        fi
    elif [[ $__PROTONWIRE_LOOPER == "container" ]]; then
        if ! __sd_notify_checks; then
            ((++errs))
        fi

        # containers cannot change sysctls so check it now
        if [[ $(sysctl -n net.ipv4.conf.all.rp_filter) != "2" ]] &&
            [[ $(sysctl -n net.ipv4.conf.all.src_valid_mark) != "1" ]]; then
            log_error "net.ipv4.conf.all.rp_filter!=2 && net.ipv4.conf.all.src_valid_mark!=1"
            ((++errs))
            log_error "Set one of the sysctls to expected value,"
            log_error "If using docker/podman add --sysctl net.ipv4.conf.all.rp_filter=2 flag to your run command"
            log_error "If using docker-compose add 'net.ipv4.conf.all.rp_filter: 2' under 'sysctls' section for protonvpn service."
            log_error "If using Kubernetes see https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/ to set sysctl values."
        fi
    fi

    # If check systemd variables
    if [[ $__PROTONWIRE_LOOPER == "systemd" ]]; then
        declare -ar systemd_populated_vars=(
            "RUNTIME_DIRECTORY"
            "STATE_DIRECTORY"
            "CACHE_DIRECTORY"
            "LOGS_DIRECTORY"
        )

        for var in "${systemd_populated_vars[@]}"; do
            if [[ -z ${!var} ]]; then
                log_warning "$var is not defined!"
            else
                log_variable "$var"
            fi
        done
    fi

    log_debug "Checking capabilities"
    if ! __check_caps; then
        log_error "Run as root and/or add CAP_NET_ADMIN capability"
        ((++errs))
    fi

    # If IPCHECK_INTERVAL is defined, and it's not
    # 0, then ensure that WATCHDOG_USEC is not defined
    if [[ -n $IPCHECK_INTERVAL ]] &&
        [[ $IPCHECK_INTERVAL != "0" ]] &&
        [[ ${WATCHDOG_USEC} =~ ^[1-9][0-9]+$ ]]; then
        log_error "IPCHECK_INTERVAL(${IPCHECK_INTERVAL}) cannot be used with systemd watchdog WATCHDOG_USEC(${WATCHDOG_USEC})"
        ((++errs))
    fi

    if [[ $errs -eq 0 ]]; then
        return 0
    fi
    return 1
}

# resolvectl wrapper
function __resolvctl_up_hook() {

    # Configure search/routing domains and the
    # default-route boolean before configuring the DNS server
    # as per systemd-resolved documentation recommendation

    if resolvectl domain protonwire0 "~." 2>&1 | log_tail "resolvectl-domain"; then
        log_success "Set routing domain to ~."
    else
        log_error "Failed to set routing domain to ~."
        ((++errs))
    fi

    if resolvectl default-route protonwire0 "true" 2>&1 | log_tail "resolvectl-default-route"; then
        log_success "Set default route"
    else
        log_error "Failed to set default route"
        ((++errs))
    fi

    if resolvectl dns protonwire0 "10.2.0.1" 2>&1 | log_tail "resolvectl-dns"; then
        log_success "Set DNS server to 10.2.0.1"
    else
        log_error "Failed to set DNS server to 10.2.0.1"
        ((++errs))
    fi

    if [[ $errs -eq 0 ]]; then
        return 0
    fi

    return 1
}

function __resolvctl_down_hook() {
    if resolvectl revert protonwire0 2>&1 | log_tail "resolvectl"; then
        log_success "Reverted systemd-resolved configuration for protonwire0"
        return 0
    else
        log_error "Failed to revert systemd-resolved configuration for protonwire0"
        return 1
    fi
}

# Detect cache, runtime data and config paths
function __detect_paths() {
    local cache_dir
    local runtime_dir

    log_variable "CACHE_DIRECTORY"
    log_variable "XDG_CACHE_HOME"

    if [[ -z $CACHE_DIRECTORY ]]; then
        if [[ -n $XDG_CACHE_HOME ]]; then
            if [[ -d "${XDG_CACHE_HOME}" ]] && [[ -w "${XDG_CACHE_HOME}" ]]; then
                cache_dir="${XDG_CACHE_HOME}"
            else
                log_warning "XDG_CACHE_HOME(${XDG_CACHE_HOME}) is not a directory or not writable!"
            fi
        fi
    else
        if [[ -d $CACHE_DIRECTORY ]] && [[ -w $CACHE_DIRECTORY ]]; then
            cache_dir="${XDG_CACHE_HOME}"
        else
            log_warning "CACHE_DIRECTORY($CACHE_DIRECTORY) is not a directory or not writable!"
        fi
    fi

    log_variable "RUNTIME_DIRECTORY"
    log_variable "XDG_RUNTIME_DIR"

    # Runtime files (should be ideally tmpfs)
    if [[ -z $RUNTIME_DIRECTORY ]]; then
        if [[ -n $XDG_RUNTIME_DIR ]]; then
            if [[ -d "$XDG_RUNTIME_DIR" ]] && [[ -w "${XDG_RUNTIME_DIR}" ]]; then
                runtime_dir="$XDG_RUNTIME_DIR"
                if [[ -z ${cache_dir} ]]; then
                    cache_dir="${XDG_RUNTIME_DIR}"
                fi
            else
                log_warning "XDG_RUNTIME_DIR(${XDG_RUNTIME_DIR}) is not a directory or not writable!"
            fi
        fi
    else
        if [[ -d $RUNTIME_DIRECTORY ]] && [[ -w $RUNTIME_DIRECTORY ]]; then
            runtime_dir="${RUNTIME_DIRECTORY}"
            if [[ -z ${cache_dir} ]]; then
                cache_dir="${RUNTIME_DIRECTORY}"
            fi
        else
            log_warning "RUNTIME_DIRECTORY($RUNTIME_DIRECTORY) is not a directory or not writable!"
        fi
    fi

    if [[ -z ${runtime_dir} ]]; then
        runtime_dir="/tmp"
    fi

    if [[ -z ${cache_dir} ]]; then
        cache_dir="/tmp"
    fi

    declare -g __PROTONWIRE_SRV_INFO="${cache_dir%/}/protonwire.serverinfo.json"
    declare -g __PROTONWIRE_HCR="${runtime_dir%/}/protonwire.hc.response"

    log_variable "__PROTONWIRE_SRV_INFO"
    log_variable "__PROTONWIRE_HCR"

}

# looper via --systemd or --container
function protonvpn_looper_cmd() {
    case "$__PROTONWIRE_LOOPER" in
    systemd)
        log_debug "Running as systemd unit, IDENTITY=$(id)"
        ;;
    container | docker)
        log_debug "Running as container"
        ;;
    *)
        log_error "Invalid __PROTONWIRE_LOOPER - $__PROTONWIRE_LOOPER"
        return 1
        ;;
    esac

    if ! __run_checks; then
        log_error "Please fix the errors above and try again!"
        return 1
    fi

    # define paths and dns updater
    __detect_paths
    __detect_dns_updater

    log_variable "PROTONVPN_CHECK_THRESHOLD"
    log_variable "IPCHECK_INTERVAL"

    # connect
    if __protonvpn_connect; then
        # if healthchecks are disabled do not verify IP
        if [[ $IPCHECK_INTERVAL != "0" ]]; then
            log_info "Verifying connection"

            local verify_attemps=0
            local max_verify_attemps="${PROTONVPN_CHECK_THRESHOLD:-3}"
            while [[ $verify_attemps -lt $max_verify_attemps ]]; do
                ((++verify_attemps))
                if __protonvpn_verify_server; then
                    log_success "Connection verified!"
                    break
                else
                    log_error "Retry ($verify_attemps/$max_verify_attemps) after 2 seconds"
                    # allow signals to be handled while sleeping
                    sleep 2 &
                    wait $!
                fi
            done

            if [[ $verify_attemps -ge $max_verify_attemps ]]; then
                log_error "Failed to verify connection!"
                __protonvpn_disconnect
                return 1
            fi
        else
            log_warning "Not verifying connection, healthchecks are disabled"
        fi
    else
        log_error "Failed to connect to ${PROTONVPN_SERVER:-Fastest-Server}"
        if [[ -z $(ip link show protonwire0 type wireguard 2>/dev/null) ]]; then
            return 1
        fi
        __protonvpn_disconnect
        return 1
    fi

    local sleep_int=60
    local watchdog_pings="false"

    # detect ping interval
    # check if watchdog is enabled
    if [[ -n $IPCHECK_INTERVAL ]]; then
        if [[ $IPCHECK_INTERVAL == "0" ]] &&
            [[ ${WATCHDOG_USEC} =~ ^[1-9][0-9]+$ ]]; then
            sleep_int="$((WATCHDOG_USEC / 2000000))"
            log_debug "Watchdog enabled, ping interval $sleep_int seconds"
            watchdog_pings="true"
        elif [[ $IPCHECK_INTERVAL != "0" ]]; then
            sleep_int="$IPCHECK_INTERVAL"
        fi
    else
        if [[ ${WATCHDOG_USEC} =~ ^[1-9][0-9]+$ ]]; then
            sleep_int="$((WATCHDOG_USEC / 2000000))"
            log_debug "Watchdog enabled, ping interval $sleep_int seconds"
            watchdog_pings="true"
        fi
    fi

    # Notify ready if socket is available
    if __has_notify_socket; then
        log_debug "Notifying systemd that we are ready"
        if ! __systemd_notify --ready; then
            log_error "Failed to notify systemd!"
            protonvpn_disconnect
            return 1
        fi

        if ! __systemd_notify --watchdog; then
            log_error "Failed to notify systemd!"
            protonvpn_disconnect
            return 1
        fi
    else
        log_debug "No systemd notify socket found, skiping READY notification"
    fi

    if [[ $IPCHECK_INTERVAL == "0" ]]; then
        log_warning "Healthchecks are disabled"

        log_info "Listening for signal events"
        __PROTONWIRE_HC_ERRORS=0
        while :; do
            if [[ $__PROTONWIRE_DISCONNECTING == "true" ]]; then
                log_debug "Disconnecting because of signal"
                break
            fi

            if [[ $watchdog_pings == "true" ]]; then
                if __has_notify_socket; then
                    if ! __systemd_notify --watchdog; then
                        log_error "Failed to notify systemd watchdog!"
                    fi
                fi
            fi

            sleep "${sleep_int:-60}" &
            wait $!
        done
    else
        log_info "Checking status - every ${sleep_int:-60} seconds"

        declare -g __PROTONWIRE_HC_ERRORS=0
        while :; do
            if [[ $__PROTONWIRE_DISCONNECTING == "true" ]]; then
                log_debug "Disconnect handler is active, exiting loop"
                break
            fi

            if [[ $__PROTONWIRE_HC_ERRORS -ge ${PROTONVPN_CHECK_THRESHOLD:-3} ]]; then
                log_error "Connection verification failed $__PROTONWIRE_CHECK_ERRS times"
                break
            fi

            sleep "${sleep_int:-60}" &
            wait $!

            if ! __protonvpn_verify_server; then
                log_error "Failed to verify connection ($((__PROTONWIRE_HC_ERRORS + 1))/${PROTONVPN_CHECK_THRESHOLD:-3})"
                ((++__PROTONWIRE_HC_ERRORS))
            else
                if [[ $__PROTONWIRE_HC_ERRORS -gt 0 ]]; then
                    log_warning "Connection re-established"
                    __PROTONWIRE_HC_ERRORS=0
                fi

                if [[ $watchdog_pings == "true" ]]; then
                    if __has_notify_socket; then
                        if ! __systemd_notify --watchdog; then
                            log_error "Failed to notify systemd watchdog!"
                        fi
                    else
                        log_warning "NOTIFY_SOCKET is missing!"
                    fi
                fi
            fi
        done
    fi

    if __has_notify_socket; then
        log_debug "Notify to systemd disconnecting"
        if ! __systemd_notify --stopping; then
            log_error "Failed to notify systemd watchdog!"
        fi
    else
        log_debug "No systemd notify socket found, skiping stopping notification"
    fi

    return 1
}

# commands
# ----------------------------------------------------------------------------
function protonvpn_refresh() {
    commands=("curl" "jq" "stat")

    # Check if all commands are available
    declare -a missing_commands
    for command in "${commands[@]}"; do
        if ! has_command "$command"; then
            ((++errs))
            missing_commands+=("$command")
        fi
    done

    if [[ ${#missing_commands[@]} -ne 0 ]]; then
        log_error "Missing commands: ${missing_commands[*]}"
        return 1
    fi

    __detect_paths

    if protonvpn_fetch_metadata; then
        return 0
    fi
    return 1
}

# Metadata cmdlet
function protonvpn_fetch_metadata() {
    # assume metadata is stale
    local metadata_stale="true"
    local force_refresh="${PROTONVPN_FORCE:-false}"
    local wrapped_invocation="false"

    while [[ ${1} != "" ]]; do
        case ${1} in
        --force-refresh | --force | -f)
            force_refresh="true"
            ;;
        --wrapper | -w)
            wrapped_invocation="true"
            ;;
        esac
        shift
    done

    # Check if __PROTONWIRE_SRV_INFO is present
    # and is not older than 60 min
    if [[ -f ${__PROTONWIRE_SRV_INFO} ]]; then
        local current_ts=0
        local metadata_ts=-1

        metadata_ts=$(stat -c %Y ${__PROTONWIRE_SRV_INFO})
        printf -v current_ts '%(%s)T' -1

        if [[ $((current_ts - metadata_ts)) -lt 7200 ]]; then
            metadata_stale="false"
        else
            log_debug "Server info is stale - ${__PROTONWIRE_SRV_INFO}"
        fi
    else
        log_debug "Server info is missing - ${__PROTONWIRE_SRV_INFO}"
    fi

    # Fetch if file is stale or forced
    if [[ $metadata_stale != "false" ]] || [[ $force_refresh == "true" ]]; then
        log_info "Refresing ProtonVPN server metadata"
        local curl_rc="-1"
        # duplicate headers from official app except user-agent

        # we use wait to ensure the term signals can be handled properly
        # this is potentially a long operation (can download ~2MB of data)
        { curl \
            --fail \
            --location \
            --max-time 120 \
            --connect-timeout 20 \
            --silent \
            --show-error \
            --user-agent 'protonwire/v7' \
            --header 'x-pm-appversion: Other' \
            --header 'x-pm-apiversion: 3' \
            --header 'Accept: application/vnd.protonmail.v1+json' \
            --output "${__PROTONWIRE_SRV_INFO}.bak" \
            https://api.protonvpn.ch/vpn/logicals 2>&1 | log_tail "curl" & }
        wait $!
        curl_rc="$?"

        # we save to a backup file as download can faile or be corrupt
        # we want to ensure we don't end up with corrupt json
        if [[ $curl_rc == "0" ]]; then
            # ensure file is json formatted and valid
            if jq -e '.LogicalServers[]' "${__PROTONWIRE_SRV_INFO}.bak" >/dev/null 2>&1; then
                if mv "${__PROTONWIRE_SRV_INFO}.bak" "${__PROTONWIRE_SRV_INFO}"; then
                    log_success "Refreshed ProtonVPN server metadata"
                    return 0
                else
                    log_error "Refreshing ProtonVPN server metadata failed (trampoline error)"
                    return 1
                fi
            else
                log_error "Refreshing ProtonVPN server metadata failed (invalid json)"
                return 1
            fi
        elif [[ $hc_response_rc == 6 ]]; then
            log_error "Failed to refresh ProtonVPN server metadata (failed to resolved api.protonvpn.ch)"
            return 1
        elif [[ $hc_response_rc == 28 ]]; then
            log_error "Failed to refresh ProtonVPN server metadata (timeout)"
            return 1
        else
            log_error "Failed to refresh ProtonVPN server metadata (curl exit code: ${curl_rc})"
            return 1
        fi
    else
        if [[ $wrapped_invocation == "true" ]]; then
            log_debug "Server metadata is already upto date"
        else
            log_success "Server metadata is already upto date"
        fi
        return 0
    fi

    return 1
}

# Healthcheck via status file age
function protonvpn_healthcheck_status_file() {
    if [[ $IPCHECK_INTERVAL == "0" ]]; then
        log_error "Healthchecks are disabled, cannot use status file!"
        return 1
    fi

    # detect valid interval
    # If IPCHECK_INTERVAL is defined, and it's not
    # 0, then ensure that WATCHDOG_USEC is not defined
    # as it can conflict with the systemd watchdog
    if [[ -n $IPCHECK_INTERVAL ]] &&
        [[ ${WATCHDOG_USEC} =~ ^[1-9][0-9]+$ ]]; then
        log_error "IPCHECK_INTERVAL(${IPCHECK_INTERVAL}) cannot be used with systemd watchdog WATCHDOG_USEC(${WATCHDOG_USEC})"
        return 1
    fi

    __detect_paths
    log_debug "Checking via file timestamp (${__PROTONWIRE_HCR})"

    if [[ -z $IPCHECK_INTERVAL ]] &&
        [[ ${WATCHDOG_USEC} =~ ^[1-9][0-9]+$ ]]; then
        local check_interval="$((WATCHDOG_USEC / 2000000))"
    elif [[ -n $IPCHECK_INTERVAL ]]; then
        local check_interval="$IPCHECK_INTERVAL"
    else
        log_debug "No healthcheck interval defined, using default(60)"
        local check_interval="60"
    fi

    if [[ -f ${__PROTONWIRE_HCR} ]]; then
        local hc_time
        hc_time="$(stat -c '%Y' "${__PROTONWIRE_HCR}")"

        local current_ts
        printf -v current_ts '%(%s)T' -1

        local hc_diff="-1"
        hc_diff=$((current_ts - hc_time))

        # this is kind of a hack, because
        # - leap seconds
        # - clock drifts
        # and this just adds buffer of 30 seconds
        if [[ $hc_diff -lt $((check_interval + 30)) ]]; then
            log_success "Healthcheck is up (via status file), last checked ${hc_diff}s ago"
            return 0
        else
            log_error "Healthcheck is down (via status file), last checked ${hc_diff}s ago"
            return 1
        fi
    else
        log_error "Healthcheck response file (${__PROTONWIRE_HCR}) does not exist!"
        log_error "Perhaps Healthchecks are disabled?"
        return 1
    fi
}

# verify connected server via api.protonvpn.ch
function __protonvpn_verify_server() {
    local wrapper="false"

    # Ensure __PROTONWIRE_SRV_INFO is defined
    if [[ -z ${__PROTONWIRE_SRV_INFO} ]]; then
        log_error "__PROTONWIRE_SRV_INFO is undefined!"
        return 1
    fi

    # metadata refresh if required (wrapper to hide message)
    if ! protonvpn_fetch_metadata --wrapper; then
        return 1
    fi

    # check if server info file exists
    if [[ ! -f ${__PROTONWIRE_SRV_INFO} ]]; then
        log_error "Server info file is missing - ${__PROTONWIRE_SRV_INFO}"
        log_error "Please ensure that protonvpn client is running!"
        return 1
    fi

    # check if server info file is readable
    if [[ ! -s ${__PROTONWIRE_SRV_INFO} ]]; then
        log_error "Server info file is not readable or empty - ${__PROTONWIRE_SRV_INFO}"
        log_error "Please ensure that protonvpn client is running!"
        return 1
    fi

    # check if has wireguard interface
    if [[ -z $(ip link show protonwire0 type wireguard 2>/dev/null) ]]; then
        log_error "WireGuard interface - protonwire0 is not present"
        return 1
    else
        log_debug "WireGuard interface - protonwire0 is present"
    fi

    # check if connected to a server
    declare -a configured_endpoints
    readarray -t configured_endpoints < <(wg show protonwire0 peers 2>/dev/null)
    if [[ ${#configured_endpoints[@]} -eq 0 ]]; then
        log_error "WireGuard interface 'protonwire0' is not connected to any peers"
        return 1
    elif [[ ${#configured_endpoints[@]} -gt 1 ]]; then
        log_debug "Connected peers - ${configured_endpoints[*]}"
        log_error "WireGuard interface 'protonwire0' is connected to multiple peers(${#configured_endpoints[@]})"
        return 1
    elif [[ -z ${configured_endpoints[0]} ]]; then
        log_error "WireGuard interface 'protonwire0' unknown error!"
        return 1
    else
        log_debug "Connected peers - ${configured_endpoints[*]}"
    fi

    log_debug "Lookup server name for peer - ${configured_endpoints[0]}"
    declare -a connected_server_name
    readarray -t connected_server_name < <(jq -r \
        --arg PEER_KEY "${configured_endpoints[0]}" \
        '[.LogicalServers[] | select(.Servers[].X25519PublicKey==$PEER_KEY)] | unique_by(.Name) | .[].Name' \
        "${__PROTONWIRE_SRV_INFO}" 2>/dev/null)

    if [[ ${#connected_server_name[@]} -eq 0 ]]; then
        log_error "Unable to lookup server name for peer - ${configured_endpoints[0]}"
        return 1
    elif [[ ${#connected_server_name[@]} -gt 1 ]]; then
        log_error "Multiple server names found for peer - ${configured_endpoints[0]}"
        return 1
    elif [[ -z ${connected_server_name[0]} ]]; then
        log_debug "Unknown error fetching server name for peer - ${configured_endpoints[0]}"
        return 1
    fi

    log_debug "Connected server name - ${connected_server_name[0]}"

    # Parse server info and get list of
    # ExitIPs and EntryIPs for server
    declare -a allowed_exit_ips
    declare -a allowed_entry_ips

    log_debug "Parsing allowed ExitIPs from server metadata"
    readarray -t allowed_exit_ips < <(jq -r \
        --arg PEER_KEY "${configured_endpoints[0]}" \
        '[ .LogicalServers[] | select(.Servers[].X25519PublicKey==$PEER_KEY) | .Servers[] ] | unique_by(.ExitIP) | .[].ExitIP' \
        "${__PROTONWIRE_SRV_INFO}" 2>/dev/null)
    readarray -t allowed_entry_ips < <(jq -r \
        --arg PEER_KEY "${configured_endpoints[0]}" \
        '[ .LogicalServers[] | select(.Servers[].X25519PublicKey==$PEER_KEY) | .Servers[] ] | unique_by(.EntryIP) | .[].EntryIP' \
        "${__PROTONWIRE_SRV_INFO}" 2>/dev/null)

    log_debug "Allowed ExitIPs  - ${allowed_exit_ips[*]}"
    log_debug "Allowed EntryIPs - ${allowed_entry_ips[*]}"
    declare -a allowed_client_public_ips=(
        "${allowed_exit_ips[@]}"
        "${allowed_entry_ips[@]}"
    )

    # check if array not empty!
    if [[ ${#allowed_exit_ips[@]} -eq 0 ]] &&
        [[ ${#allowed_entry_ips[@]} -eq 1 ]]; then
        log_error "Failed to parse allowed Client IPs from - ${__PROTONWIRE_SRV_INFO}"
        return 1
    else
        log_debug "Allowed Client IPs - ${allowed_client_public_ips[*]}"
    fi

    local hc_response
    local hc_response_with_status
    local hc_response_code
    local hc_response_rc=-1

    # Invoke healthcheck API and save response
    log_debug "Checking client IP via api.protonvpn.ch/vpn/location"
    curl \
        --max-time 20 \
        --silent \
        --output "${__PROTONWIRE_HCR}" \
        --fail \
        --location \
        --user-agent "protonvpn-docker" \
        "https://api.protonvpn.ch/vpn/location" 2>/dev/null &
    wait $!
    hc_response_rc="$?"
    log_debug "Healthcheck curl exit code - ${hc_response_rc:-NA}"

    local ts_format
    printf -v ts_format '%(%I:%M:%S %p)T' -1

    if [[ $hc_response_rc == 6 ]]; then
        log_error "Failed to resolve DNS domain (api.protonvpn.ch)"
        return 1
    elif [[ $hc_response_rc == 28 ]]; then
        log_error "curl failed to connect to api.protonvpn.ch (timeout)"
        return 1

    elif [[ $hc_response_rc != 0 ]]; then
        log_error "curl command exited with $hc_response_rc (HTTP response code ${hc_response_code:-NA})"
        return 1
    fi

    # further processing via jq
    local client_ip
    client_ip=$(jq -r '.IP' "$__PROTONWIRE_HCR" 2>/dev/null)
    log_debug "Client IP address - $client_ip"

    if [[ -z $client_ip ]]; then
        log_error "Failed to parse client IP from - ${__PROTONWIRE_HCR}"
        return 1
    fi

    # strip newlines if any
    for exit_ip in "${allowed_client_public_ips[@]}"; do
        if [[ $exit_ip == "${client_ip}" ]]; then
            if __has_notify_socket; then
                log_debug "Connected to ${connected_server_name[0]} (via $client_ip)"
                if ! __systemd_notify --status "Connected to ${connected_server_name[0]} (via $client_ip), verified at $ts_format"; then
                    log_error "Failed to notify status to systemd"
                fi
            else
                log_success "Connected to ${connected_server_name[0]} (via $client_ip)"
            fi
            return 0
        fi
    done
    log_error "Your current IP address - ${client_ip} is not in the list for Server ${connected_server_name[0]}"
    log_error "Your current IP address - ${client_ip} must belong to set (${allowed_client_public_ips[*]})"

    if __has_notify_socket; then
        if ! __systemd_notify --status "IP Mismatch"; then
            log_error "Failed to notify status to systemd"
        fi
    fi

    # return code 20 is used to indicate that the IP is not in the list
    # we use this to trigger a reconnection immediately if running as systemd unit
    return 20
}

# healthcheck
function protonvpn_healthcheck() {
    # define paths
    __detect_paths

    if ! __check_caps; then
        return 1
    fi

    local verify_rc=-1
    __protonvpn_verify_server
    verify_rc="$?"
    if [[ $verify_rc -eq 0 ]]; then
        return 0
    elif [[ $verify_rc -eq 20 ]]; then
        return 20
    fi
    return 1

}

# checks if keyfile is usuable
# Verifies - input is a file
#          - follow symlinks
#          - file is readable
#          - file is not empty
#          - file has correct permissions (660 or better)
#          - file is a valid key
function __is_usable_keyfile() {
    local file_path="$1"

    if [[ -z ${file_path} ]]; then
        log_error "__is_usable_keyfile() requires a file path"
        return 1
    fi

    if [[ -L ${file_path} ]]; then
        log_debug "File - ${file_path} is a symbolic link following it"
        file_path="$(readlink -f "${file_path}")"
    fi

    if [[ -f $file_path ]]; then
        if [[ -r $file_path ]] && [[ -s $file_path ]]; then
            local fp_perms="stat-error"
            fp_perms="$(stat -c '%a' "${file_path}")"
            case $fp_perms in
            400 | 600 | 440 | 640 | 660)
                log_debug "File - ${file_path} has correct permissions (${fp_perms})"
                return 0
                ;;
            *)
                log_warning "File - $file_path has insecure permissions ($fp_perms)"
                return 1
                ;;
            esac
        else
            log_warning "$file_path is not readable or empty!"
        fi
    else
        log_warning "$file_path is not a file!"
    fi
    return 1
}

# Selects server based on criteria
function __protonvpn_config_select_server() {
    local metadata_fetch_tries=0
    local metadata_fetch_max_tries=3
    while [[ $metadata_fetch_tries -lt $metadata_fetch_max_tries ]]; do
        ((++metadata_fetch_tries))
        if protonvpn_fetch_metadata; then
            break
        else
            if [[ $metadata_fetch_tries -lt $metadata_fetch_max_tries ]]; then
                log_error "Retrying after $((2 ** metadata_fetch_tries)) seconds ($metadata_fetch_tries/$metadata_fetch_max_tries)"
                sleep "$((2 ** metadata_fetch_tries))" &
                # allow signals to be handled while sleeping
                wait $!
            fi
        fi
    done

    # Use cached file if failed to fetch metadata,
    # this is most likely due to a network issue
    if [[ $metadata_fetch_tries -gt $metadata_fetch_max_tries ]]; then
        if [[ ! -f ${__PROTONWIRE_SRV_INFO} ]]; then
            log_error "Failed to fetch server metadata after 5 tries"
            log_error "Please check your internet connection and try again!"
            log_error "If you have killswitch enabled please disable it and try again!"
            return 1
        else
            log_warning "Failed to fetch server metadata after 5 tries,using cached file (might be stale)"
        fi
    fi

    # https://github.com/ProtonVPN/protonvpn-nm-lib/blob/1df7462ff242388a4278f6505a0576808a00a6c0/protonvpn_nm_lib/enums.py#L43
    # NORMAL - 0
    # SECURE_CORE - 1
    # TOR - 2
    # P2P - 4
    # STREAMING - 8
    # IPv6 - 16

    # jq processed server names which satisfy plan
    declare -a server_pool=()

    # default use fastest server available in your plan/tier
    if [[ -z ${PROTONVPN_SERVER} ]]; then
        log_warning "Server not specified, Selecting fastest server (Requires paid plan)"
        readarray -t server_pool < <(jq -r \
            '[ .LogicalServers[] | select( (.Tier==2) and (.Status==1) ) ] | sort_by(.Score) | .[].Name' \
            "${__PROTONWIRE_SRV_INFO}" 2>/dev/null)
    elif [[ ${PROTONVPN_SERVER^^} =~ ^([A-Z]{2})\$ ]]; then
        log_info "Selecting fastest server in country ${BASH_REMATCH[1]} (Requires paid plan)"
        readarray -t server_pool < <(jq -r \
            --arg COUNTRY "${BASH_REMATCH[1]}" \
            '[ .LogicalServers[] | select(( .ExitCountry==$COUNTRY) and (.Tier==2) and (.Status==1) ) ] | sort_by(.Score) | .[].Name' \
            "${__PROTONWIRE_SRV_INFO}" 2>/dev/null)
    # FREE
    elif [[ ${PROTONVPN_SERVER^^} == "FREE" ]]; then
        log_info "Selecting fastest free server (Might be sub-optimal for few tasks)"
        readarray -t server_pool < <(jq -r \
            '[ .LogicalServers[] | select( (.Tier==0) and (.Status==1) ) ] | sort_by(.Score) | .[].Name' \
            "${__PROTONWIRE_SRV_INFO}" 2>/dev/null)
    # [CC]-FREE
    elif [[ ${PROTONVPN_SERVER^^} =~ ^([A-Z]{2})\-FREE$ ]]; then
        log_info "Selecting fastest free server in country ${BASH_REMATCH[1]}"
        readarray -t server_pool < <(jq -r \
            --arg COUNTRY "${BASH_REMATCH[1]}" \
            '[ .LogicalServers[] | select(( .ExitCountry==$COUNTRY) and (.Tier==0) and (.Status==1) ) ] | sort_by(.Score) | .[].Name' \
            "${__PROTONWIRE_SRV_INFO}" 2>/dev/null)

    # P2P(3) can be >=4<8, >=12<16, >=20
    elif [[ ${PROTONVPN_SERVER^^} == "P2P" ]]; then
        log_info "Selecting fastest P2P server"
        readarray -t server_pool < <(jq -r \
            '[ .LogicalServers[] | select( ((.Features>=4) and (.Features<8)) or ((.Features>=12) and (.Features<16)) or ((.Features>=20) and (.Features<32)) and (.Status==1)) | {Score: .Score, Name: .Name} ] | sort_by(.Score) | .[].Name' \
            "${__PROTONWIRE_SRV_INFO}" 2>/dev/null)

    # P2P(3) can be >=4<8, >=12<16, >=20
    elif [[ ${PROTONVPN_SERVER^^} =~ ^([A-Z]{2})\-P2P$ ]]; then
        log_info "Selecting fastest P2P server in country ${BASH_REMATCH[1]}"
        readarray -t server_pool < <(jq -r \
            --arg COUNTRY "${BASH_REMATCH[1]}" \
            '[ .LogicalServers[] | select( ( ((.Features>=4) and (.Features<8)) or ((.Features>=12) and (.Features<16)) or ((.Features>=20) and (.Features<32)) ) and (.Status==1) and (.ExitCountry==$COUNTRY) ) ] | sort_by(.Score) | .[].Name' \
            "${__PROTONWIRE_SRV_INFO}" 2>/dev/null)

    # Tor(2) can be
    # - 2(tor),
    # - 3(SecureCore+Secure core),
    # - 6(SecureCore+P2P),
    # - 7(SecureCore+SecureCore+P2P),
    # - 10(SecureCore+streaming)
    # - 14(SecureCore+streaming+P2P)
    # - 15(SecureCore+straming+P2P+SecureCore)
    # - 18(Ipv6+tor)
    # - 19(Ipv6+SecureCore+Secure core),
    # - 22(Ipv6+SecureCore+P2P),
    # - 23(Ipv6+SecureCore+SecureCore+P2P),
    # - 16(Ipv6+SecureCore+streaming)
    # - 30(Ipv6+SecureCore+streaming+P2P)
    # - 31(Ipv6+SecureCore+straming+P2P+SecureCore)
    elif [[ ${PROTONVPN_SERVER^^} == "TOR" ]]; then
        log_info "Collecting available TOR servers"
        readarray -t server_pool < <(jq -r \
            '[ .LogicalServers[] | select( ( (.Features==2) or (.Features==3) or (.Features==6) or (.Features==7) or (.Features==10) or (.Features==14) or (.Features==15) or (.Features==18) or (.Features==19) or (.Features==22) or (.Features==23) or (.Features==26) or (.Features==30) or (.Features==31)) and (.Status==1) ) ] | sort_by(.Score) | .[].Name' \
            "${__PROTONWIRE_SRV_INFO}" 2>/dev/null)

    # SecureCore(1) can be odd
    elif [[ ${PROTONVPN_SERVER^^} =~ ^SECURE[-_]?CORE$ ]]; then
        log_info "Collecting available SECURE_CORE servers"
        readarray -t server_pool < <(jq -r \
            '[ .LogicalServers[] | select( ((.Features%2)==1) and (.Status==1) ) ] | sort_by(.Score) | .[].Name' \
            "${__PROTONWIRE_SRV_INFO}" 2>/dev/null)

    elif [[ ${PROTONVPN_SERVER^^} =~ ^([A-Z]{2})\-SECURE[-_]?CORE$ ]]; then
        log_info "Collecting available SECURE_CORE servers in ${BASH_REMATCH[1]}"
        readarray -t server_pool < <(jq -r \
            --arg COUNTRY "${BASH_REMATCH[1]}" \
            '[ .LogicalServers[] | select( ((.Features%2)==1) and (.Status==1) and (.ExitCountry==$COUNTRY) ) ] | sort_by(.Score) | .[].Name' \
            "${__PROTONWIRE_SRV_INFO}" 2>/dev/null)

    # direct servername like NL-FREE#30
    else
        # check if server is in the list
        local _server_name
        log_info "Checking if $PROTONVPN_SERVER is valid server name"
        _server_name="$(jq -r \
            --arg SERVER_NAME "${PROTONVPN_SERVER^^}" \
            '.LogicalServers[] | select(.Name==$SERVER_NAME) | .Name' \
            "${__PROTONWIRE_SRV_INFO}" 2>/dev/null)"
        if [[ -z $_server_name ]] || [[ $_server_name == "null" ]]; then
            log_error "Unknown server name - ${PROTONVPN_SERVER^^}"
            return 1
        else
            log_success "Server - ${_server_name} exits"
        fi

        # check if server is offline
        local _server_online
        _server_online="$(jq -r \
            --arg SERVER_NAME "${PROTONVPN_SERVER^^}" \
            '.LogicalServers[] | select(.Name==$SERVER_NAME) | .Status' \
            "${__PROTONWIRE_SRV_INFO}" 2>/dev/null)"
        if [[ $_server_online != "1" ]]; then
            log_error "Server ${PROTONVPN_SERVER^^} is offline"
            return 1
        else
            log_success "Server ${PROTONVPN_SERVER^^} is online"
        fi
        # Uppercase is used in server shortnames(normalize)
        server_pool=("${PROTONVPN_SERVER^^}")
    fi

    # check if we have atleast one server!
    if [[ ${#server_pool[@]} -lt 1 ]]; then
        log_error "No servers found for - PROTONVPN_SERVER=${PROTONVPN_SERVER}"
        return 1
    fi

    # now check if we have an active wireguard interface
    if [[ -n $(ip link show protonwire0 type wireguard 2>/dev/null) ]]; then
        log_debug "Wireguard interface 'protonwire0' exists"
        # check if connected to a server
        declare -a configured_endpoints
        readarray -t configured_endpoints < <(wg show protonwire0 peers 2>/dev/null)
        if [[ ${#configured_endpoints[@]} -eq 0 ]]; then
            log_warning "WireGuard interface 'protonwire0' is not connected to any peers"
        elif [[ ${#configured_endpoints[@]} -gt 1 ]]; then
            log_debug "Connected peers - ${configured_endpoints[*]}"
            log_error "WireGuard interface 'protonwire0' is connected to multiple peers"
            log_error "Please run protonvpn disconnect and try again!"
            return 1
        else
            log_debug "Connected peers - ${configured_endpoints[*]}"
            # if we have a peer check its name in server metadata
            if [[ -n ${configured_endpoints[0]} ]]; then
                log_debug "Lookup server name for peer - ${configured_endpoints[0]}"
                declare -a connected_server_name
                readarray -t connected_server_name < <(jq -r \
                    --arg PEER_KEY "${configured_endpoints[0]}" \
                    '[.LogicalServers[] | select(.Servers[].X25519PublicKey==$PEER_KEY)] | unique_by(.Name) | .[].Name' \
                    "${__PROTONWIRE_SRV_INFO}" 2>/dev/null)
                if [[ ${#connected_server_name[@]} -eq 0 ]]; then
                    log_error "Unable to lookup server name for peer - ${configured_endpoints[0]}"
                    return 1
                elif [[ ${#connected_server_name[@]} -gt 1 ]]; then
                    log_error "Multiple server names found for peer - ${configured_endpoints[0]}"
                    return 1
                elif [[ -z ${connected_server_name[0]} ]]; then
                    log_debug "Unknown error fetching server name for peer - ${configured_endpoints[0]}"
                    log_error "Please run protonvpn disconnect and try again!"
                    return 1
                fi

                # check if server is in the criteria
                local connected_peer_is_in_pool="false"
                for server in "${server_pool[@]}"; do
                    if [[ ${connected_server_name[0]} == "$server" ]]; then
                        connected_peer_is_in_pool="true"
                        log_notice "Selecting already connected/configured server ${connected_server_name[0]}"
                        __PROTONWIRE_SELECTED_SERVER="$server"
                        return 0
                    fi
                done

                if [[ $connected_peer_is_in_pool == "false" ]]; then
                    log_error "Existing peer ${configured_endpoints[0]}(${connected_server_name[0]}) is not in the specified server pool"
                    log_error "Please run protonvpn disconnect and try again!"
                    return 1
                fi
            else
                log_warning "WireGuard interface 'protonwire0' exists, but is not connected to any peers"
            fi
        fi
    fi

    # If a large pool is returned >20 lets randomize from first 5 servers
    # Otherwise chose fastest.
    log_debug "Server Pool = ${server_pool[*]}"
    if [[ ${#server_pool[@]} -ge 20 ]]; then
        log_info "Server pool is larger than 20 (${#server_pool[@]}), selecting random server from top 5 servers"
        __PROTONWIRE_SELECTED_SERVER="${server_pool[$((RANDOM % 5))]}"
    else
        log_info "Server pool is less than 20 (${#server_pool[@]}), selecting fastest server"
        __PROTONWIRE_SELECTED_SERVER="${server_pool[0]}"
    fi

    log_notice "Selecting server - ${__PROTONWIRE_SELECTED_SERVER:-unknown}"

    if [[ -z $__PROTONWIRE_SELECTED_SERVER ]]; then
        log_error "Unknown error! No server selected"
        return 1
    fi

}

# hook to enable openvpn
function __resolvconf_up_hook() {
    if has_command resolvconf; then
        if printf "nameserver 10.2.0.1" | timeout 5s resolvconf -a protonwire0.wg 2>&1 | log_tail "resolvconf set"; then
            log_debug "Successfully updated /etc/resolv.conf"
            return 0
        else
            log_error "Failed to update /etc/resolv.conf!"
        fi
    else
        log_error "resolvconf is not installed!"
    fi

    return 1
}

function __resolvconf_down_hook() {
    if has_command resolvconf; then
        if timeout 5s resolvconf -f -d protonwire0.wg 2>&1 | log_tail "resolvconf restore"; then
            log_debug "Successfully restored /etc/resolv.conf"
            return 0
        else
            log_error "Failed to restore /etc/resolv.conf"
        fi
    else
        log_error "resolvconf is not installed!"
    fi
    return 1
}

# Builds list of routable subnets
function __build_subnets() {
    local errs
    if [[ -z $PROTONVPN_ALLOWED_SUBNETS_IPV4 ]]; then
        log_debug "Excluding RFC-1918 subnets(IPv4) except DNS sever from WireGuard table"
        declare -ga __PROTONWIRE_SUBNET_4=(
            "10.2.0.1/32" # DNS server
            "0.0.0.0/5"
            "8.0.0.0/7"
            "11.0.0.0/8"
            "12.0.0.0/6"
            "16.0.0.0/4"
            "32.0.0.0/3"
            "64.0.0.0/3"
            "96.0.0.0/6"
            "100.0.0.0/10"
            "100.128.0.0/9"
            "101.0.0.0/8"
            "102.0.0.0/7"
            "104.0.0.0/5"
            "112.0.0.0/5"
            "120.0.0.0/6"
            "124.0.0.0/7"
            "126.0.0.0/8"
            "128.0.0.0/3"
            "160.0.0.0/5"
            "168.0.0.0/8"
            "169.0.0.0/9"
            "169.128.0.0/10"
            "169.192.0.0/11"
            "169.224.0.0/12"
            "169.240.0.0/13"
            "169.248.0.0/14"
            "169.252.0.0/15"
            "169.255.0.0/16"
            "170.0.0.0/7"
            "172.0.0.0/12"
            "172.32.0.0/11"
            "172.64.0.0/10"
            "172.128.0.0/9"
            "173.0.0.0/8"
            "174.0.0.0/7"
            "176.0.0.0/4"
            "192.0.0.0/9"
            "192.128.0.0/11"
            "192.160.0.0/13"
            "192.169.0.0/16"
            "192.170.0.0/15"
            "192.172.0.0/14"
            "192.176.0.0/12"
            "192.192.0.0/10"
            "193.0.0.0/8"
            "194.0.0.0/7"
            "196.0.0.0/6"
            "200.0.0.0/5"
            "208.0.0.0/4"
            "224.0.1.0/24"
            "224.0.2.0/23"
            "224.0.4.0/22"
            "224.0.8.0/21"
            "224.0.16.0/20"
            "224.0.32.0/19"
            "224.0.64.0/18"
            "224.0.128.0/17"
            "224.1.0.0/16"
            "224.2.0.0/15"
            "224.4.0.0/14"
            "224.8.0.0/13"
            "224.16.0.0/12"
            "224.32.0.0/11"
            "224.64.0.0/10"
            "224.128.0.0/9"
            "225.0.0.0/8"
            "226.0.0.0/7"
            "228.0.0.0/6"
            "232.0.0.0/5"
        )
        declare -a invalid_ipv4_routes=()
    else
        log_debug "ALLOWED_SUBNETS_IPV4 - ${PROTONVPN_ALLOWED_SUBNETS_IPV4}"
        declare -a invalid_ipv4_routes=()
        # shellcheck disable=SC2206
        declare -ga __PROTONWIRE_SUBNET_4=(${PROTONVPN_ALLOWED_SUBNETS_IPV4//,/ })
        if [[ ${#__PROTONWIRE_SUBNET_4[@]} -eq 0 ]]; then
            log_error "No allowed IPv4 routes specified"
            ((++errs))
        else
            for ipv4_route in "${__PROTONWIRE_SUBNET_4[@]}"; do
                if ! __is_valid_ipv4 --subnet "$ipv4_route"; then
                    ((++errs))
                    invalid_ipv4_routes+=("$ipv4_route")
                fi
            done
        fi
    fi

    if [[ -z $PROTONVPN_ALLOWED_SUBNETS_IPV6 ]]; then
        log_debug "Excluding ULA subnets(IPv6) from WireGuard table"
        declare -ga __PROTONWIRE_SUBNET_6=("2000::/3")
        declare -a invalid_ipv6_routes=()
    else
        log_debug "ALLOWED_SUBNETS_IPV6 - ${PROTONVPN_ALLOWED_SUBNETS_IPV6}"
        declare -a __PROTONWIRE_SUBNET_6=()
        declare -a invalid_ipv6_routes=()
        # shellcheck disable=SC2206
        declare -ga __PROTONWIRE_SUBNET_6=(${PROTONVPN_ALLOWED_SUBNETS_IPV6//,/ })
        if [[ ${#__PROTONWIRE_SUBNET_6[@]} -eq 0 ]]; then
            log_error "No allowed IPv6 routes specified"
            ((++errs))
        else
            for ipv6_route in "${__PROTONWIRE_SUBNET_6[@]}"; do
                if ! __is_valid_ipv6 --subnet "$ipv6_route"; then
                    ((++errs))
                    invalid_ipv6_routes+=("$ipv6_route")
                fi
            done
        fi
    fi

    if [[ ${#invalid_ipv4_routes[@]} -gt 0 ]]; then
        log_error "Invalid IPv4 routes specified: ${invalid_ipv4_routes[*]}"
        ((++errs))
    fi

    if [[ ${#invalid_ipv6_routes[@]} -gt 0 ]]; then
        log_error "Invalid IPv6 routes specified: ${invalid_ipv6_routes[*]}"
        ((++errs))
    fi

    if [[ $errs -gt 0 ]]; then
        return 1
    fi
}

# Build route table
function __build_route_table() {
    local table_type="$1"

    case "${table_type}" in
    wireguard)
        table_id="51820"
        ;;
    killswitch)
        table_id="51820"
        ;;
    *)
        log_error "Unknown route table type"
        return 1
        ;;
    esac

    if __is_ipv6_disabled; then
        log_info "IPv6 is disabled, skipping IPv6 routes and rules"
        declare -ar __rt_protos=("4")
    else
        declare -ar __rt_protos=("4" "6")
    fi

    local errs=0

    for proto in "${__rt_protos[@]}"; do
        if [[ $proto == "4" ]]; then
            declare -a desired_routes=("${__PROTONWIRE_SUBNET_4[@]}")
        elif [[ $proto == "6" ]]; then
            declare -a desired_routes=("${__PROTONWIRE_SUBNET_6[@]}")
        fi

        local create_table="false"
        local flush_table="false"
        log_info "Configuring table ($table_id) for IPv$proto"
        if [[ -z $(ip "-${proto}" route show table "$table_id" 2>/dev/null) ]]; then
            log_debug "${table_name} table($table_id) not present or empty(IP$proto)"
            create_table="true"
        else
            log_debug "Route table($table_id) already exists, checking routes"
            local existing_routes

            log_debug "Collecting (IPv$proto) routes from table $table_id"
            existing_routes="$(ip "-${proto}" --json route show table "$table_id" | jq -r '.[].dst' 2>/dev/null)"

            if [[ -z ${existing_routes} ]]; then
                log_warning "No (IPv$proto) routes configured in table"
                create_table="true"
            fi

            # we have a route table already, check if its configured correctly
            log_info "Verifying routes(IPv$proto) in table $table_id"

            for route in "${desired_routes[@]}"; do
                # special handling of /32 route
                __route_regex="(${route}|${route///32/})"

                if [[ "$existing_routes" =~ ${__route_regex} ]]; then
                    log_debug "Route - $route already present in table ($table_id)"
                else
                    log_warning "Route - $route is not present in table ($table_id)"
                    create_table="true"
                    flush_table="true"
                fi
            done
        fi

        if [[ $flush_table == "true" ]]; then
            log_debug "Flush (IPv$proto) ${table_name} table($table_id)"
            if ! ip "-${proto}" route flush table "$table_id" 2>&1 | log_tail "ip route flush"; then
                log_error "Failed to flush ${table_name} table($table_id)"
                ((++errs))
            fi
        else
            log_debug "No need to flush (IPv$proto) ${table_name} table($table_id)"
        fi

        if [[ $create_table == "true" ]]; then
            for route in "${desired_routes[@]}"; do
                if ! ip "-${proto}" route add table "$table_id" dev protonwire0 "$route" 2>&1 | log_tail "ip route"; then
                    log_error "Failed to add route(IPv$proto) - $route to ${table_name} table($table_id)"
                    ((++errs))
                else
                    log_debug "Added route(IPv$proto) - $route to ${table_name} table($table_id)"
                fi
            done
        fi
    done

    if [[ $errs -eq 0 ]]; then
        return 0
    fi
    return 1
}

function __build_route_rules() {
    if __is_ipv6_disabled; then
        log_info "IPv6 is disabled, skipping IPv6 routes and rules"
        declare -ar __rt_protos=("4")
    else
        declare -ar __rt_protos=("4" "6")
    fi

    local errs=0
    for proto in "${__rt_protos[@]}"; do
        declare -a wg_rule_p
        declare -a manual_route_p

        local config_rules="true"

        # There may be multiple rules added with same
        # setting but with diff priority
        log_info "Configuring IP rules (IPv$proto)"
        readarray -t wg_rule_p < <(ip "-${proto}" --json rule | jq '.[] | select((.fwmark=="0xca6c") and (.table=="51820") and (.src=="all")) | .priority' 2>/dev/null)
        readarray -t manual_route_p < <(ip "-${proto}" --json rule | jq '.[] | select((.suppress_prefixlen=0) and (.table=="main") and (.src=="all")) | .priority' 2>/dev/null)
        log_debug "Rule Wiregurad Table - ${wg_rule_p[*]}"
        log_debug "Rule Manual Routes   - ${manual_route_p[*]}"

        if [[ ${#wg_rule_p[@]} -eq 1 ]] && [[ ${#manual_route_p[@]} -eq 1 ]]; then
            if [[ ${wg_rule_p[0]} -lt ${manual_route_p[0]} ]]; then
                log_success "IP(v$proto) rules are already configured"
                config_rules="false"
            else
                log_error "IP(v$proto) rules are configured but have wrong priority!"
            fi
        fi

        if [[ $config_rules != "false" ]]; then
            log_debug "Cleanup old IP(v$proto) rules (if any)"

            while [[ $(ip "-${proto}" rule show 2>/dev/null) == *"lookup 51820"* ]]; do
                log_warning "Removing (IPv$proto) WireGuard table rule"
                if ! ip "-${proto}" rule del not fwmark 51820 table 51820 2>&1 | log_tail "ip rule"; then
                    log_error "Failed to remove rule(IPv$proto) to route traffic via WireGuard"
                    ((++errs))
                fi
            done

            while [[ $(ip "-${proto}" rule show 2>/dev/null) == *"from all lookup main suppress_prefixlength 0"* ]]; do
                log_warning "Removing (IPv$proto) Manual route rule"
                if ! ip "-${proto}" rule delete table main suppress_prefixlength 0 2>&1 | log_tail "ip rule"; then
                    log_error "Failed to remove rule(IPv$proto) for manual routes"
                    ((++errs))
                fi
            done

            log_info "Adding Manual route (IPv$proto) rule"
            if ! ip "-${proto}" add table main suppress_prefixlength 0 2>&1 | log_tail "ip rule"; then
                log_error "Failed to add (IPv$proto) rule to Killswitch"
                ((++errs))
            fi

            log_debug "Adding IP rule for Wireguard Table (51820)"
            if ! ip "-${proto}" rule add not fwmark 51820 table 51820 2>&1 | log_tail "ip rule"; then
                log_error "Failed to add rule to route traffic via WireGuard(51820)"
                ((++errs))
            fi
        fi
    done

    if [[ $errs -eq 0 ]]; then
        return 0
    fi
    return 1
}

function __protonvpn_connect() {
    # We collect all errors and display them together
    # This helps to detect all errors at once.
    local errs=0

    # Get server
    if ! __protonvpn_config_select_server; then
        log_debug "Server is not defined or invalid!"
        return 1
    fi

    if __has_notify_socket; then
        __systemd_notify --status "Connecting to ${__PROTONWIRE_SELECTED_SERVER}"
    fi

    # Get entry IP of server
    # prefer IP than hostnames because DNS might be broken because
    # of broken tunnel.
    declare -a entry_ips
    readarray -t entry_ips < <(jq -r \
        --arg SERVER_NAME "${__PROTONWIRE_SELECTED_SERVER}" \
        '[ .LogicalServers[] | select(.Name==$SERVER_NAME) | .Servers[] | select(.Status==1) ] | unique_by(.EntryIP) | .[].EntryIP' \
        "${__PROTONWIRE_SRV_INFO}" 2>/dev/null)

    log_debug "EntryIPs for $__PROTONWIRE_SELECTED_SERVER - ${entry_ips[*]}"
    if [[ ${#entry_ips[@]} -eq 0 ]]; then
        log_error "No entry IPs found for server ${__PROTONWIRE_SELECTED_SERVER}"
        return 1
    elif [[ ${#entry_ips[@]} -gt 1 ]]; then
        log_info "More than one EntryIP found for server ${__PROTONWIRE_SELECTED_SERVER}, selecting forst IP"
    fi

    if __is_valid_ipv4 "${entry_ips[0]}"; then
        log_info "Peer Endpoint (IPv4) - ${entry_ips[0]}"
    elif __is_valid_ipv6 "${entry_ips[0]}"; then
        log_info "Peer Endpoint (IPv6) - ${entry_ips[0]}"
    else
        log_error "Invalid peer endpoint address - ${entry_ips[0]}"
        return 1
    fi

    # Get public key for entry IP
    declare -a pubkeys_list
    readarray -t pubkeys_list < <(jq -r \
        --arg ENTRY_IP "${entry_ips[0]}" \
        '[ .LogicalServers[] | .Servers[]  | select(.EntryIP==$ENTRY_IP)] | unique_by(.X25519PublicKey) | .[].X25519PublicKey' \
        "${__PROTONWIRE_SRV_INFO}" 2>/dev/null)

    if [[ ${#pubkeys_list[@]} -eq 0 ]]; then
        log_error "Failed to populate public keys for IP - ${__PROTONWIRE_ENDPOINT_IP:-NA}(${#pubkeys_list[@]})"
        return 1
    elif [[ ${#pubkeys_list[@]} -gt 1 ]]; then
        log_warning "More than one public key found for IP - ${__PROTONWIRE_ENDPOINT_IP:-NA}(${#pubkeys_list[@]})"
        return 1
    else
        log_info "Peer PublicKey - ${pubkeys_list[0]}"
    fi

    # Lookup private key
    local wg_client_pubkey
    local WIREGUARD_PRIVATE_KEY_FILE

    if [[ -n $WIREGUARD_PRIVATE_KEY ]]; then
        local __wg_client_pubkey

        # check if WIREGUARD_PRIVATE_KEY is a file
        if [[ -e $WIREGUARD_PRIVATE_KEY ]]; then
            if __is_usable_keyfile "${WIREGUARD_PRIVATE_KEY}"; then
                __wg_client_pubkey=$(wg pubkey <"${WIREGUARD_PRIVATE_KEY}" 2>/dev/null)
                if [[ -n $__wg_client_pubkey ]]; then
                    WIREGUARD_PRIVATE_KEY_FILE="${WIREGUARD_PRIVATE_KEY}"
                    log_success "Using PrivateKeyFile - ${WIREGUARD_PRIVATE_KEY}"
                    wg_client_pubkey="$__wg_client_pubkey"
                else
                    log_error "PrivateKeyFile - $WIREGUARD_PRIVATE_KEY is invalid!"
                    return 1
                fi
            else
                log_error "PrivateKeyFile - $WIREGUARD_PRIVATE_KEY cannot be used!"
                return 1
            fi
        else
            __wg_client_pubkey=$(wg pubkey <<<"${WIREGUARD_PRIVATE_KEY}" 2>/dev/null)
            if [[ -n $__wg_client_pubkey ]]; then
                log_success "WIREGUARD_PRIVATE_KEY(${WIREGUARD_PRIVATE_KEY:0:5}**********) is a valid key"
            else
                log_error "WIREGUARD_PRIVATE_KEY(${WIREGUARD_PRIVATE_KEY:0:5}**********) is not a valid key"
                return 1
            fi
        fi
    else
        log_debug "WIREGUARD_PRIVATE_KEY is not set"

        # Secrets and other variables
        # files in /etc/protonwire always takes precedence
        declare -a lookup_paths=(
            "/etc/protonwire/private-key"
            "/etc/protonwire/protonwire-private-key"
            "/etc/protonwire/wireguard-private-key"
            "/run/secrets/private-key"
            "/run/secrets/protonwire/protonwire-private-key"
            "/run/secrets/protonwire/wireguard-private-key"
        )

        # CREDENTIALS_DIRECTORY is defined if using systemd-creds
        if [[ -n $CREDENTIALS_DIRECTORY ]]; then
            lookup_paths+=("${CREDENTIALS_DIRECTORY%/}/private-key")
            lookup_paths+=("${CREDENTIALS_DIRECTORY%/}/protonwire-private-key")
            lookup_paths+=("${CREDENTIALS_DIRECTORY%/}/wireguard-private-key")
        fi

        for lookup_path in "${lookup_paths[@]}"; do
            if [[ -f ${lookup_path} ]]; then
                if __is_usable_keyfile "${lookup_path}"; then
                    local __wg_client_pubkey
                    __wg_client_pubkey=$(wg pubkey <"${lookup_path}" 2>/dev/null)
                    if [[ -n $__wg_client_pubkey ]]; then
                        WIREGUARD_PRIVATE_KEY_FILE="${lookup_path}"
                        log_success "Using PrivateKeyFile - $lookup_path"
                        wg_client_pubkey="$__wg_client_pubkey"
                        break
                    else
                        log_error "PrivateKeyFile - $lookup_path is invalid!"
                    fi
                else
                    log_error "PrivateKeyFile - $lookup_path cannot be used!"
                fi
            elif [[ -e ${lookup_path} ]]; then
                log_debug "File not found - ${lookup_path} (path is not a file)"
            else
                log_debug "File not found - ${lookup_path}"
            fi
        done
    fi

    if [[ -z $WIREGUARD_PRIVATE_KEY_FILE ]] && [[ -z $WIREGUARD_PRIVATE_KEY ]]; then
        log_error "No usable private key found!"
        return 1
    fi

    # sysctl checks
    if [[ $(sysctl -n net.ipv4.conf.all.rp_filter) == "2" ]]; then
        log_success "net.ipv4.conf.all.rp_filter is already set to 2"
    elif [[ $(sysctl -n net.ipv4.conf.all.src_valid_mark) == "1" ]]; then
        log_success "net.ipv4.conf.all.src_valid_mark is already set to 1"
    else
        log_info "Setting net.ipv4.conf.all.rp_filter to 2"
        if ! sysctl -w net.ipv4.conf.all.rp_filter=2 2>&1 | log_tail "sysctl-net-rp_filter"; then
            log_error "Failed to set net.ipv4.conf.all.rp_filter to 2"
            return 1
        fi
    fi

    # Wireguard interface
    if [[ -n $(ip link show protonwire0 type wireguard 2>/dev/null) ]]; then
        log_notice "WireGuard interface 'protonwire0' already exists"
        local _ipjson
        _ipjson=$(ip --json addr show dev protonwire0)
        if [[ -z $_ipjson ]]; then
            log_error "Failed to get link properties for 'protonwire0'"
            return 1
        fi

        local wg_existing_ip
        local wg_exiting_prefixlen
        local wg_exiting_mtu
        local wg_existing_link_state

        wg_existing_ip="$(jq -r '.[].addr_info[] | select(.family=="inet") | .local' <<<"${_ipjson}" 2>/dev/null)"
        wg_exiting_prefixlen="$(jq -r '.[].addr_info[] | select(.family=="inet") | .prefixlen' <<<"${_ipjson}" 2>/dev/null)"
        wg_exiting_mtu="$(jq -r '.[].mtu' <<<"${_ipjson}" 2>/dev/null)"
        wg_existing_link_state="$(jq -r '.[].operstate' <<<"${_ipjson}" 2>/dev/null)"

        log_debug "Current IPAddress  (protonwire0) : $wg_existing_ip"
        log_debug "Current Prefix     (protonwire0) : $wg_exiting_prefixlen"
        log_debug "Current Link MTU   (protonwire0) : $wg_exiting_mtu"
        log_debug "Current Link State (protonwire0) : $wg_existing_link_state"
    elif [[ -n $(ip link show protonwire0 2>/dev/null) ]]; then
        log_error "Existing 'protonwire0' is not a WireGuard interface"
        return 1
    else
        log_notice "Creating WireGuard Interface - protonwire0"
        if ! ip link add protonwire0 type wireguard 2>&1 | log_tail "ip-link"; then
            log_error "WireGuard Interface creation failed!"
            log_error "Please install WireGuard. For more info see https://www.wireguard.com/install/"
            return 1
        fi
        # init to emtpy
        local wg_existing_ip
        local wg_exiting_prefixlen
        local wg_exiting_mtu
        local wg_existing_link_state
    fi

    # Protonvpn has static ip same for all clients
    if [[ $wg_existing_ip == "10.2.0.2" ]] && [[ $wg_exiting_prefixlen == "32" ]]; then
        log_success "WireGuard interface already has address - 10.2.0.2/32"
    else
        if [[ -n $wg_existing_ip ]]; then
            log_info "Flushing all exiting addresses on WireGuard Interface"
            if ! ip address flush "protonwire0" 2>&1 | log_tail "ip-addr"; then
                log_error "Failed to flush addresses on WireGuard interface 'protowire0'"
                return 1
            fi
        fi
        log_info "Setting WireGuard Interface address - 10.2.0.2"
        if ! ip -4 address add 10.2.0.2/32 dev protonwire0 2>&1 | log_tail "ip-addr"; then
            log_error "Setting address on 'protonwire0' failed!"
            return 1
        fi
    fi

    # MTU
    if [[ $wg_exiting_mtu == "1480" ]]; then
        log_success "WireGuard interface MTU is already set to - 1480"
    else
        log_info "Setting WireGuard interface MTU to 1480"
        if ! ip link set protonwire0 mtu 1480 2>&1 | log_tail "ip-link"; then
            log_error "Setting protonwire0 MTU failed"
            return 1
        fi
    fi

    # Private key
    # check if public key
    if [[ $(wg show protonwire0 public-key) == "${wg_client_pubkey:-none}" ]]; then
        log_success "WireGuard interface already has private key"
    else
        if [[ -n $WIREGUARD_PRIVATE_KEY ]]; then
            if printf "%s" "${WIREGUARD_PRIVATE_KEY}" | wg set protonwire0 private-key /dev/stdin 2>&1 | log_tail "wg-set-key"; then
                log_success "Setting WireGuard private key"
            else
                log_error "Setting WireGuard private key failed"
                return 1
            fi
        elif [[ -n $WIREGUARD_PRIVATE_KEY_FILE ]]; then
            if wg set protonwire0 private-key "${WIREGUARD_PRIVATE_KEY_FILE}" 2>&1 | log_tail "wg-set-key"; then
                log_success "Setting WireGuard private key from $WIREGUARD_PRIVATE_KEY_FILE"
            else
                log_error "Setting WireGuard private key from $WIREGUARD_PRIVATE_KEY_FILE failed"
                return 1
            fi
        else
            log_error "Private key is not defined or not found!"
            return 1
        fi
    fi

    # peers and endpoints
    declare -a configured_endpoints
    readarray -t configured_endpoints < <(wg show protonwire0 endpoints 2>/dev/null)
    if [[ ${#configured_endpoints[@]} -eq 0 ]] || [[ -z ${configured_endpoints[0]} ]]; then
        if wg set protonwire0 peer "${pubkeys_list[0]}" \
            allowed-ips 0.0.0.0/0,::/0 \
            endpoint "${entry_ips[0]}:51820" \
            persistent-keepalive 25 \
            2>&1 | log_tail "wg-set-peer"; then
            log_debug "WireGuard interface is configured with peer - ${pubkeys_list[0]}"
        else
            log_error "Setting WireGuard peer on interface failed"
            return 1
        fi
    elif [[ ${#configured_endpoints[@]} -eq 1 ]]; then
        log_debug "Endpoint - ${configured_endpoints[0]}"

        local ep_mismatch="false"
        if [[ ${configured_endpoints[0]} == *"${pubkeys_list[0]}"* ]]; then
            log_success "WireGuard interface is already configured with peer - ${pubkeys_list[0]}"
        else
            log_error "WireGuard interface is configured wrong peer - ${configured_endpoints[0]}"
            ep_mismatch="true"
        fi

        if [[ ${configured_endpoints[0]} =~ ${entry_ips[0]}\:51820$ ]]; then
            log_success "WireGuard interface is already configured with endpoint - ${entry_ips[0]}"
        else
            log_error "WireGuard interface is configured wrong endpoint - ${configured_endpoints[0]}"
            ep_mismatch="true"
        fi

        if [[ $ep_mismatch == "true" ]]; then
            log_error "Please run protonwire disconnect and try again!"
            return 1
        fi
    else
        log_debug "Connected peers - ${configured_endpoints[*]}"
        log_error "WireGuard interface 'protonwire0' is connected to multiple peers"
        log_error "Please run protonwire disconnect and try again!"
        return 1
    fi

    # Check if link is down if so, bring it up
    if [[ $wg_existing_link_state == "DOWN" ]] || [[ -z $wg_existing_link_state ]]; then
        log_info "Bringing WireGuard interface up"
        if ! ip link set protonwire0 up 2>&1 | log_tail "ip-link"; then
            log_error "Bringing WireGuard interface up failed"
            return 1
        fi
    else
        log_success "WireGuard interface is already UP"
    fi

    # fw mark 0xca6c(51820)
    if [[ $(wg show protonwire0 fwmark) == "0xca6c" ]]; then
        log_success "WireGuard interface fwmark is already set to - 0xca6c"
    else
        if wg set protonwire0 fwmark 0xca6c 2>&1 | log_tail "wg-set-fwmark"; then
            log_success "Setting fwmark on WireGuard interface to - 0xca6c"
        else
            log_error "Setting fwmark on WireGuard interface to - 0xca6c failed!"
            return 1
        fi
    fi

    # Route tables
    if ! __build_subnets; then
        return 1
    fi

    if ! __build_route_table "wireguard"; then
        log_error "Failed to build WireGuard table!"
        return 1
    fi

    if __is_enable_killswitch; then
        if ! __build_route_table "killswitch"; then
            log_error "Failed to build killswitch table!"
            return 1
        fi
    else
        log_debug "Killswitch is disabled, check if Killswitch table is present"
        if __is_ipv6_disabled; then
            log_info "IPv6 is disabled, skipping IPv6 routes and rules"
            declare -ar __rt_protos=("4")
        else
            declare -ar __rt_protos=("4" "6")
        fi

        for proto in "${__rt_protos[@]}"; do
            if [[ -z $(ip "-${proto}" route show table 51820 2>/dev/null) ]]; then
                log_warning "Flush (IPv$proto) Killswitch table (51820)"
                if ! ip "-${proto}" route flush table 51820 2>&1 | log_tail "ip route flush"; then
                    log_warning "Failed to flush IPv$proto Killswitch table(51820)"
                fi
            else
                log_debug "Killswitch table (IPv$proto) 51820 is not present or empty!"
            fi
        done
    fi

    if ! __build_route_rules; then
        log_error "Failed to configure routing rules!"
        return 1
    fi

    # DNS
    if __is_skip_cfg_dns; then
        log_info "Skipping DNS configuration"
    else
        if [[ $__PROTONWIRE_DNS_UPDATER == "systemd-resolved" ]]; then
            if __resolvctl_up_hook; then
                log_success "Successfully configured DNS (systemd-resolved)"
            else
                log_error "Failed to configure DNS (systemd-resolved)"
                return 1
            fi
        elif [[ $__PROTONWIRE_DNS_UPDATER == "resolvconf" ]]; then
            if __resolvconf_up_hook; then
                log_success "Successfully configured DNS (resolvconf)"
            else
                log_error "Failed to configure DNS (resolvconf)"
                return 1
            fi
        else
            log_error "Unknown DNS updater: $__PROTONWIRE_DNS_UPDATER"
            return 1
        fi
    fi

    if __has_notify_socket; then
        __systemd_notify --status "Connected to ${__PROTONWIRE_SELECTED_SERVER}"
    fi
}

function protonvpn_connect_cmd() {
    # We collect all errors and display them together
    # This helps to detect all errors at once.
    local errs=0

    if ! __run_checks; then
        log_error "Please fix the errors and try again!"
        return 1
    fi

    # define paths
    __detect_paths
    __detect_dns_updater

    if __protonvpn_connect; then
        return 0
    fi
    return 1
}

function protonvpn_disconnect_cmd() {
    # We collect all errors and display them together
    # This helps to detect all errors at once.
    local errs=0

    if ! __run_checks; then
        log_error "Please fix the errors and try again!"
        return 1
    fi

    # define paths
    __detect_paths

    if __protonvpn_disconnect; then
        return 0
    fi
    return 1
}

function __protonvpn_disconnect() {
    # Order in which we do ensures that we dont have
    # broken dns on the machine/container during disconnect.
    # This is prone to dns leakage during this
    # short disconnect window.
    __PROTONWIRE_DISCONNECTING="true"

    local errs=0
    if [[ $__PROTONWIRE_DNS_UPDATER == "systemd-resolved" ]]; then
        if __resolvctl_down_hook; then
            log_success "Successfully restored DNS(systemd-resolved)"
        else
            log_error "Failed to restore DNS"
            ((++errs))
        fi
    elif [[ $__PROTONWIRE_DNS_UPDATER == "resolvconf" ]]; then
        if __resolvconf_down_hook; then
            log_success "Successfully restored DNS(resolvconf)"
        else
            log_error "Failed to restore DNS"
            ((++errs))
        fi
    elif [[ $__PROTONWIRE_DNS_UPDATER == "none" ]]; then
        :
    else
        log_error "Unknown DNS updater: $__PROTONWIRE_DNS_UPDATER"
        ((++errs))
    fi

    local skip_ipv6="false"
    if __is_ipv6_disabled; then
        log_info "IPv6 disabled, skipping IPv6 routes and rules"
        skip_ipv6="true"
    fi

    log_info "Removing IP rules"
    while [[ $(ip -4 rule show 2>/dev/null) == *"lookup 51820"* ]]; do
        if ! ip -4 rule del not fwmark 51820 table 51820 2>&1 | log_tail "ip rule"; then
            log_error "Failed to remove rule(IPv4) to route traffic via WireGuard"
            ((++errs))
        fi
    done

    if [[ $skip_ipv6 != "true" ]]; then
        while [[ $(ip -6 rule show 2>/dev/null) == *"lookup 51820"* ]]; do
            if ! ip -6 rule del not fwmark 51820 table 51820 2>&1 | log_tail "ip rule"; then
                log_error "Failed to remove rule(IPv4) to route traffic via WireGuard"
                ((++errs))
            fi
        done
    fi

    # delete table
    if ip -4 route list table 51820 >/dev/null 2>&1; then
        log_debug "Flushing routing table 51820 (IPv4)"
        if ! ip -4 route flush table 51820 2>&1 | log_tail "ip route"; then
            log_error "Failed to flush table 51820"
            ((++errs))
        fi
    else
        log_warning "Table 51820(IPv4) does not exist"
    fi

    if [[ $skip_ipv6 != "true" ]]; then
        if ip -6 route list table 51820 >/dev/null 2>&1; then
            log_debug "Flushing routing table 51820 (IPv6)"
            if ! ip -6 route flush table 51820 2>&1 | log_tail "ip route"; then
                log_error "Failed to flush table 51820"
                ((++errs))
            fi
        fi
    fi

    if [[ -n $(ip link show protonwire0 type wireguard 2>/dev/null) ]]; then
        log_info "Removing WireGuard interface"
        if ! ip link del protonwire0 2>&1 | log_tail "ip link"; then
            log_error "Failed to remove WireGuard interface"
            ((++errs))
        fi
    else
        log_warning "WireGuard interface 'protonwire0' does not exist"
    fi

    if [[ $errs -eq 0 ]]; then
        return 0
    fi
    return 1
}

# debugging for server selection tests
function select_server_cmd() {
    __detect_paths
    if __protonvpn_config_select_server; then
        return 0
    fi
    return 1
}

function display_usage() {
    if __is_stdout_colorable; then
        local NC=$'\e[0m'
        local BOLD=$'\e[1m'
        local YELLOW=$'\e[38;5;220m'
        local BLUE=$'\e[38;5;159m'
        local CYAN=$'\e[38;5;51m'
        local ORANGE=$'\e[38;5;208m'
        local TEAL=$'\e[38;5;192m'
        local PINK=$'\e[38;5;212m'
        local GRAY=$'\e[38;5;246m'
        local LGRAY=$'\e[38;5;240m'
        local MAGENTA=$'\e[38;5;219m'
    fi

    cat <<EOF

${BOLD}ProtonVPN WireGuard Client${NC}

${BOLD}${YELLOW}Usage:${NC} protonwire [OPTIONS...]
${BOLD}${YELLOW}or:${NC} protonwire [OPTIONS...] c|connect [SERVER]
${BOLD}${YELLOW}or:${NC} protonwire [OPTIONS...] d|disconnect
${BOLD}${YELLOW}or:${NC} protonwire [OPTIONS...] r|refresh-metadata
${BOLD}${YELLOW}or:${NC} protonwire [OPTIONS...] check
${BOLD}${YELLOW}or:${NC} protonwire [OPTIONS...] help

${BOLD}${CYAN}Options:${NC}
  -k, --private-key [FILE|KEY]  Wireguard private key or
                                file containing private key.
      --force                   Ignore cache and existing states.
      --container               Run as container entrypoint
                                (Cannot be used with --systemd).
      --systemd                 Run as systemd service.
                                (Cannot be used with --container).
      --skip-dns                Skip configuring DNS
      --check-interval [INT]    IP Check interval in seconds.
  -q, --quiet                   Show only errors
  -v, --verbose,                Show debug logs
  -h, --help                    Display this help and exit
      --version                 Display version and exit

${BOLD}${TEAL}Examples:${NC}
  protonwire connect FREE       Connect to fastest free server
  protonwire connect NL#17      Connect to server NL#17
  protonwire disconnect         Disconnect from current server
  protonwire check              Check if connected to a server

${BOLD}${ORANGE}Files:${NC}
  /etc/protonwire/private-key   WireGuard private key

${BOLD}${MAGENTA}Environment:${NC}
  WIREGUARD_PRIVATE_KEY         WireGuard private key or file
  PROTONVPN_SERVER              ProtonVPN server name
  IPCHECK_INTERVAL              Custom IP check interval in seconds
  SKIP_DNS                      Set to '1' to skip configuring DNS
  DEBUG                         Set this to '1' for debug logs
EOF
}

function main() {
    # exclusive option locks, these only validate cli args not env vars
    declare -i log_lvl_v_lock=0
    declare -i log_lvl_q_lock=0
    declare -i cmd_lock=0
    declare -i looper_lock=0
    declare -i ip_check_lock=0

    local color_mode="auto"
    local cmd_mode="HELP"
    local hc_status_file="false"

    # Toggle debug flag
    if __is_debug; then
        LOG_LVL="0"
    fi

    while [[ ${1} != "" ]]; do
        case ${1} in
        -h | --help | help)
            cmd_mode="HELP"
            ;;
        --version)
            cmd_mode="VERSION"
            ;;
        --verbose | --debug | -v | -vv | -vvv | -vvvv)
            LOG_LVL="0"
            ((++log_lvl_v_lock))
            ;;
        --quiet | --silent | -q)
            LOG_LVL=40
            ((++log_lvl_q_lock))
            ;;
        --color)
            shift
            mode="${1}"
            ;;
        --logfmt | --logformat | --log-fmt | --log-format)
            shift
            LOG_FMT="${1}"
            ;;
        --force | -f)
            PROTONVPN_FORCE="true"
            ;;
        --check-interval | --ipcheck-interval)
            ((++ip_check_lock))
            shift
            IPCHECK_INTERVAL="${1}"
            ;;
        --skip-dns)
            SKIP_DNS="false"
            ;;
        -k | --key | --private-key)
            shift
            WIREGUARD_PRIVATE_KEY="$1"
            ;;
        --container)
            ((++cmd_lock))
            ((++looper_lock))
            cmd_mode="LOOPER"
            __PROTONWIRE_LOOPER="container"
            ;;
        --use-status-file)
            hc_status_file="true"
            ;;
        --systemd)
            ((++cmd_lock))
            ((++looper_lock))
            cmd_mode="LOOPER"
            __PROTONWIRE_LOOPER="systemd"
            ;;
        connect | c)
            ((++cmd_lock))
            cmd_mode="CONNECT"
            ;;
        disconnect | d)
            cmd_mode="DISCONNECT"
            ((++cmd_lock))
            ;;
        check | healthcheck | health-check | status | s)
            cmd_mode="HEALTHCHECK"
            ((++cmd_lock))
            ;;
        update-metadata | refresh-metadata | refresh | r)
            cmd_mode="METADATA_REFRESH"
            ((++cmd_lock))
            ;;
        # For DEBUGGING only
        # The folllowng cmmands ar not covered by API stability gurantees.
        select-server)
            cmd_mode="SELECT_SERVER"
            ((++cmd_lock))
            ;;
        *-)
            log_error "Invalid argument - $1. See usage below."
            display_usage
            exit 1
            ;;
        *)
            PROTONVPN_SERVER="$1"
            ;;
        esac
        shift
    done

    log_variable "PROTONVPN_SERVER"

    # check cli coflicts
    local args_errors=0

    case ${color_mode,,} in
    force | always)
        CLIFORCE="1"
        ;;
    never)
        CLICOLOR="0"
        ;;
    auto) ;;
    *)
        log_error "Invalid --color mode specified - ${color_mode}"
        ((++args_errors))
        ;;
    esac

    # check --debug conflicts with --quiet
    if [[ ${log_lvl_q_lock} -gt 0 ]] && [[ ${log_lvl_v_lock} -gt 0 ]]; then
        log_error "Cannot use --debug/-v and --quiet/-v at the same time."
        ((++args_errors))
    fi

    # Loop mode
    if [[ ${looper_lock} -gt 1 ]]; then
        log_error "Cannot use --container and --systemd at the same time."
        ((++args_errors))
    fi

    # Check if more than one command is specified
    if [[ $cmd_lock -gt 1 ]]; then
        log_error "More than one exclusive command specified!"
        ((++args_errors))
    fi

    # special handling for --use-status-file check
    # which uses hc file to avoid duplicate http requests
    # we skip lot of checks which are not used in this mode
    if [[ $cmd_mode == "HEALTHCHECK" ]] && [[ $hc_status_file == "true" ]]; then
        cmd_mode="HEALTHCHECK_CONTAINER"
    fi

    # check if IPCHECK_INTERVAL
    if [[ -n ${IPCHECK_INTERVAL} ]]; then
        log_variable "IPCHECK_INTERVAL"
        if [[ $IPCHECK_INTERVAL =~ ^[0-9]+$ ]]; then
            if [[ ${IPCHECK_INTERVAL} -eq 0 ]]; then
                :
            elif [[ ${IPCHECK_INTERVAL} -lt 10 ]]; then
                log_error "IPCHECK_INTERVAL must be at-least 10s."
                ((++args_errors))
            fi
        else
            log_error "IPCHECK_INTERVAL must be a positive integer."
            ((++args_errors))
        fi
    fi

    if [[ $args_errors -gt 0 ]]; then
        log_error "See protonwire(1) or protonwire --help for more information."
        exit 1
    fi

    # shellcheck disable=SC2119
    case "${cmd_mode^^}" in
    HEALTHCHECK)
        protonvpn_healthcheck
        exit $?
        ;;
    HEALTHCHECK_CONTAINER)
        protonvpn_healthcheck_status_file
        exit $?
        ;;
    METADATA_REFRESH)
        protonvpn_refresh --force
        exit $?
        ;;
    LOOPER)
        protonvpn_looper_cmd
        exit $?
        ;;
    CONNECT)
        protonvpn_connect_cmd
        exit $?
        ;;
    DISCONNECT)
        protonvpn_disconnect_cmd
        exit $?
        ;;
    SELECT_SERVER)
        select_server_cmd
        exit $?
        ;;
    HELP)
        display_usage
        exit $?
        ;;
    VERSION)
        __print_version
        exit $?
        ;;
    *)
        log_error "Unknown PROTONVPN_EXE_MODE - $cmd_mode"
        exit 10
        ;;
    esac
}

main "$@"