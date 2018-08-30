#!/bin/bash

# Tools for getting info on user sessions and access to other machines

#
#	Kill the script if the user is not sudoed
#
function checkSudo {
	if [[ $USER != 'root' ]] || [[ -z "$SUDO_USER" ]]; then
		echo Sudo root from an API Connect admin user to run this
		exit 87
	fi
}

#
#	Kill the script if the user is sudoed or root
#
function checkNotSudo {
	if [[ $USER == 'root' ]]; then
		echo This script cannot run as root
		exit 87
	fi
}

function sshKeycheck {

	if [[ ! -e ~/.ssh/id_rsa.pub ]]; then
		echo "Generating id_rsa keys for this host"
		ssh-keygen -b 2048 -t rsa -P '' -f $HOME/.ssh/id_rsa
	fi

	#
	#	TODO this is dumb -- replace this with ssh-copy-id
	#

	ssh -q $1 -qo PasswordAuthentication=no true
	if [[ $? -ne 0 ]]; then
		echo "Exchanging ssh keys with $1"
		keyCmd='mkdir -p .ssh ; touch .ssh/authorized_keys ; chmod 700 .ssh ; chmod 640 .ssh/authorized_keys ; cat >> .ssh/authorized_keys'
		cat $HOME/.ssh/id_rsa.pub | ssh $1 "$keyCmd"
	fi

}

