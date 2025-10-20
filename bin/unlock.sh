#!/bin/sh

set -x

adb shell input keyevent KEYCODE_MENU

if [ $# -gt 0 ]; then
#adb shell sqlite3 /data/system/locksettings.db "update locksettings set value=1 where name='lockscreen.disabled'"
adb shell settings put system screen_off_timeout 1800000
#adb shell settings put global stay_on_while_plugged_in 7
fi
