#!/bin/bash

#
#	Global validations go here. These are scripts that can run quickly to 
#	sanity check your configuration.
#

h1 "Validating configuration"

h2 "Valid Yaml"

# DEBUG_VALIDATE=true

if [ -z "$DEBUG_VALIDATE" ]; then
	DEBUG_VALIDATE=false
fi

errors=0

if [ -z "$CONFIG" ]; then
	fatal "configs.yaml is not parseable. Cannot continue."
	exit 1
fi

h2 "Unique names"
namesFound=()
function uniqueNames {
	local filter=$1
	$DEBUG_VALIDATE && comment $filter
	$DEBUG_VALIDATE && comment $(jq -r "$filter" <<< $CONFIG)
	for name in $(jq -r "$filter" <<< $CONFIG); do

		# test if name exists already
		if contains $name ${namesFound[@]}; then
			error "Duplicate name: $i"
			(( errors ++ ))
		fi
		namesFound+=($name)

	done
}

uniqueNames '.machineTypes|.[]|select(.!=null)|.hosts|.[]|.name'
$DEBUG_VALIDATE && comment "${namesFound[@]}"

h2 "Validate all tools packages are known"
function validateTools {
	local allTools=($(jq -r '.machineTypes|.[]|select(.!=null)|.hosts|.[]|select(.tools).tools|unique|sort|.[]' <<< $CONFIG))
	local knownTools=($(jq -r '.services.tools.installOrder|.[]' <<< $CONFIG))
	for tool in ${allTools[@]}; do
		if ! contains $tool ${knownTools[@]}; then
			error "$tool not known"
			(( errors ++ ))
		fi
	done
}
validateTools

#
#	Add your own validations here. 
#	h2 "<Validation type>"					# output a headline to the console
#	function myValidation {					# keep the validations in functions
#											# so, if you need to, you can
#											# encapsulate local variables
#		if <something_bad>; then
#			error "<something bad text>"	# output error text
#			(( errors ++ ))					# increment error count
#		fi
# 	}
#	myValidation							# call your validation function
#
#
# example:
h2 "Validate something is true"
function isTruthy {
	if [ true == false ]; then
		error "Truth is not truth"
		(( errors ++ ))
	fi
}
isTruthy


if [ $errors != 0 ]; then
	end 1 "BUILD FAILED, $errors VALIDATION ERRORS"
fi

