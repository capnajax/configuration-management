#!/bin/bash

#
#	A collection of functions to make the output of shell scripts more friendly.
#

##
#	Log levels are set by the scripts. The logLevel specified here is a 
#	default. Higher number means more logging.
#	0 - no logging
#	1 - fatal, error and h0
#	2 - warnings and h1, h2
#	3 - info
#	4 - comment
#	5 - trace (default)
#
if [ -z "$logLevel" ]; then logLevel=5; fi

##
#	Set to true if logging in colour
#
if [ -z "$logInColor" ]; then logInColor=true; fi

function warn { 
	if [ $logLevel -ge 1 ]; then
		if [ $logInColor == "true" ]; then
			(>&2 echo  $'\x1b[31;1mWARNING\x1b[0m\x1b[31;1m:\x1b[0m [ \x1b[31m'$@$'\x1b[0m ]')
		else
			(>&2 echo '[  WARNING****] '$@)
		fi		
	fi
}
function error { 
	if [ $logLevel -ge 1 ]; then
		if [ $logInColor == "true" ]; then
			(>&2 echo  $'\x1b[31;1;4mERROR\x1b[0m\x1b[31;1m:\x1b[0m [ \x1b[31m'$@$'\x1b[0m ]')
		else
			(>&2 echo '[ ERROR  *****] '$@)
		fi		
	fi
}
function fatal { 
	if [ $logLevel -ge 1 ]; then
		if [ $logInColor == "true" ]; then
			(>&2 echo  $'\x1b[31;1;4mFATAL\x1b[0m\x1b[31;1m:\x1b[0m [ \x1b[31m'$@$'\x1b[0m ]')
		else
			(>&2 echo '[FATAL  ******] '$@)
		fi		
	fi
}
##
#	Most scripts shouldn't need an h0 -- this is for scripts that run in their
#	entirety over a large set.
#
function h0 {
	if [ $logLevel -ge 1 ]; then
		if [ $logInColor == "true" ]; then
			(>&2 echo  $'\n\x1b[36;1;4m'$@$'\x1b[0m')
		else
			(>&2 echo '[   info  ****] '$@)
		fi		
	fi
}
function h1 { 
	if [ $logLevel -ge 2 ]; then
		if [ $logInColor == "true" ]; then
			(>&2 echo  $'\n\x1b[36;1;4m'$@$'\x1b[0m')
		else
			(>&2 echo '[   info   ***] '$@)
		fi		
	fi
}
function h2 { 
	if [ $logLevel -ge 2 ]; then
		if [ $logInColor == "true" ]; then
			(>&2 echo  $'\x1b[36m \xe2\x86\xb3 '$@$'\x1b[0m')
		else
			(>&2 echo '[   info    **] '$@)
		fi		
	fi
}
function info {
	if [ $logLevel -ge 3 ]; then
		if [ $logInColor == "true" ]; then
			(>&2 echo  $' \x1b[104;93m ℹ\x1b[0m \x1b[93m'$@$'\x1b[0m')
		else
			(>&2 echo '[   info     *] '$@)
		fi		
	fi
}
function strike {
	if [ $logLevel -ge 3 ]; then
		if [ $logInColor == "true" ]; then
			(>&2 echo  $'\t\x1b[2;32m'$@$'\x1b[0m')
		else
			(>&2 echo '[   struck---*] '$@)
		fi		
	fi
}
function comment {
	if [ $logLevel -ge 4 ]; then
		if [ $logInColor == "true" ]; then
			(>&2 echo  $'\t\x1b[90m'$@$'\x1b[0m')
		else
			(>&2 echo '[    comment  ] '$@)
		fi		
	fi
}
function trace {
	if [ $logLevel -ge 5 ]; then
		if [ $logInColor == "true" ]; then
			(>&2 echo  $'\t\x1b[90m'$@$'\x1b[0m')
		else
			(>&2 echo '[     trace  ] '$@)
		fi		
	fi
}


function getInput {

	varName=$1
	description=$2
	silent=$3

	if [ -z ${silent+x} ]; then 
		silent=-s
	fi

	if [ -z ${!varName+x} ]; then
		echo $description
		read $silent $varName
	fi

}

if [ -z "$__startTime" ]; then
	__startTime=$(date '+%s')
fi

function end {

	exitStatus=$1
	exitMessage=$2

	h1 "${exitMessage}, disableEnd=$disableEnd"

	if [ -z "${disableEnd}" ] || ! $disableEnd; then

		timeDifference=$(( $(date '+%s') - $__startTime ))
		timeString="Elapsed time:"
		if [ $timeDifference -gt 3600 ]; then
			hours=$(( $timeDifference / 3600 ))
			timeString="${timeString} ${hours}h"
		fi
		if [ $timeDifference -gt 60 ]; then
			minutes=$(( ($timeDifference % 3600) / 60 ))
			timeString="${timeString} ${minutes}m"
		fi
		timeString="${timeString} $(( $timeDifference % 60 ))s"

		info $timeString
		sleep 0.1 
		echo
		exit ${exitStatus}

	fi
}

