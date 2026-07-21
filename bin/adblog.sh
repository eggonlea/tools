#!bin/bash

#adb logcat -b all "$@"
#exit

trap 'echo Ctrl-C detected; exit' INT
trap 'echo TERM detected; exit' TERM
trap 'echo Cleanup; kill 0' EXIT

adbroot.sh

# Doesn't work for logd since Android L
#adb shell '(cat /proc/kmsg | while read LINE; do echo \\06kernel\\0$LINE\\0 > /dev/log/main; done)' &
adb push `which dmesg2logcat` /data/
adb shell '/data/dmesg2logcat' &
adb logcat -vthreadtime "$@"
