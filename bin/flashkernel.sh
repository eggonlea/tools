#!/bin/sh

set -x

KERNEL=${1:-android-msm-pixel-4.19}

adb reboot bootloader

fastboot flash dtbo out/$KERNEL/dist/dtbo.img
fastboot flash vendor_boot out/$KERNEL/dist/vendor_boot.img
fastboot flash boot out/$KERNEL/dist/boot.img

fastboot reboot
