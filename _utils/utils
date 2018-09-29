#!/bin/bash

#
#	Some common functions and useful vars
#

#
#	Use this script to load the other scripts in this collection
#	Example: source ./utils.sh friendlyIO jq sessions
#

function getShUtilsVersion {
	echo 'v2.0.0b'
}

#
#	Load additional utilities
#

__utilsPath="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

for i in $@ ; do
	if [ -e ${__utilsPath}/${i}.sh ]; then
		source ${__utilsPath}/${i}.sh
	fi
done

