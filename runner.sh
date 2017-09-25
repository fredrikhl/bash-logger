#!/usr/bin/env bash
#
# Example usage
#
# <script> -v <command> <opts>
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

shift $(( OPTIND-1 ))

example_func() {
    >&1 echo some output to stdout
    >&2 echo some output to stderr
    >&1 echo more stdout
    >&2 echo more stderr
}

log NOTICE "Running '$*'"
# Ordering of output from stdout and stderr is not guaranteed
{
    eval "$@" 2>&1 1>&3 3>&- | log ERROR ":"
} 3>&1 1>&2 | log INFO ":"
log NOTICE "DONE!"
