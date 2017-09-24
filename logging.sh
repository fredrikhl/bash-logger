#!/usr/bin/env bash
#
# Basic logging functions with filters
#

# RFC-5424 log levels
declare -A LOG_LEVELS
LOG_LEVELS=([DEBUG]=7 [INFO]=6 [NOTICE]=5 [WARNING]=4 [ERROR]=3 [CRITICAL]=2 [ALERT]=1 [EMERGENCY]=0)

# Current (default) filter level
LOG_LEVEL=${LOG_LEVELS[WARNING]}

# log <level> <msg> [msg...]
#
#   Format log line and write to stderr. 
#
log() {
    _logging_log "${@}";
}

# _logging_fmt <level> <msg> [msg...]
#
#   Print formatted message.  Redefine for custom formatting.
#   This implementation formats lines as:
#     YYYY-mm-dd HH:MM:SS+ZZ:ZZ LEVEL (func_name) Message
#
_logging_fmt() {
    # caller is three stackframes back (_logging_fmt, _logging_log, log, <caller>)
    local level="$1" cmd="${FUNCNAME[3]}"
    shift
    printf "%s %s (%s) %s\n" "$(date +%Y-%m-%dT%H:%M:%S%z)" \
            "$level" "$cmd" "$@"
}

# _logging_out <msg> [msg...]
#
#   Write log line to stderr. Redefine for custom output.
#
_logging_out() {
    >&2 echo "$@"
}

# _log <level> <msg> [msg...]
#
#   Validates and filters records according to <level>, reads record from stdin,
#   formats and outputs a log record.
#
_logging_log() {
    local level="$1" line=""
    shift
    [ -z "${LOG_LEVELS[$level]+isset}" ] && return 1
    [ "${LOG_LEVELS[$level]}" -gt "$LOG_LEVEL" ] && return 0
    if [ -t 0 ]; then
        _logging_out "$(_logging_fmt "$level" "$@")"
    else
        while read -r line; do
            if [ -n "$*" ]; then
                line="$* $line";
            fi
            _logging_out "$(_logging_fmt "$level" "$line")"
        done
    fi
}

# get_level_name <0..7>
#
#   Get log level name from numeric value.
#
get_level_name() {
    local level="" value="${1}"
    for level in "${!LOG_LEVELS[@]}"; do
       [ "${LOG_LEVELS[$level]}" -eq "${value}" ] && echo "${level}" && return 0
    done
    return 1
}

# helper functions for each level
die()    { _logging_log EMERGENCY "${@}"; exit 1; }
alert()  { _logging_log ALERT "${@}"; }
crit()   { _logging_log CRITICAL "${@}"; }
error()  { _logging_log ERROR "${@}"; }
warn()   { _logging_log WARNING "${@}"; }
notice() { _logging_log NOTICE "${@}"; }
info()   { _logging_log INFO "${@}"; }
debug()  { _logging_log DEBUG "${@}"; }
