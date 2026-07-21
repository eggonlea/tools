#!/bin/bash

ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- make menuconfig
ARCH=arm64 CROSS_COMPILE=aarch64-linux-android- make savedefconfig
