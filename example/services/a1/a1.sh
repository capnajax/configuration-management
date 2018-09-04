#!/bin/bash

function a1_validations {
	true
}
register validation a1_validations "Necessary validations for a1"

function a1_dependencies {
	local cmd=$1
	shift
	addTask a2 $@
	addTask a3 $@
	enqueue $cmd $@
}
register dependency a1_dependencies

function a1_runTask {

	info "Running $@ : a1 $@ depends on a's 2 and 3"

}
register task a1_runTask
