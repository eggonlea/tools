#watch -n 1 -d "adb shell cat /proc/interrupts | sed -e '/ 0          0          0          0 /d'"
watch -n 1 -d "adb shell cat /proc/interrupts | sed -e '/ 0          0          0          0          0          0          0          0 /d'"
