#!/bin/bash

#
#	This is the entry point for all global configurations and validations.
#	Each service script will include this file first.
#

# load config
COMMON_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

source ${COMMON_DIR}/../utils/utils.sh friendlyIO arrays strings

# platform differences

# some parameters are different between BSD and Linux
IS_LINUX=$([ $(uname -s) == "Linux" ] && echo true || echo false)
if [ $IS_LINUX ]; then
	debase64impl="base64 -D"
else
	debase64impl="base64 -d"
fi

#
# global functions
#
function debase64 {
	$debase64impl $@
}

