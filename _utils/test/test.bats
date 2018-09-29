#!/bin/bash

DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
source ${UTIL}/utils.sh friendlyIO arrays strings 

function t_strings {

	h1 "Testing strings library"

	h2 "ansifold"

	#
	#	Visual tests are in the visualTests.sh script -- this only detects 
	# 	if the exit status code is 0
	#

	echo $'\x1b[31;1mThe quick brown fox jumps over the lazy dog\x1b[0m The quick brown fox jumps\x1b[31;1m: over the lazy\x1b[0m [ \x1b[31mdog\x1b[0m ]' | ansifold

}

function t_arrays {

	h1 "Testing arrays library"

	local ar

	h2 "Contains"

	trace "1 is in 1 2 3"
	contains 1 1 2 3
	trace "3 is in 1 2 3"
	contains 3 1 2 3
	trace "0 is not in 1 2 3"
	! contains 0 1 2 3
	trace "4 is not in 1 2 3"
	! contains 4 1 2 3

	h2 "Pop"
	trace "Start with 1 2 3 4 5"
	ar=(1 2 3 4 5)
	local popped=6
	trace "$popped -- ${ar[@]}"
	pop ar popped
	[ "$popped" == "5" ]
	[ ${#ar[@]} == 4 ]
	trace "$popped -- ${ar[@]}"
	pop ar popped
	[ "$popped" == "4" ]
	trace "$popped -- ${ar[@]}"
	pop ar popped
	[ "$popped" == "3" ]
	trace "$popped -- ${ar[@]}"
	pop ar popped
	[ "$popped" == "2" ]
	trace "$popped -- ${ar[@]}"
	pop ar popped
	[ "$popped" == "1" ]
	[ -z "${ar[@]}" ]
	! pop ar popped
	[ -z "$popped" ]
	[ -z "${ar[@]}" ]
	local newAr=(11 22)
	pop newAr popped
	[ "$popped" == "22" ]

	h2 "join"
	ar=(1 2 3 4 5)
	echo "$(join , ${ar[@]})"
	[ "$(join , ${ar[@]})" == "1,2,3,4,5" ]
	[ "$(join , 1 2 3 4 5)" == "1,2,3,4,5" ]
	[ -z "$(join ,)" ]
	[ $(join , 1) == "1" ]

}


#
#	this is for running individual tests
#
if [ ! -z $1 ]; then

	errors=0

	for i in $@; do
		t_${i}
		(( errors += $? ))
	done
	exit $errors

fi

@test "strings" {
	t_strings
}

@test "arrays" {
	t_arrays
}
