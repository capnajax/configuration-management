# Configuration Management

This is a simple scripting framework for managing configurations of several
installs on several machines, everything managed by a single configuration
file and the script is run from a single machine.

## Usage

The machine running this script must have the following installed:
* `jq` version 1.5+, available here https://stedolan.github.io/jq/download/, or as an Ubuntu 16.04 package (`sudo apt-get install jq`)
* A recent version of `node` and `npm`
* `yaml2json`; This can be installed with `npm install -g yamljs`

Add this package a folder (for example `_utils/cm`), set two variables `DIR` and `CONFIG`, and then source the `configure.sh` file

	DIR=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)
	CONFIG_FILE=${DIR}/config.yaml

	source _utils/cm/configure.sh $@

Then you can call your package with

	<my_config_script>.sh <config-type> [<parameters ...>]

## Folder Structure

In this convention over configuration model, place scripts in the following folders:

* `common` - Scripts in this folder are run first. Use this to create functions any validation or configuration can use.
* `validations` - Scripts in this folder are global validations run before any configuration is run. Ideally these validations should be general in nature and finish quickly.
* `services` - This contains the configurations themselves.

## Global Validations

The `validate` folder has all the global validations. This is run before any configuration script. Ideally validations here should run quickly, cover things of global importance, and not write details to console unless either (a.) `$DEBUG_VALIDATE` is set to `true` or (b.) there's an error. To add a validation, add a new method to this script.

When your validation detects an error, it should do two things:
1. Log that there's an error `error "error text"`
1. Increment the errors count `(( errors ++ ))`

If any errors are detected, the config will end in failure after the validations are complete, but before any configurations are attempted.

## Services

Each service in the services folder should have its entry point in a script with one of the following names, where `$cmd` is the name of the service (in order of priority):
* `services/$cmd.sh`
* `services/$cmd`
* `services/$cmd/$cmd.sh`
* `services/$cmd/$cmd`

Each service config script has three kinds of functions:
* Dependency
* Validation
* Task

### Dependency

A dependency script runs first; its purpose is to load dependencies and put the enqueue the task. In this function you would call the following:

	addTask <service_name> [<parameters>]

`addTask` ensures another service is configured prior to adding this service. That service's dependencies will be checked as well. If a dependency is added twice (same service and parameter set), it'll only configure once.

	enqueue <service_name> [<parameters>]

`enqueue` adds this service's configuration task to the queue.

To register this dependency function, use this command:

	register dependency <dependency_func>

Remember your dependency function lives in a global namespace, so ensure that its name is unique.

### Validations

A validation script runs before all configuration tasks, but only for the configs that need to be run. A service can have multiple validation tasks. Validations run only once, even if a task needs to run multiple times. It is not sensitive to task parameters.

To register a validation, create your validation function and then register it with:

	register validation <validation_func> "<description>"

Remember your validation function lives in a global namespace, so ensure that its name is unique. A service may have multiple validation tasks, they all will be run if a service needs to be configured.

### Task

This is the actual service configuration task; each service must have exactly one.

To register a service configuration task, create your task function and register it with:

	register task <task_func>



