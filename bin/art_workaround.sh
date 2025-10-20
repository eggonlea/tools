adb remount
adb pull /system/build.prop /tmp/build.prop
sed -i -e 's/dalvik.vm.image-dex2oat-flags=--compiler-filter=verify-none//g' /tmp/build.prop
sed -i -e 's/dalvik.vm.image-dex2oat-filter=verify-none//g' /tmp/build.prop
sed -i -e 's/dalvik.vm.dex2oat-flags=--compiler-filter=interpret-only//g' /tmp/build.prop
sed -i -e 's/dalvik.vm.dex2oat-filter=interpret-only//g' /tmp/build.prop
adb push /tmp/build.prop /system/build.prop
adb shell chmod 644 /system/build.prop

adb shell 'echo 0 > /sys/fs/selinux/enforce'

adb shell stop
adb shell rm -rf /data/dalvik-cache/*
adb shell setprop dalvik.vm.dex2oat-flags ""
adb shell setprop dalvik.vm.dex2oat-filter ""
adb shell setprop dalvik.vm.image-dex2oat-flags ""
adb shell setprop dalvik.vm.image-dex2oat-filter ""
adb shell start

