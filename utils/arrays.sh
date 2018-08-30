#!/bin/bash

function contains {
	local item=$1
	shift
	local result=1
	for i in "$@"; do 
		if [ "$i" == "$item" ]; then
			result=0
			break
		fi
	done
	return $result
}
