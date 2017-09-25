#!/usr/bin/env bash
#
# Example usage
#
# <script>        # WARNING (default)
# <script> -vv    # INFO (default + 2 verbosity)
# <script> -q     # disabled (reset level)
# <script> -qvvv  # CRITICAL (reset + 3 verbosity)
#

source ./logging.sh

# Current (default) filter level
LOG_LEVEL=${LOG_LEVELS[WARNING]}

while getopts ":vq" opt;
do
    case $opt in
        v)
            LOG_LEVEL=$(( LOG_LEVEL + 1 ))
            ;;
        q)
            LOG_LEVEL=-1
            ;;
  esac
done

example_func() {
    debug "example"
    info "example"
    notice "example"
    warn "example"
    error "example"
    crit "example"
    alert "example"
}

# Current level after getopts
alert "log level set to '$(get_level_name "$LOG_LEVEL")'"

# Log output from a function
example_func

# Regular logging
notice "example"
log ERROR "example"

# Pipe log line
echo "piped line" | notice
echo "piped line" | notice "prefix:"

# Pipe multiline input
echo -e "multi\nline\npipe" | log INFO "pipe:"

# Pipe empty message
echo "" | log ERROR "pipe:"

# die
die "example"

echo "Never reached!"
