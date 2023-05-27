#!/bin/bash

# functions.sh -------------------------------------------------------------------------------------
#
# Script Description:
#    This script contains functions used by all the scripts
#
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
# Configuration
# --------------------------------------------------------------------------------------------------
# Logging
VERBOSE=true
REQUIREMENTS='requirements.txt'


# --------------------------------------------------------------------------------------------------
# Functions
# --------------------------------------------------------------------------------------------------
log() {
    printf '%s %s\n' "$(date -u +"%Y-%m-%dT%H:%M:%S:%3NZ") $1 | $2"
    return
}

log_dev() {
    $VERBOSE && log "DEV  " "$1"
    return
}

log_info() {
    log "INFO " "$1"
    return
}

log_warn() {
    log "WARNING" "$1"
    return
}

log_error() {
    log "ERROR" "$1"
    return
}

lock() {
    touch "$1.lock"
}

unlock() {
    rm "$1.lock" 2> /dev/null
}

is_locked() {
    [ -f "$1.lock" ] && return 0 || return 1
}

exit_if_locked() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            - | -- | -* | --* )
                shift
            ;;
            * )
                is_locked $1
                if (( $? == 0 )); then
                    log_dev "Execution is locked for '$1'. Skipping..."
                    exit 0
                fi
                shift
            ;;
        esac
    done
}
