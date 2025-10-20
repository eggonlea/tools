#!/bin/bash

echo "Example Usage: ./run.sh 900 test.out 'simpleperf record -a -o /mnt/test.out/perf.data sleep'"

DURATION=${1:-5}
OUT=${2:-test.out}
if [ $# -le 3 ]; then
  WORKLOAD=${3:-sleep}
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
adb push partial_wakelock.sh /data
adb push bg_partial_wakelock.sh /data
adb shell /data/bg_partial_wakelock.sh $DURATION $OUT $WORKLOAD

sleep $DURATION

adb wait-for-device
sleep 1
adb pull /mnt/$OUT
./parse.sh $DURATION $OUT | tee ./$OUT/parse.log

adb bugreport $OUT
