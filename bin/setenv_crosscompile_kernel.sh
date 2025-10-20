#!/bin/bash

# Download aarch64 glibc toolchain from https://toolchains.bootlin.com/
export ARCH=arm64
export SUBARCH=arm
export CROSS_COMPILE=~/work/toolchain/aarch64--glibc--stable-2020.08-1/bin/aarch64-linux-

which ${CROSS_COMPILE}gcc
