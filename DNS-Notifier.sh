#!/bin/bash

# Backing up the delimiter used by arrays to differentiate between different data in the array (prior to changing it)
SAVEIFS=$IFS
	
# Changing the delimiter used by arrays from a space to a new line, this allows a list of users (on new lines) to be stored in to an array
IFS=$'\n'

find /var/named/ -maxdepth 1 -type f -name a* | sed s,/var/named/,,g | sed s/.db//g > domain-list.txt

for DOMAIN in $(cat domain-list.txt)
do
	dig +short $DOMAIN A | grep "176.74.17.190" &>/dev/null
	if [ `echo $?` == '0' ]
	then
		echo "$DOMAIN,176.74.17.190"
	fi

done

# Resets $IFS this changes the delimiter that arrays use from new lines (\n) back to just spaces (which is what it normally is)
IFS=$SAVEIFS
