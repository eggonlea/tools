set -x

adb shell stop

CPUCLK=1363200

for i in $(seq 4 7)
do
  adb shell "echo 0 > /sys/devices/system/cpu/cpu$i/online"
done

for i in $(seq 0 3)
do
  adb shell "echo 1 > /sys/devices/system/cpu/cpu$i/online"
  adb shell "echo userspace > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor"
  adb shell "echo $CPUCLK > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_max_freq"
  adb shell "echo $CPUCLK > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_min_freq"
  adb shell "echo $CPUCLK > /sys/devices/system/cpu/cpu$i/cpufreq/scaling_setspeed"
done

adb shell sync
adb shell "echo 3 > /proc/sys/vm/drop_caches"

for i in /sys/block/dm-*
do
  adb shell "echo 4 > $i/queue/read_ahead_kb"
done

trap 'echo Ctrl-C detected; exit' INT
trap 'echo TERM detected; adb shell killall busyloop; exit' TERM
trap 'echo Cleanup; kill 0' EXIT

for i in $(seq 0 31)
do
  adb shell /data/busyloop $i &
done

adb shell /data/pagefault_traversal /system/apex
