#!bin/bash

set -x
adbroot.sh

adb shell "echo disabled > /sys/class/thermal/thermal_zone0/mode"
adb shell "echo disabled > /sys/class/thermal/thermal_zone1/mode"
adb shell "cat /sys/class/thermal/thermal_zone0/mode /sys/class/thermal/thermal_zone1/mode"

adb shell "echo ff634808 0x0 > /sys/kernel/debug/aml_reg/paddr"
adb shell "echo ff634c08 0x0 > /sys/kernel/debug/aml_reg/paddr"

for i in $(seq 0 5)
do
	adb shell "echo 1 > /sys/devices/system/cpu/cpu$i/online"
	adb shell "echo performance > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor"
	#adb shell "echo 2016000 > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq"
	#adb shell "echo 2016000 > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq"
done
adb shell "cat /sys/devices/system/cpu/online"

adb shell "echo 3 > /sys/class/mpgpu/scale_mode"
adb shell "cat /sys/class/mpgpu/cur_freq"
adb shell "cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"

