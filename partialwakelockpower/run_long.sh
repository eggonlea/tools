#!/bin/bash

echo "Example Usage: ./run.sh 60 long.out 'sleep 60'"

DURATION=${1:-5}
OUT=${2:-long.out}
if [ $# -le 3 ]; then
  WORKLOAD=${3:-"sleep 60"}
else
  shift 2
  WORKLOAD=$@
fi

echo "Duration: $DURATION"
echo "Out     : $OUT"
echo "Workload: $WORKLOAD"

adbroot.sh
adb shell rm -rf /mnt/$OUT
adb shell mkdir -p /mnt/$OUT
adb push long_wakelock.sh /data
adb push bg_long_wakelock.sh /data
adb shell /data/bg_long_wakelock.sh $DURATION $OUT $WORKLOAD

sleep $DURATION

adb wait-for-device
adb pull /mnt/$OUT
./stats.sh $OUT | tee ./$OUT/stats.log
