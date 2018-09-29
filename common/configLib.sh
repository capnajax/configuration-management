#!/bin/bash

##
#	hosts [-type [<machineType1> ...]] [-concern [<concern1> ...]] 	
#
function hosts {
	local originalParameters=($@)
	local hostsFilter='.machineTypes|.[]|.hosts|select(.!=null)|.[]'
	local names=()
	local types=()
	local concerns=()
	local nextParamType=''

	while [ $# -gt 0 ]; do

		if [[ $1 =~ ^- ]]; then
			nextParamType=$1
		else
			case $nextParamType in
				-concerns) concerns+=('.concerns|index(["'$1'"])') ;;
				-names) names+=('.name=="'$1'"') ;;
				-type)	types+=($1) ;;
				*)	error "hosts invalid parameter set ${originalParameters[@]}"
					exit 1 ;;
			esac
		fi
		shift
	done

	hostsFilter='.machineTypes'

	if [ ${#types[@]} -gt 0 ]; then
		hostsFilter+="$(join , ${types[@]})"
	else
		hostsFilter+='|.[]'
	fi

	hostsFilter+='|.hosts|select(.!=null)|.[]'

	if [ ${#names[@]} -gt 0 ]; then
		hostsFilter+="|select($(join , ${names[@]}))"
	fi

	if [ ${#concerns[@]} -gt 0 ]; then
		hostsFilter+="|select(.concerns)|select(.!=null)|select($(join , ${concerns[@]}))"
	fi

	jq -cr "$hostsFilter|.name" <<< $CONFIG
}

