#!/bin/sh

set -x

DIST_DIR=out/mixed/dist

fastboot set_active a
fastboot erase boot_a && fastboot erase boot_b
fastboot erase vendor_boot_a && fastboot erase vendor_boot_b
fastboot stage $DIST_DIR/dtbo.img
fastboot stage $DIST_DIR/vendor_boot.img
fastboot boot $DIST_DIR/boot.img
