#!/bin/sh

PID=$1
CGROUP=/sys/fs/cgroup/test

adbroot.sh

./run_perfetto.sh &
sleep 8

set -x

adb shell "mkdir -p $CGROUP"
adb shell "echo $PID > $CGROUP/cgroup.procs"
adb shell "echo 1 > $CGROUP/cgroup.freeze"
adb shell "kill -9 $PID"
adb shell "echo 0 > $CGROUP/cgroup.freeze"
sleep 1

echo "Waiting for perfetto to finish..."
wait
