

function allHosts {
	local concern=''
	local filterOnly=false

	while [ "$#" -ne 0 ]; do
		case $1 in
		-f) filterOnly=true; shift;;
		-c) concern=$2; shift; shift;;
		*) echo "unknown parameter $1"; exit 1;;
		esac
	done

	local filter='.machineTypes|.[]|.hosts|select(.!=null)|.[]'
	if [ ! -z $concern ]; then
		filter+='|select(.concerns)|select(.concerns|.[]|contains("'$concern'"))'
	fi
	if ! $filterOnly; then
		filter+='|.name'
	fi

	if $filterOnly; then
		echo $filter
	else
		jq -cr "$filter" <<< $CONFIG | xargs echo
	fi
}

