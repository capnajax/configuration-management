#!/bin/bash

function a2_dependencies {
	local cmd=$1
	shift
	addTask a3 $@
	addTask a3 1
	enqueue $cmd $@
}
register dependency a2_dependencies

function a2_runTask {

	info "Running $@ : a1 $@ depends on a3"

}
register task a2_runTask
