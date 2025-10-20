set -x
adb shell sync
adb shell "echo 3 > /proc/sys/vm/drop_caches"

