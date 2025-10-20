set -x
adbroot.sh
for i in $(seq 0 7)
do
	adb shell "echo 1 > /sys/devices/system/cpu/cpu$i/online"
	adb shell "echo performance > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor"
	adb shell "echo 2016000 > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq"
	adb shell "echo 2016000 > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq"
done

adb shell "echo 0 > /sys/class/kgsl/kgsl-3d0/bus_split"
adb shell "echo performance > /sys/class/kgsl/kgsl-3d0/devfreq/governor"
adb shell "cat /sys/class/kgsl/kgsl-3d0/devfreq/max_freq > /sys/class/kgsl/kgsl-3d0/devfreq/min_freq"
adb shell "echo 1 > /sys/class/kgsl/kgsl-3d0/force_bus_on"
adb shell "echo 1 > /sys/class/kgsl/kgsl-3d0/force_rail_on"
adb shell "echo 1 > /sys/class/kgsl/kgsl-3d0/force_clk_on"
adb shell "echo 1000000 > /sys/class/kgsl/kgsl-3d0/idle_timer"
