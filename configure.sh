#!/bin/bash

source $(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)/common/global.sh

#
#	Run this as "./configure.sh [<config_type> [<params]] "
#

echo running config

# Run the whole config
source ${COMMON_DIR}/tasks.sh $@


