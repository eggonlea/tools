#!bin/bash

export ARCH=arm64
export SUBARCH=arm
export CROSS_COMPILE=~/work/toolchain/aarch64--glibc--stable-2020.08-1/bin/aarch64-linux-

which ${CROSS_COMPILE}gcc

#make -j$(nproc) mrproper
make -j$(nproc) defconfig
make -j$(nproc)

