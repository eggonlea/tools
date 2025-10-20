#!/bin/bash

while [ 1 ]; do
	clear
	#. choose_adb.sh
	watch -n 1 -d -E adb shell "cat /proc/meminfo"
	sleep 1
done

