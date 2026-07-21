#!/bin/bash

ID=${1:-0}
adb pull /proc/stat /tmp/procstat.$ID > /dev/null 2> /dev/null
top.py /tmp/procstat.$ID.old /tmp/procstat.$ID 2> /dev/null
cp /tmp/procstat.$ID /tmp/procstat.$ID.old 2> /dev/null
