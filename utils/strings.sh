#!/bin/bash

THIS_DIR=$(dirname ${BASH_SOURCE[0]})

#
#	Similar to the flow command, except it accounts for ANSI escape codes
#
function ansifold {
	while read line; do
		echo $line | node $THIS_DIR/strings/ansifold.js
	done
}
