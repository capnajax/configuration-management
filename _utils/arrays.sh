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

function pop {
	local arName=$1 
	local outVar=$2
	eval "_pop_ar=( \${"$arName"[@]} )"
	eval "$arName=(\"${_pop_ar[@]}\")"
	local arLen=${#_pop_ar[@]}
	if [ $arLen -gt 0 ]; then
		(( arLen -- ))
		if [ ! -z "$outVar" ]; then
			eval "$outVar=${_pop_ar[$arLen]}"
		fi
		unset _pop_ar[$arLen]
	else
		eval "$outVar=''"
		false
	fi
	eval "$arName=(${_pop_ar[@]})"
}

function join {
	local separator=$1
	local result=''
	shift
	if [ $# -gt 0 ]; then
		local result=$1
		shift
		while [ $# -gt 0 ]; do
			result+=",$1"
			shift
		done
	fi
	echo $result
}
