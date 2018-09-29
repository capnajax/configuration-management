#!/bin/bash

#
#	Test for a dependency on jq, and if necessary, load it
#

if [[ `uname` = 'Darwin' ]]; then 
	JQ_DOWNLOAD_URI=https://github.com/stedolan/jq/releases/download/jq-1.5/jq-osx-amd64
else 
	JQ_DOWNLOAD_URI=https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
fi

function checkJqPrerequisite {

	which jq >/dev/null
	if [[ $? -eq 0 ]]; then

		return 0

	else

		if [[ ! -e ./jq ]]; then

			h1 "Fetching jq"

			curl -kL $JQ_DOWNLOAD_URI -o jq
			chmod a+x jq

		fi

		mv jq /usr/local/bin/jq
		if [[ $? -eq 0 ]]; then

			echo "jq installed"
			return 0

		else 

			echo "Unable to move jq into /usr/local/bin. Will use copy in local directory."
			echo "Not a problem, but it leaves the program in the project folder. To move it:"
			echo "  sudo mv jq /usr/local/bin "

			return -1

		fi

	fi

}

function needsQuoting {
	local value=$1
	local numberRe='^-?[0-9]+([.][0-9]+)?$'
	local v1=$(head -c 1 <<< $value)
	if [[ $v1 == '"' || $v1 == '{' || $v1 == '[' || $value =~ $numberRe || $value == 'null' ]]; then
		# Quoted string, object, array, number, or null
		return 1
	else
		# Unquoted string
		return 0
	fi
}

##
#	Usage: buildJsonObj [ <var> ] [ <name> <value> ] [ <name> <value> ] [ ... ]
#
function buildJsonObj {


	# TODO change this to use jq to build the object so quoting issues are handled.


	local returnVar
	local jsonString=''

	if [ $(expr $# % 2) -eq 1 ]; then
		returnVar=$1
		shift
	fi

	while [ $# -ge 2 ]; do

		local name=$1
		local value=$2

		shift
		shift

		if needsQuoting $value; then
			jsonString+='"'$name'":"'$value'"'
		else
			jsonString+='"'$name'"':$value
		fi

		if [ $# -ge 2 ]; then
			jsonString+=','
		fi

	done

	if [ ! -z $returnVar ]; then
		eval "${returnVar}='{${jsonString}}'"
	else
		echo "{${jsonString}}"
	fi
}

##
#	Usage:
#		jsonObjectPair <key> <type> <value>
#	Value may contain spaces
function jsonObjectPair {
	local key=$1
	local valueType=$2
	local value
	shift; shift

	case ${valueType} in
		null) 	value="null" ;;
		string) quoteJsonString value $@ ;;
		*) 		value="$@" ;;
	esac

	echo "{\"${key}\":${value}}"
}

##
#	Usage:
#		quoteJsonString (<var>|-p) string
#
#	Convert a list of parameters into a JSON array of strings.
function quoteJsonString {
	local returnVar=$1
	shift

	local c="$@" result

	result=$(jq -c -n '$c' --arg c "$c")

	if [ "${returnVar}" == "-p" ]; then
		echo $result
	else
		eval "${returnVar}='${result}'"
	fi
}

##
#	Usage:
#		buildJsonStringArray (<var>|-p) [<elem1> [<elem2> [ ... <elemN>]]]
#
#	Convert a list of parameters into a JSON array of strings.
function buildJsonStringArray {

	local returnVar=$1
	shift

	local IFS='' result i

	#	This one-liner is the kernel of the method. Iterate through the 
	#	parameters, quote each as a JSON string, then combine them into an 
	#array.
	result="$(for i in $@; do jq '$c' --arg c "$i" -n; done | jq -c --slurp '.')"

	if [ "${returnVar}" == "-p" ]; then
		echo $result
	else
		eval "${returnVar}='${result}'"
	fi
}


##
# Usage: readJsonArray <var> <JSON_string>
# Read a JSON array into a shell array. the array is not validated.
##
function readJsonArray {

	local varName=$1
	local jsonString=$2

	eval "${varName}=()"
	for (( i=0 ; i<$(jq length<<<$jsonString || 0) ; i++ )); do
		#
		#	WARNING: currently only works with arrays of Strings and Numbers, not Arrays or Objects
		#	FIXME -- arrays of objects seems to work but it causes error messages
		#

		local eltype=$(jq -r '.['$i']|type' <<<$jsonString)
#debug		echo \$i == $i, \$eltype == $eltype
		case "$eltype" in
			object)
				eval "${varName}+=( '$(jq -c '.['$i']'<<<$jsonString)' )" 
#debug				echo $varName=$(eval echo '${'$varName'[@]}')
				;;
			string)
				eval "${varName}+=( \"$(jq -r -c '.['$i']'<<<$jsonString) \" )" 
#debug				echo $varName=$(eval echo '$'$varName)
				;;
			*)
				echo "readJsonArray for arrays of $eltype not implemented yet"
				false
				;;
		esac

	done
}
