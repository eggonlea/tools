#!/bin/bash

PACKAGES=`adb shell pm list packages -f | sed 's/^package://g' | sed 's/\(.*\)\/.*$/\1/g'`
for i in $PACKAGES
do
	echo $i
	adb pull $i
done
