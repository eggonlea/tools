#!bin/bash

#adb wait-for-device
echo "Waiting for BOOT_COMPLETED"
while [ "`adb shell getprop sys.boot_completed | tr -d '\r' `" != "1" ] ; do sleep 1; done

