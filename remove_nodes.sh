#!/bin/bash

LASTNAME=""
LASTNODE=""

for node in `knife node list`
do

  case `knife node show $node -a chef_environment` in
		"chef_environment:  vagrant")
		
		NAME=`echo $node | sed 's/-[^-]*$//'`

		if [ -z "$LASTNAME" ]; then
			LASTNAME=$NAME
			LASTNODE=$node
		elif [ "$LASTNAME" == "$NAME" ]; then
			DELETE=("${DELETE[@]}" $LASTNODE)
			LASTNAME=$NAME
			LASTNODE=$node
		else
			LASTNAME=$NAME
			LASTNODE=$node
		fi

	esac

done

for node in "${DELETE[@]}"
do
	knife node delete $node -y
	knife client delete $node -y
done