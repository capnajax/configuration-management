#!/bin/bash

DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
source ${DIR}/common/global.sh

#
#	Run this as "./configure.sh [<config_type> [<params]] "
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

function addTask {

	local cmd=$1
	shift

	if [ ${#_tasks_queue[@]} -gt 50 ]; then
		trace "long queue: ${_tasks_queue[@]}"
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

#
# actual task run
#
function runTask {

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

# Run the whole config
source ${COMMON_DIR}/tasks.sh

