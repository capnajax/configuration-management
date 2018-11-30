#!/bin/bash

# validations that need to be run before starting any configurations
_tasks_validations_queue='[]'
# services modules already loaded, so they don't get loaded twice
_tasks_services_loaded=()
# maps services to their task function
_tasks_task_map='{}'
# maps dependencies to their task function
_tasks_dependency_map='{}'

_tasks_configsRun=()
_tasks_queue=()

argv=$@

errors=0

function enqueue {

	local outVar
	if [ "$1" == -o ]; then
		outVar=$2
		shift
		shift
	fi
	local result=$(base64 <<< "$@")
	if [ ! -z "$outVar" ]; then
		eval "$outVar=$result"
	fi
	_tasks_queue+=($result)
}

#
#	add dependencies to all tasks
#

function filterTasks {

	local taskb64=$1

	# don't run a task that's already been run
	if contains "$taskb64" ${_tasks_configsRun[@]}; then return 0; fi

	_tasks_configsRun+=($taskb64)

}

#
#	Register a task
#
function register {

	local module=$loadingModule
	local registrationType=$1
	local p2=$2
	shift
	if [ -z "${module}" ]; then
		module=$1
		shift
	fi

	case $registrationType in

	dependency)
		local existingDependency=$(jq '.'${module}' and true or false' <<< $_tasks_dependency_map)
		if $existingDependency; then
			error "Dependency for module \"$module\" registered twice. Cannot continue."
			end 1 "CONFIGURATION FAILED"
		fi
		_tasks_dependency_map=$(jq '. + {"'${module}'":$v}' --arg v $1 <<< $_tasks_dependency_map)
		;;

	task)
		local existingTask=$(jq '.'${module}' and true or false' <<< $_tasks_task_map)
		if $existingTask; then
			error "Task for module \"$module\" registered twice. Cannot continue."
			end 1 "CONFIGURATION FAILED"
		fi
		_tasks_task_map=$(jq '. + {"'${module}'":$v}' --arg v $1 <<< $_tasks_task_map)
		;;

	validation)
		# a module can have any number of validations
		_tasks_validations_queue=$(jq '. + [{"module":$m,"function":$f,"heading":$h}]' \
				--arg m $module \
				--arg f "$1" \
				--arg h "$2" \
				<<< $_tasks_validations_queue)
		;;
	*)
		error "unknown registrationType \"$registrationType\""
		;;
	esac
}

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

		# only load the service if it isn't already loaded
		if ! contains $cmd ${_tasks_services_loaded[@]}; then

			local sourceCmd=''
			local possibleFiles=( \
					"${DIR}/services/$cmd.sh" \
					"${DIR}/services/$cmd" \
					"${DIR}/services/$cmd/$cmd.sh" \
					"${DIR}/services/$cmd/$cmd" \
				)
			for possibility in "${possibleFiles[@]}"; do
				if [ -e $possibility ] && [ ! -d $possibility ]; then
					sourceCmd=$possibility
					break;
				fi
			done

			if [ -z "$sourceCmd" ]; then
				error "Cannot find module for config type \"$cmd\". Cannot continue."						
				end 1 "CONFIGURATION FAILED"
			else
				loadingModule=$cmd
				if source $sourceCmd; then
					_tasks_services_loaded+=($cmd)
				else
					error "Failed to load module for config type \"$cmd\". Cannot continue."		
					end 1 "CONFIGURATION FAILED"
				fi
				loadingModule=''
			fi
		fi

		dependency_func=$(jq -cr '.[$m]' --arg m $cmd <<< $_tasks_dependency_map)
		if [ ! -z "$dependency_func" ]; then
			$dependency_func $(jq -cr '.[$m]' --arg m $cmd <<< $_tasks_task_map) $@
		else
			enqueue $cmd $@
		fi

	fi
}

source ${COMMON_DIR}/configLib.sh

CONFIG=$(yaml2json ${CONFIG_FILE})

for common in ${DIR}/common/*.sh; do
	source $common
done

# validations
validationScripts=(${DIR}/validations/*.sh)
if [ "$VALIDATE" != "false" ] && [ -e ${validationScripts}  ]; then
	for validationScript in ${validationScripts[@]}; do
		if [ "$validationScript" != "README.md" ]; then
			loadingModule=$(basename "$validationScript" | sed -e 's/.sh$//')
			source "$validationScript"
			loadingModule=''
		fi
	done
fi

addTask $@

for i in "${_tasks_queue[@]}"; do
	filterTasks $i
done

h1 "Running Validations"
validationSpec=''
function runValidations {
	local validationNum
	for (( validationNum=0; validationNum < $(jq length <<< $_tasks_validations_queue); validationNum++ )); do
		validationSpec=$(jq '.[$v|tonumber]' --arg v $validationNum <<< $_tasks_validations_queue)
		h1 "Validating for $(jq -cr .module <<< $validationSpec): $(jq -c .heading <<< $validationSpec)"
		jq -cr .function <<< $validationSpec
		if ! $(jq -cr .function <<< $validationSpec); then
			(( errors++ ))
		fi
	done
}
runValidations

if [ "$errors" != 0 ]; then
	end 1 "ERRORS IN VALIDATION"
fi

for task in ${_tasks_configsRun[@]}; do
	taskCmdLine="$(debase64 <<< $task)"
	taskCmd=$(sed -e 's/ .*//' <<< $taskCmdLine)
	taskCmd=$(jq -cr 'to_entries[]|select(.value==$v)|.key' --arg v $taskCmd <<< $_tasks_task_map)
	taskParameters=$(sed -e 's/[^ ]*//' <<< $taskCmdLine)
	h1 "Running $taskCmd on $taskParameters"
	$taskCmdLine
done

if [ "$errors" != 0 ]; then
	end 1 "ERRORS IN CONFIGURATION"
else
	end 0 "CONFIGURATION SUCCESSFUL"
fi

