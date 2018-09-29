#!/bin/bash

#	Note this script is very beta

#	Call this at the begininning of your single-page application to save off
#	the current screen and clear it
function saveScreen {

	if ! $debug; then
		tput smcup
		clear
	fi

}

#	Call this as you exit the single-page application to restore the contents
#	of the screen as it was before you started the app
function restoreScreen {

	# restore screen
	if ! $debug; then
		tput rmcup
	fi

}

#	Sets the phases of the app, for display by `showPhase`
function setPhases {
	__phases=${1[@]}
}
__phases=('phase 1' 'phase 2')

#	Display a header at the top of the screen that shows a set of phases and 
#	highlights the current one
function showPhase {

	tput sc
	activePhase=$1

	# calculate columns per phase
	# we'll treat each phase as a chiclet with two spaces on the left
	# and one on the right -- so its ideal width is 3+(title length)

	# maxTitleWidth is the maximum width of the phase description text
	maxTitleWidth=0
    firstTitle=${__phases[1]}
    minTitleWidth=${#firstTitle}
  	# idealCols is the width if all __phases are accomodated to their exact
	# plus two cols on the left, one on the right, and three between each
	idealCols=0
	numCols=$(tput cols)

	i=0
	while (($i < ${#__phases[@]})); do
		phaseName=${__phases[$i]}
		len=${#phaseName}

		if (( $len > $maxTitleWidth )); then
			maxTitleWidth=$len
		fi
		if (( $len < $minTitleWidth )); then
			minTitleWidth=$len
		fi
		((idealCols += 3 + $len))
		((i++))
	done

	actualCols=$idealCols
	if (($idealCols > $numCols)); then
		# we'll have to shrink some headers. 
		phaseTest=0
		# reduce the maximum title width by one
		((maxTitleWidth--))
		while (($actualCols > $numCols)); do
			# each iteration of the while loop tests a single title
			if (($phaseTest >= ${#__phases[@]})); then
				# if we've tested all the titles against the current max,
				# reduce the max by one and try again
				((maxTitleWidth--))
				phaseTest=0
			fi
			# is the phase's title too long?
		    phaseTestText=${__phases[$phaseTest]}
			len=${#phaseTestText}
			if (($len > $maxTitleWidth)); then
				# reduce the phase's title length by one (or two if it would 
				# end in a space) then recaculate the actual columns
				__phases[$phaseTest]=$(sed -E -e 's/ ?.$//' <<< ${__phases[$phaseTest]})
				actualCols=0
				for i in ${__phases[@]}; do 
					((actualCols += 3+ ${#i})); 
				done
				sleep 2
			fi
			((phaseTest++))
		done

	elif (($idealCols < $numCols)); then
		# we'll have to expand some headers
		phaseTest=0
		# reduce the maximum title width by one
		((minTitleWidth++))
		while (($actualCols < $numCols)); do

			# each iteration of the while loop tests a single title
			if (($phaseTest >= ${#__phases[@]})); then
				# if we've tested all the titles against the current max,
				# reduce the max by one and try again
				((minTitleWidth++))
				phaseTest=0
			fi
			# is the phase's title too short?
	    	phaseTestText=${__phases[$phaseTest]}
			len=${#phaseTestText}
			if (($len < $minTitleWidth)); then
				# pad the phase's title length by one space then recaculate the actual columns
				__phases[$phaseTest]=${__phases[$phaseTest]}$'\xc2\xa0'
				actualCols=0
				for i in ${__phases[@]}; do 
					((actualCols += 3 + ${#i}))
				done
			fi
			((phaseTest++))
		done

	else
		# we got lucky
		true

	fi

	phase=0
	tput cup 0 0
	col=0
	while (($phase <= ${#__phases})); do
		phaseText=${__phases[$phase]}
		if [ $phase -eq $activePhase ]; then
			# echo in bright colours
			echo $'\x1b[102m \x1b[46;30;1m '${phaseText}$' \x1b[0m'
		else
			# echo in subdued colous
			echo '  '$phaseText' '
		fi
		len=${#phaseText}
		((col += 3 + $len))
		tput cup 0 $col
		((phase++))
	done

	tput rc

}

