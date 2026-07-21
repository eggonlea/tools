#!bin/bash

set -x
while [ 1 ]
do
	adbroot.sh
	adb shell cat /proc/kmsg
	sleep 0.1
done
