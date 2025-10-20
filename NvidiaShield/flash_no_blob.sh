set -x

# adb reboot bootloader

#fastboot flash staging blob
#fastboot reboot-bootloader

fastboot flash boot boot.img

# fastboot reboot
# adb wait-for-device
# adb reboot bootloader

fastboot flash recovery recovery.img
fastboot flash system system.img
fastboot flash vendor vendor.img
fastboot reboot

