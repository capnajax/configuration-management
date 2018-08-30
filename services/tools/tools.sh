#!/bin/bash


function installNvm {
	if ssh $1 '[ -e $HOME/.nvm/nvm.sh ]' ; then
		comment "nvm already installed at $(which nvm)"
	else
		ssh $host 'curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash'
	fi
}

function installNode {
	if which node >/dev/null; then
		comment "node $(node -v) already installed at $(which node)"
	else
		ssh $host '$HOME/.nvm/nvm.sh && nvm install --lts'
	fi
}

function installYaml2Json {
	if which yaml2json >/dev/null; then
		comment "yamljs $(yaml2json -v) already installed at $(which yaml2json)"
	else
		ssh $host '$HOME/.nvm/nvm.sh && npm install -g yaml2json'		
	fi
}

function installJq {
	if which jq >/dev/null; then
		comment "$(jq --version) already installed at $(which jq)"
	else
		# need to detect RHEL vs Ubuntu
		# sudo apt-get install -y jq
		warn "TODO jq install not yet automated"
	fi
}

function installTools {

	# load the order in which tools will be installed
	local toolsOrder=($(jq -r '.services.tools.installOrder|.[]' <<< $CONFIG))

	local tools
	local filter='.machineTypes|.[]|.hosts|select(.!=null)|.[]|select(.name==$host and .tools)|.tools|.[]'

	for host in $@; do

		h2 $host

		tools=($(jq -cr "${filter}" --arg host $host <<< $CONFIG))
		if [ ${#tools[@]} -eq 0 ]; then
			info "No tools needed on host"
			continue
		else
			info "Installing tools: ${tools[@]}"
		fi

		for tool in ${toolsOrder[@]}; do
			if contains $tool ${tools[@]}; then

				case $tool in

				jq) installJq $host
					;;

				node) 
					installNode $host
					;;

				nvm) 
					installNvm $host
					;;

				yaml2json) 
					installYaml2Json $host
					;;

				*) 	fatal "No package install available for tool \"$tool\". Cannot continue."
					end 1 "TOOLS INSTALL FAILED"
					;;
				esac

			fi
		done

	done

}
installTools $@

