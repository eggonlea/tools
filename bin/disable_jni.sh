#!bin/bash

adb remount
adb pull /system/build.prop /tmp/build.prop
sed -i -e 's/ro.kernel.android.checkjni=1//g' /tmp/build.prop
adb push /tmp/build.prop /system/build.prop
adb shell chmod 644 /system/build.prop
adb shell stop
adb shell start

