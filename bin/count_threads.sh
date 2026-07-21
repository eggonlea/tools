#!bin/bash

set -x
adb shell "cat /proc/*/status" | grep -E "Name|Threads"
