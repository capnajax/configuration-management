#!/bin/bash

DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
source ${DIR}/common/global.sh

configsRun=()
dependencies=() # maps command in base64 to array of dependencies in base64
queue=()

#
#	Run this as "./configure.sh <config_type> "
#

#
#	To add tasks:
#	1.  Add a case for the task name to `addTask` function. This case should
#		add dependent tasks first, then enqueue the task you want to run.
#		Full task command lines, including parameters are enqueued. If a task
#		is queued twice (same command and parameters), it will only run once.
#	2.	Add a case to the `taskRun` function. This case is the entry point to
#		your actual script.	
#

function enqueue {

	local outVar
	if [ $1 == -o ]; then
		outVar=$2
		shift
		shift
	fi
	local result=$(base64 <<< "$@")
	if [ ! -z $outVar ]; then
		eval "$outVar=$result"
	fi
	queue+=($result)
}

errors=0

function addTask {

	local cmd=$1
	shift

	if [ ${#queue[@]} -gt 50 ]; then
		trace "long queue: ${queue[@]}"
		error "Task queue too long. Circular dependency?"
		end 1 "CONFIGURATION FAILED"
	fi

	if [ -z "$cmd" ]; then

		h1 "Running configs"
		echo
		info "No configuration selected."

	else

		case $cmd in

		a1)
			addTask a2 $@
			addTask a3 $@
			enqueue $cmd $@
			;;

		a2)
			addTask a3 $@
			enqueue $cmd $@
			;;

		a3)
			enqueue $cmd $@
			;;

		datapower)
			addTask software build
			addTask software $@
			enqueue $cmd $@
			;;

		software)
			enqueue $cmd $@
			;;

		#
		#	Add configs here
		#

		*)
			error "Unknown configuration $1"
			;;

		esac

	fi
}
addTask $@

#
#	add dependencies to all tasks
#

function runTask {

	local taskb64=$1

	# don't run a task that's already been run
	if contains "$taskb64" ${configsRun[@]}; then return 0; fi

	configsRun+=($taskb64)

}
for i in "${queue[@]}"; do
	runTask $i
done

#
# actual task run
#
function taskRun {

	local cmd=$1
	shift
	h0 "Running config of $cmd on $@"

	case $cmd in
	a1)
		echo "a1 $@ depends on a's 2 and 3"
		;;

	a2)
		echo "a2 $@ depends on a3"
		;;

	a3)
		echo "a3 $@ depends on nothing"
		;;

	datapower)
		source services/datapower/datapower.sh $@
		;;

	software)
		source services/software/software.sh $@
		;;

	esac
}
for task in ${configsRun[@]}; do
	taskRun $(debase64 <<< $task)
done

if [ $errors != 0 ]; then
	end 1 "ERRORS IN CONFIGURATION"
else
	end 0 "CONFIGURATION SUCCESSFUL"
fi

