#! /bin/bash

ACTUAL_VOLUME=""
NEW_VOLUME=""

if [[ -z "$1" || $(echo "$1" | egrep "^(-|\+)[0-9]$|^(-|\+)[0-9][0-9]$") ]]; then
    PROPER_INDEX=""
    i=0

    for line in $(pacmd list-sinks); do 
        if [ ! -z "$PROPER_INDEX" ]; then 
	    if [[ "$line" == "1" ]]; then
	        PROPER_INDEX=1;
	    fi
	    if [[ "$PROPER_INDEX" == "1" ]]; then
	        if [[ $(echo "$line" | grep "volume.") && -z "$VOLUMEFOUND" ]]; then  
	            VOLUMEFOUND=1
	            i=1	
	        else
		    if [ ! -z "$VOLUMEFOUND" -a "$i" -eq '2' ]; then
		        ACTUAL_VOLUME=$(echo "$line" | cut -f1 -d'%'); 
	                echo "The volume is currently: $ACTUAL_VOLUME"
		        ((i++)); #needed if script does not exit
		       #exit 0	
		       break;
		    elif [ ! -z "$VOLUMEFOUND" ]; then
		        ((i++));
		    fi
	        fi;
	    fi 
        else 
	    if [[ $(echo "$line" | grep -i "index.") ]]; then 
	        PROPER_INDEX=0 
	    fi; 
        fi; 
    done
    if [ -z "$1" ]; then
       exit 0
    fi
fi

#allows for the use of a + or - to change the current percent by x amount
#make sure that the actual volume is recorded if something like -1 or +1 is passed
if [[ $(echo "$1" | egrep "^(-|\+)[0-9]$|^(-|\+)[0-9][0-9]$") ]]; then
    if [[ $(echo "$1" | egrep "^-[0-9]$|^-[0-9][0-9]$") ]]; then
	NEW_VOLUME=$(eval echo "$ACTUAL_VOLUME-$(echo -n "$1" | cut -f2 -d'-')" | bc)
    elif [[ $(echo "$1" | egrep "^\+[0-9]$|^\+[0-9][0-9]$") ]]; then
	NEW_VOLUME=$(eval echo "$ACTUAL_VOLUME+$(echo -n "$1" | cut -f2 -d'+')" | bc)
    fi
fi


if [[ "$1" != "mute" ]]; then
    if [ -z "$NEW_VOLUME" ]; then
        VALID_NUM=$1
    else
	VALID_NUM=$NEW_VOLUME
    fi
    #strip leading zeros
    while [[ $(echo "$VALID_NUM" | grep "^0.*") ]]; do 
        VALID_NUM=$(echo "$VALID_NUM" | sed -e "s/^0//g")
    done
    #make sure the input is indeed numbers...	
    if [[ ! $(echo "$VALID_NUM" | egrep "^[0-9]$|^[0-9][0-9]$") ]]; then
	echo "We only take valid whole numbers up to two digits."
	exit 123
    fi
   	
    if [[ $(echo "$VALID_NUM" | grep  "^[0-9]$") ]]; then
	#add a single 0 for single digit volume adjustments
	VALID_NUM=$(echo "0${VALID_NUM}")
    elif [[ $(echo "$VALID_NUM" | grep  "^[4-9][0-9].*") ]]; then
	#limit volume to 39 at highest
	VALID_NUM=10
	echo "HA"'!'" funny..."
    fi
    #do the actual math
    SCALEDNUM=$(echo ".${VALID_NUM}*65536" | bc | cut -f1 -d'.')
elif [[ "$1" == "mute" ]]; then
    SCALEDNUM=0
fi

pacmd set-sink-volume 1 ${SCALEDNUM} >> /dev/null

if [[ "$VALID_NUM" =~ ^0.* && ! -z "$VALID_NUM" ]]; then
    #remove leading 0s
    while [[ $(echo "$VALID_NUM" | grep "^0.*") ]]; do 
        VALID_NUM=$(echo "$VALID_NUM" | sed -e "s/^0//g")
    done
    #print single digit volume
    echo "Volume now set to $(echo -n "$VALID_NUM" | cut -b 1 )."
else
    #print whole two digit volume
    echo "Volume now set to $(echo -n ${VALID_NUM} | cut -b 1-2)."
fi

