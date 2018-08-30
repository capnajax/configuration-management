# Configuration Management

This is a simple scripting framework for managing configurations of several
installs on several machines, everything managed by a single configuration
file and the script is run from a single machine.

## Running

The machine running this script must have the following installed:
* `jq` version 1.5+, available here https://stedolan.github.io/jq/download/, or as an Ubuntu 16.04 package (`sudo apt-get install jq`)
* A recent version of `node` and `npm`
* `yaml2json`; This can be installed with `npm install -g yamljs`

The command line is pretty simple

	./configure.sh [<configType> [<params>]]

If `configType` is omitted, it will only run the validations and then stop. In general, the `<params>` in this command should be a list of host names to configure.

## Adding new features

The `configure.sh` module has two functions, `addTask` and `runTask`, and each has a `case` statement. Each valid `<configType>` is listed as cases in both.

The `addTask` simply adds the task and all its dependencies to the task queue. It's ok if a task gets added more than once; this script will not run the same task with the same parameters more than once.

The `runTask` method adds the tasks. Usually it just sources `./services/<configType>/<configType>.sh $@`.

The `./services/<configType>/<configType>.sh $@` scripts are up to the user to write. In general, they should do the following:
1. Accept a list of hostnames as parameters
1. Check if a config is already in place before overwriting it
1. Install the config, but only if necessary.

## Adding new validations

The `validate.sh` script has all the global validations. This is run before any configuration script. Ideally validations here should run quickly, cover things of global importants, and not write details to console unless either (a.) `$DEBUG_VALIDATE` is set to `true` or (b.) there's an error. To add a validation, add a new method to this script.

When your validation detects an error, it should do two things:
1. Log that there's an error `error "error text"`
1. Increment the errors count `(( errors ++ ))`

If any errors are detected, the config will end in failure after the validations are complete, but before any configurations are attempted.



