#!/bin/bash

adbroot.sh

adb shell "echo 0 > /proc/sys/kernel/kptr_restrict"

adb shell /data/perf.main top


