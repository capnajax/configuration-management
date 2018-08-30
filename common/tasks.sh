#!/bin/bash


_tasks_configsRun=()
_tasks_queue=()

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
	_tasks_queue+=($result)
}

addTask $@

#
#	add dependencies to all tasks
#

function filterTasks {

	local taskb64=$1

	# don't run a task that's already been run
	if contains "$taskb64" ${_tasks_configsRun[@]}; then return 0; fi

	_tasks_configsRun+=($taskb64)

}
for i in "${_tasks_queue[@]}"; do
	filterTasks $i
done

for task in ${_tasks_configsRun[@]}; do
	runTask $(debase64 <<< $task)
done

if [ $errors != 0 ]; then
	end 1 "ERRORS IN CONFIGURATION"
else
	end 0 "CONFIGURATION SUCCESSFUL"
fi
