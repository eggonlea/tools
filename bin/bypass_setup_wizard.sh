#!/bin/sh

set -x

adbroot.sh
adb shell am start -a com.android.setupwizard.EXIT

