#!/usr/bin/env bash
#
# Basic logging functions with filters
#

# RFC-5424 log levels
declare -A LOG_LEVELS
LOG_LEVELS=([DEBUG]=7 [INFO]=6 [NOTICE]=5 [WARNING]=4 [ERROR]=3 [CRITICAL]=2 [ALERT]=1 [EMERGENCY]=0)

# Current (default) filter level
log_level=${LOG_LEVELS[WARNING]}

# log <level> <msg> [msg...]
#
#   Format log line and write to stderr. Lines are formatted as:
#     YYYY-mm-dd HH:MM:SS+ZZ:ZZ LEVEL (func_name) Message
#
log() {
    _log "${@}";
}
_fmt() {
    # caller is three stackframes back (_fmt, _log, log, <caller>)
    local level="$1" cmd="${FUNCNAME[3]}"
    shift
    printf "%s %s (%s) %s\n" "$(date +%Y-%m-%dT%H:%M:%S%z)" \
            "$level" "$cmd" "$@"
}
_log() {
    local level="$1" line=""
    shift
    [ -z "${LOG_LEVELS[$level]+isset}" ] && return 1
    [ "${LOG_LEVELS[$level]}" -gt "$log_level" ] && return 0
    if [ -t 0 ]; then
        >&2 _fmt "$level" "$@"
    else
        while read -r line; do
            if [ -n "$*" ]; then
                line="$* $line";
            fi
            >&2 _fmt "$level" "$line"
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
die()    { _log EMERGENCY "${@}"; exit 1; }
alert()  { _log ALERT "${@}"; }
crit()   { _log CRITICAL "${@}"; }
error()  { _log ERROR "${@}"; }
warn()   { _log WARNING "${@}"; }
notice() { _log NOTICE "${@}"; }
info()   { _log INFO "${@}"; }
debug()  { _log DEBUG "${@}"; }


### Example usage ###

# <script>        # WARNING (default)
# <script> -vv    # INFO (default + 2 verbosity)
# <script> -q     # disabled (reset level)
# <script> -qvvv  # CRITICAL (reset + 3 verbosity)
while getopts ":vq" opt;
do
    case $opt in
        v)
            log_level=$((log_level + 1))
            ;;
        q)
            log_level=-1
            ;;
  esac
done

foo() {
    debug "example"
    info "example"
    notice "example"
    warn "example"
    error "example"
    crit "example"
}

# example main
alert "log level set to '$(get_level_name "$log_level")'"
foo
notice "example"
log ERROR "example"
echo -e "multi\nline\npipe" | log INFO "pipe:"
echo "" | log ERROR "pipe:"
die "example"

echo "Never reached!"
