#!/bin/bash

function a3_dependencies {
	local cmd=$1
	shift
	enqueue $cmd $@
}
register dependency a3_dependencies

function a3_runTask {

	info "Running $@ : a3 $@ depends on nothing"

}
register task a3_runTask
