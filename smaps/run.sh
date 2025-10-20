# Please flash and configure the device before running this script.

set -x
adb reboot
sleep 3
adb wait-for-device
sleep 3
adb root
sleep 3
adb wait-for-device
sleep 180
adb shell am kill-all
clear_fscache.sh
#adb bugreport > bugreport.log
adb bugreport bugreport.zip
