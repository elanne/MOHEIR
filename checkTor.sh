#!/bin/bash

usage() {
     	echo "Checks for TOR exit nodes in an list/csv of IP addresses."
        echo "Optionally removes found TOR nodes with 'remove' option"
       	echo "Example: $0 <list of IPs> [remove]"
	return
}

# check command line arguments
check_arguments() {
	if ! [ $# -eq 1 -o $# -eq 2 ]; then
		usage
	        exit 0

	elif [ $# -eq 2 ] && [ "$2" != "remove" ]; then
		echo "Second option is garbage ('remove' expected)"
		exit 0
	fi

	if ! [ -e $1 ]; then
		echo "File $1 does not exist!"
		exit 0
	fi
	return
} 

check_for_nodes() {
	# read ips from file and leave only unique IPs
	grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' $inputfile > $TEMPFILE2
	sort -u $TEMPFILE2 > $TEMPFILE

	#get Tor nodes list
	echo "Fetching list of TOR relays..."
	wget --quiet http://campaigns.ahmia.fi/finnish-tor-campaign/relays_fi.json -O $RELAYS

	echo "Checking IP list..."
	# check if found in Tor nodes list
	while read line; do 
		grep -q $line $RELAYS
		result=$?
		if [ "$result" == "0" ]; then
			echo "$line is a Tor exit node"
			echo "$line" >> $FOUNDEXITNODES
		fi
	done < $TEMPFILE
}

remove_nodes() {
	# remove if selected and if found
	if [ -e $FOUNDEXITNODES ]; then
		if [ "$2" == "remove" ]; then
			while read line; do
				grep -v $line $inputfile >> "$1.tmp"
				mv "$1.tmp" $inputfile
			done < $FOUNDEXITNODES
			echo "Exit nodes removed from $inputfile"
		fi
	fi
	return
}

cleanup() {
	# remove temporary files
	if [ -e $FOUNDEXITNODES ]; then
		rm $FOUNDEXITNODES
	fi
	rm $TEMPFILE $TEMPFILE1
	return
}


# check command line arguments
check_arguments "$@"

# assign variables
inputfile=$1
FOUNDEXITNODES="foundexitnodes.tmp"
RELAYS="relays_fi.json"
TEMPFILE="tmp.txt"
TEMPFILE2="tmp2.txt"

# check and print nodes
check_for_nodes

# if remove was selected, remove nodes from the list
remove_nodes "$@"

# clean up downloaded or created temporary files
cleanup

exit 0
