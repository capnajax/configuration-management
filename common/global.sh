#!/bin/bash

#
#	This is the entry point for all global configurations and validations.
#	Each service script will include this file first.
#

# load config
COMMON_DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)

source ${COMMON_DIR}/../utils/utils.sh friendlyIO arrays strings
CONFIG=$(yaml2json ${COMMON_DIR}/../config.yaml)

errors=0

# validations
if [ "$VALIDATE" != "false" ]; then
	source ${COMMON_DIR}/validate-config.sh
fi

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

function allHosts {
	local concern=''
	local filterOnly=false

	while [ "$#" -ne 0 ]; do
		case $1 in
		-f) filterOnly=true; shift;;
		-c) concern=$2; shift; shift;;
		*) echo "unknown parameter $1"; exit 1;;
		esac
	done

	local filter='.machineTypes|.[]|.hosts|select(.!=null)|.[]'
	if [ ! -z $concern ]; then
		filter+='|select(.concerns)|select(.concerns|.[]|contains("'$concern'"))'
	fi
	if ! $filterOnly; then
		filter+='|.name'
	fi

	if $filterOnly; then
		echo $filter
	else
		jq -cr "$filter" <<< $CONFIG | xargs echo
	fi
}

