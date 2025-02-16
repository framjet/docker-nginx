#!/bin/sh

set -e

ME=$(basename "$0")

entrypoint_log() {
    if [ -z "${NGINX_ENTRYPOINT_QUIET_LOGS:-}" ]; then
        echo "$@"
    fi
}

# Function to parse and execute wait4x for WAIT_FOR_* variables
process_wait_for() {
  for var in $(env | awk -F= '/^WAIT_FOR_/ {print $1}'); do
    value=$(printenv "$var")
    hostport=$(echo "$value" | cut -d'#' -f1)
    timeout=$(echo "$value" | cut -d'#' -s -f2)
    timeout=${timeout:-120s} # Default to 120s if not provided

    entrypoint_log "$ME: Waiting for \"$hostport\" with timeout \"$timeout\""
    wait4x tcp "$hostport" --timeout "$timeout"
  done
}

# Function to process and execute wait4x for WAIT_CMD_FOR_* variables
process_wait_cmd_for() {
  for var in $(env | awk -F= '/^WAIT_CMD_FOR_/ {print $1}'); do
    value=$(printenv "$var")
    entrypoint_log "$ME: Executing wait4x command: \"$value\""
    wait4x $value
  done
}

# Execute the functions
process_wait_for
process_wait_cmd_for

exit 0
