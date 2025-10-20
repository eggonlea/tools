# aa for ANDROID_SERIAL
export TARGET=$TARGET_PRODUCT

# factory reset
adb reboot bootloader
fastboot erase userdata
fastboot reboot
adbroot.sh

# sleep 5m = 300s
sleep 300
PID=`adb shell pidof system_server`

# 1st round
export OO=$TARGET.1.5m.simpleperf.ss.out
rm -rf $OO
unlock.sh
./run_partial.sh 900 $OO simpleperf record -p $PID -g --post-unwind=yes -m 8192 -o /mnt/$OO/perf.data -f 1000 --log info sleep

# 2nd round
export OO=$TARGET.2.36m.simpleperf.ss.out
rm -rf $OO
unlock.sh
./run_partial.sh 900 $OO simpleperf record -p $PID -g --post-unwind=yes -m 8192 -o /mnt/$OO/perf.data -f 1000 --log info sleep

