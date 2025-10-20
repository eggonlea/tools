#!/bin/bash

DURATION=${1:-900}
OUT=${2:-test.out}

echo "=== Logs ==="
grep CPU ./$OUT/power?.log

echo "=== Delta ==="
echo "Duration: $DURATION sec"

# PowerStats HAL 1.0
KEYS=`awk '{for (i=1;i<NF;i++) if ($i ~ /^CPU(\W)/) {print $i}}' ./$OUT/power1.log`
for KEY in $KEYS; do
  PATTERN=$( echo "$KEY" | sed -e 's/[\(|\)]/\\\\&/g' )
  cat ./$OUT/power?.log | awk -v KEY=$KEY -v PAT=$PATTERN -v DUR=$DURATION \
    'BEGIN {t=0} $0 ~ PAT { if (t==0) t=$3; else printf("%40s\t%12.2f\t%8.2f\n", KEY,$3-t,($3-t)/DUR)}'
done

# PowerStats HAL 2.0
awk -v DUR=$DURATION \
  '/:CPU(\W)/ {t=substr($5,0,length($5)-1); printf("%40s\t%12.2f\t%8.2f\n", $1,t,t/DUR)}' ./$OUT/power2.log

