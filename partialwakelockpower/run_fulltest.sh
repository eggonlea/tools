# aa for ANDROID_SERIAL
export TARGET=$TARGET_PRODUCT

# factory reset
adb reboot bootloader
fastboot erase userdata
fastboot reboot
adbroot.sh
wait_bootcompleted.sh

# sleep 5m = 300s
echo "Waiting for 5 min"
sleep 300
PID=`adb shell pidof system_server`

# 1st round
export OO=$TARGET.1.5m.power.out
rm -rf $OO
unlock.sh
./run_partial.sh 900 $OO sleep

# 2nd round
export OO=$TARGET.2.36m.power.out
rm -rf $OO
unlock.sh
./run_partial.sh 900 $OO sleep

