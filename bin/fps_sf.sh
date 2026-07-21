#!/bin/bash

adbroot.sh

set -x

FPS_ON=${1:-1}

adb shell service call SurfaceFlinger 1001 i32 ${FPS_ON}

