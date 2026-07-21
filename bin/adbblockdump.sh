#!bin/bash

adbroot.sh

rm -f /tmp/block.dump

while [ 1 ]
do
adb shell 'echo 1 > /proc/sys/vm/block_dump'
adb shell 'cat /proc/kmsg' | tee -a /tmp/block.dump
done
