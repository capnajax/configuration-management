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



if [ $errors != 0 ]; then
	end 1 "BUILD FAILED, $errors VALIDATION ERRORS"
fi

