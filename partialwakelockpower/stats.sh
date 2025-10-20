#!/bin/bash

OUT=${1:-long.out}

# PowerStats HAL 2.0
grep "PowerStats HAL 2.0" ./$OUT/power0.log > /dev/null 2> /dev/null
if [ $? -eq 0 ]; then
  i=0
  HEAD=$(echo "Time" && sed -n -r 's/\s*(\S+) .* mWs \(.*\)$/\1/gp' ./$OUT/power0.log)
  echo $HEAD
  while true; do
    FILE=./$OUT/power$i.log
    if [ -f $FILE ]; then
      LINE=$(echo "$i" && sed -n -r 's/.* mWs \(\s*([0-9]+\.[0-9]+)\)$/\1/gp' $FILE)
      echo $LINE
      i=$(( $i + 1 ))
    else
      exit
    fi
  done
fi

# PowerStats HAL 1.0
grep "PowerStats HAL 1.0" ./$OUT/power0.log > /dev/null 2> /dev/null
if [ $? -eq 0 ]; then
  i=0
  HEAD=$(echo "Time" && sed -n -r 's/\s*(\S+) .* mWs/\1/gp' ./$OUT/power0.log)
  echo $HEAD
  while true; do
    FILE=./$OUT/power$i.log
    if [ -f $FILE ]; then
      LINE=$(echo "$i" && sed -n -r 's/.* ([0-9]+\.[0-9]+) mWs/\1/gp' $FILE)
      echo $LINE
      i=$(( $i + 1 ))
    else
      exit
    fi
  done
fi
