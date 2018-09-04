#!/bin/bash

v_namesFound=()
function v_uniqueNamesImpl {
	local filter=$1
	$DEBUG_VALIDATE && comment $filter
	$DEBUG_VALIDATE && comment $(jq -r "$filter" <<< $CONFIG)
	for name in $(jq -r "$filter" <<< $CONFIG); do

		# test if name exists already
		if contains $name ${v_namesFound[@]}; then
			error "Duplicate name: $i"
			(( errors ++ ))
		fi
		v_namesFound+=($name)

	done
}
function v_unqiueNames {
	v_uniqueNamesImpl '.machineTypes|.[]|select(.!=null)|.hosts|.[]|.name'
	$DEBUG_VALIDATE && comment "${namesFound[@]}"
}
register validation v_uniqueNames "Validate unique names"


function v_validateTools {
	local allTools=($(jq -r '.machineTypes|.[]|select(.!=null)|.hosts|.[]|select(.tools).tools|unique|sort|.[]' <<< $CONFIG))
	local knownTools=($(jq -r '.services.tools.installOrder|.[]' <<< $CONFIG))
	for tool in ${allTools[@]}; do
		if ! contains $tool ${knownTools[@]}; then
			error "$tool not known"
			(( errors ++ ))
		fi
	done
}
register validation v_validateTools "Validate all tools packages are known"

