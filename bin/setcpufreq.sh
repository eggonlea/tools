set -x
adbroot.sh

for i in $(seq 0 7)
do
	adb shell "echo $1 > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq"
	adb shell "echo $1 > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq"
done
