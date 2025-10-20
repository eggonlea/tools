#!/system/bin/sh

CMD="$@"
echo "$0 $@"
OUT=`$CMD`
RET=$?
echo "Return Value: $RET"
echo "Standard out: $OUT"
