#!/bin/bash

set -x
adb shell "echo $1 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq"
