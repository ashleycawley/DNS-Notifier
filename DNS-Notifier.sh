#!/bin/bash

# Server's old IP Address
OLD_SERVER_IP="176.74.17.250"

SAVEIFS=$IFS	# Backing up the delimiter used by arrays to differentiate between different data in the array (prior to changing it)
	
IFS=$'\n'	# Changing the delimiter used by arrays from a space to a new line, this allows a list of users (on new lines) to be stored in to an array

find /var/named/ -maxdepth 1 -type f | sort | sed s,/var/named/,,g | sed s/.db//g > domain-list.txt

for DOMAIN in $(cat domain-list.txt)
do
	sleep 0.5	
	# A Dig Test	
	dig +short $DOMAIN A @194.110.243.230 | grep "$OLD_SERVER_IP" &>/dev/null
	if [ $? -eq 0 ]
	then
		ARESULT=0
	else
		ARESULT=1
	fi

	# WWW Dig Test
        dig +short www.$DOMAIN A @194.110.243.230 | grep "$OLD_SERVER_IP" &>/dev/null
        if [ $? -eq 0 ]
        then
                WWWRESULT=0
        else
                WWWRESULT=1
        fi

	# MAIL Dig Test
        dig +short mail.$DOMAIN A @194.110.243.230 | grep "$OLD_SERVER_IP" &>/dev/null
        if [ $? -eq 0 ]
        then
                MAILRESULT=0
        else
                MAILRESULT=1
        fi


	if [ $ARESULT == 0 ] || [ $WWWRESULT == 0 ] || [ $MAILRESULT == 0 ]
	then
		USERNAME=(`grep -ri "$DOMAIN" /var/cpanel/userdata/ | grep "main_domain: \|parked_domains\|addon_domains" | head -n 1 | cut -d '/' -f 5`)
		OWNER=(`grep -ri "owner: " /var/cpanel/userdata/$USERNAME/ | grep -v SSL | awk ' { print $2 } '`)
		echo "$DOMAIN,$USERNAME,$OWNER"
	fi

done

IFS=$SAVEIFS # Resets $IFS this changes the delimiter that arrays use from new lines (\n) back to just spaces (which is what it normally is)
