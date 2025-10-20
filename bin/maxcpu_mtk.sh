set -x
adbroot.sh

# CPU
for i in $(seq 0 7)
do
	adb shell "echo 1 > /sys/devices/system/cpu/cpu$i/online"
	adb shell "echo performance > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor"
	#adb shell "echo 1989000 > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq"
	#adb shell "echo 1989000 > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq"
done
adb shell "cat /sys/devices/system/cpu/online"
adb shell "cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"

# DDR
#adb shell "echo kr_req_mask 65535 > /sys/power/vcorefs/vcore_debug"
#adb shell "echo skip 1 > /sys/class/devfreq/10012000.dvfsrc_top/device/helio-dvfsrc/dvfsrc_debug"
#adb shell "echo KIR_SYSFSX 0 > /sys/power/vcorefs/vcore_debug"

# GPU
#adb shell "echo 800000 > /proc/gpufreq/gpufreq_opp_freq"
#adb shell "echo 0 > /proc/gpufreq/gpufreq_opp_freq"
