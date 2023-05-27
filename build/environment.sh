#!/bin/bash

# environment.sh -----------------------------------------------------------------------------------
#
# Script Description:
#    This script searches for requirements.txt files based on a given directory and create a venv
#
# Required Arguments:
#    -d | --directory : Directory of the cron project
#
# Optional Arguments:
#    -h | --help  : Help message
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
This script searches for requirements.txt files based on a given directory and create a venv

Valid arguments
(Required)
   -d | --directory {Directory of the cron project}

(Optional)
   -h | --help {this message}
"

PROJECT_DIRECTORY=""

# Iterate through each given argument
while true; do
   case "$1" in
        -d | --directory  ) PROJECT_DIRECTORY="$2";         shift 2 ;;
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
if [[ -z "${PROJECT_DIRECTORY}" || ! -d "${PROJECT_DIRECTORY}" ]]; then
    log_error "Project's directory does not exist!"
    exit 1
fi


# --------------------------------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------------------------------
#
find "${PROJECT_DIRECTORY}" -type f -name "${REQUIREMENTS}" > temp$$
if (( $(cat temp$$ | wc -l) == 0 )); then
   log_error "No ${REQUIREMENTS} files found!"
   rm temp$$
   exit 1
fi
log_info "Found ($(cat temp$$ | wc -l)) ${REQUIREMENTS} files"

# Prepare Python Environment:
VIRTUAL_ENV="${PROJECT_DIRECTORY}/.venv"
log_info "Creating virtual environment '${VIRTUAL_ENV}' for '${PROJECT_DIRECTORY}'"
python -m venv $VIRTUAL_ENV

log_info "Append virtual environment to PATH"
export PATH="$VIRTUAL_ENV/bin:$PATH"
echo ${PATH} | tr ':' '\n' | while read path; do log_dev "${path}"; done

log_info "Activate $VIRTUAL_ENV"
source "${VIRTUAL_ENV}/bin/activate"
python -m pip install --upgrade pip
pip install wheel

# Install dependencies:
cat temp$$ | while read r; do
   pip install -r ${r}
done

# Create a wrapper script that executes the main python code, using the virtual environment
echo "#!/bin/bash"                         > ${PROJECT_DIRECTORY}/python
echo "# Move to project's directory"      >> ${PROJECT_DIRECTORY}/python
echo "cd ${PROJECT_DIRECTORY}"            >> ${PROJECT_DIRECTORY}/python
echo "# Check if execution is locked"     >> ${PROJECT_DIRECTORY}/python
echo "source /build/functions.sh"         >> ${PROJECT_DIRECTORY}/python
echo "exit_if_locked \$@"                 >> ${PROJECT_DIRECTORY}/python
echo "# Execure script using venv"        >> ${PROJECT_DIRECTORY}/python
echo "source ${VIRTUAL_ENV}/bin/activate" >> ${PROJECT_DIRECTORY}/python
echo "exec python \$@"                    >> ${PROJECT_DIRECTORY}/python

chmod 750 ${PROJECT_DIRECTORY}/python

rm temp$$

exit 0
