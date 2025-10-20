set -x
BLANK=${1:-1}
adb shell "echo ${BLANK} > /sys/class/graphics/fb0/blank"
