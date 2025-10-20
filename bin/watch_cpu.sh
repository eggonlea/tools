#!/bin/bash

# require a modified watch which accepts -E (in addition to -e)

while [ 1 ]; do
	adbroot.sh
	clear
	. choose_adb.sh
	#watch -n 1 -d -E cpu.sh $$
	watch -n 1 -d cpu.sh $$
	rm -rf /tmp/cpu.$$ 2> /dev/null
	sleep 1
done

