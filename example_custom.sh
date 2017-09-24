#!/usr/bin/env bash
#
# Example with alternate formatting and output
#
# <script>        # WARNING (default)
# <script> -vv    # INFO (default + 2 verbosity)
# <script> -q     # disabled (reset level)
# <script> -qvvv  # CRITICAL (reset + 3 verbosity)
#

source ./logging.sh

# Current (default) filter level
LOG_LEVEL=${LOG_LEVELS[DEBUG]}


# custom format
_logging_fmt() {
    local level="$1"
    shift
    printf "log(%s): %s\n" "$level" "$@"
}

# log to stdout
_logging_out() {
    echo "$@"
}

# do not die
die()    { _logging_log EMERGENCY "${@}"; }

{
    debug "example"
    info "example"
    notice "example"
    warn "example"
    error "example"
    crit "example"
    alert "example"
    die "example"
} 2> /dev/null

echo "end reached"
