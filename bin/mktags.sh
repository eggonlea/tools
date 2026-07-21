#!/bin/bash

KERNEL_SRC=$PWD
cd $TOP
make -j6 -C $KERNEL_SRC O=$OUT/obj/KERNEL_OBJ ARCH=arm64 CROSS_COMPILE=$TOP/prebuilts/gcc/linux-x86/aarch64/aarch64-linux-android-4.9/bin/aarch64-linux-android- CLANG_TRIPLE=aarch64-linux-gnu- CC=$TOP/prebuilts/clang/host/linux-x86/clang-4691093/bin/clang ROOTDIR=$TOP tags
cd $KERNEL_SRC
ln -f -s $OUT/obj/KERNEL_OBJ/tags .
