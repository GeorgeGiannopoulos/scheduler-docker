#!/bin/bash

# cron-control.sh ----------------------------------------------------------------------------------
#
# Script Description:
#    This script enables/disables a cron-job by given the scheduler's name and one of the arguments
#
# Required Arguments:
#    -e | --enable    : Enable a cron-job
#    -d | --disable   : Disable a cron-job
#    -s | --scheduler : Scheduler name (parent directory)
#    -p | --pattern   : One pattern that corresponds to one of the argument
#
# Optional Arguments:
#    -h | --help  : Help message
#
#
#  NOTE: If pattern matches more than one cron-jobs then all of them will be enabled/disabled
#
# --------------------------------------------------------------------------------------------------


# --------------------------------------------------------------------------------------------------
# Initialize script
# --------------------------------------------------------------------------------------------------
#
# Turn on bash's exit on error (e)
set -e

# Get current directory where the script is located
HERE="$(cd `dirname $0` && pwd -P)"

source "/build/functions.sh"

log_info "Running: ${0##*/}"


# --------------------------------------------------------------------------------------------------
# Arguments
# --------------------------------------------------------------------------------------------------
#
USAGE="
Usage: ${0##*/}
This script enables/disables a cron-job by given the scheduler's name and one of the arguments

Valid arguments
(Required)
   -e | --enable    {Enable a cron-job}
   -d | --disable   {Disable a cron-job}
   -s | --scheduler {Scheduler name (parent directory)}
   -p | --pattern   {One pattern that corresponds to one of the argument}

(Optional)
   -h | --help {this message}
"

ENABLE=false
DISABLE=false
SCHEDULER=''
PATTERN=''

# Iterate through each given argument
while true; do
   case "$1" in
        -e | --enable     ) ENABLE=true;                  shift ;;
        -d | --disable    ) DISABLE=true;                 shift ;;
        -s | --scheduler  ) SCHEDULER="$2";               shift 2 ;;
        -p | --pattern    ) PATTERN="$2";                 shift 2 ;;
        -h | --help       ) echo -e "$USAGE";             exit 0 ;;
        - | -- | -* | --* ) echo "Invalid argument '$1'"; shift;     echo -e "$USAGE"; exit 1 ;;
        *                 ) break;;
   esac
done


# --------------------------------------------------------------------------------------------------
# Check
# --------------------------------------------------------------------------------------------------
#
# Check if required arguments were given
if [[ "${ENABLE}" != 'true' && "${DISABLE}" != 'true' ]]; then
    log_error "Please give enable or disable flag!"
    exit 1
fi
if [[ -z "${SCHEDULER}" || -z "${PATTERN}" ]]; then
    log_error "Please give both scheduler and pattern!"
    exit 1
fi


# --------------------------------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------------------------------
#
# Search for project homes that matches given scheduler pattern
PROJECT_DIRECTORY=$(eval echo $(printf '${%s} ' $(env                  |
                                                  grep -E "CRON_[0-9]" |
                                                  grep "${SCHEDULER}"  |
                                                  cut -d'=' -f1)))
if [[ -z "${PROJECT_DIRECTORY}" ]]; then
    log_error "Project's directory not found!"
    exit 1
fi
PROJECT_DIRECTORY=${PROJECT_HOME}/${PROJECT_DIRECTORY}
if [[ ! -d "${PROJECT_DIRECTORY}" ]]; then
    log_error "Project's directory does not exist!"
    exit 1
fi

# Check if enable is true and then disable. Both could be given but only one must be true
if [[ "${ENABLE}" == 'true' ]]; then
    log_info "Enable execution for '${PATTERN}' for '${SCHEDULER}'"
    rm "${PROJECT_DIRECTORY}/${PATTERN}.lock" 2> /dev/null
elif [[ "${DISABLE}" == 'true' ]]; then
    log_info "Disable execution for '${PATTERN}' for '${SCHEDULER}'"
    touch "${PROJECT_DIRECTORY}/${PATTERN}.lock"
fi

exit 0
